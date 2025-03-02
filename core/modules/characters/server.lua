local characters = {}

--- Creates a new character for a player.
--- @param options table: Table containing character details.
--- @return table|nil: The created character object or nil if failed.
local function create_character(options)
    if not options or not options.source or not options.unique_id or not options.first_name or not options.last_name or not options.sex or not options.date_of_birth then
        return debug_log('error', 'Missing required parameters to create a character.')
    end
    local user_data = MySQL.query.await('SELECT character_slots FROM utils_users WHERE unique_id = ?', { options.unique_id })
    if not user_data or not user_data[1] then return debug_log('error', ('Failed to retrieve user data for unique_id: %s'):format(options.unique_id)) end
    local max_characters = user_data[1].character_slots or 2
    local char_count = MySQL.scalar.await('SELECT COUNT(*) FROM players WHERE unique_id = ?', { options.unique_id }) or 0
    if char_count >= max_characters then
        debug_log('warn', ('User %s has reached their character limit (%d/%d).'):format(options.unique_id, char_count, max_characters))
        return nil, 'Character slot limit reached. Delete an existing character to create a new one.'
    end
    local char_id = (MySQL.query.await('SELECT MAX(char_id) as max_id FROM players WHERE unique_id = ?', { options.unique_id })[1] or {}).max_id or 0
    char_id = char_id + 1
    local identifier = ('%s_%s'):format(options.unique_id, char_id)
    local style = STYLES.get_style(options.sex) or {}
    local total_weight = calculate_total_item_weight(config.new_characters.inventory.items)
    local queries = {
        { 'INSERT INTO players (unique_id, char_id, identifier, first_name, middle_name, last_name, sex, date_of_birth, nationality) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', { options.unique_id, char_id, identifier, options.first_name, options.middle_name or '', options.last_name, options.sex, options.date_of_birth, options.nationality }},
        { 
            'INSERT INTO player_inventories (identifier, grid_columns, grid_rows, weight, max_weight, items) VALUES (?, ?, ?, ?, ?, ?)', 
            { identifier, config.new_characters.inventory.grid_columns, config.new_characters.inventory.grid_rows, total_weight, config.new_characters.inventory.max_weight, json.encode(config.new_characters.inventory.items) }
        },        
        { 'INSERT INTO player_spawns (identifier, spawn_id) VALUES (?, ?)', { identifier, 'last_location' } },
        { 'INSERT INTO player_statuses (identifier) VALUES (?)', { identifier } },
        { 'INSERT INTO player_flags (identifier) VALUES (?)', { identifier } },
        { 'INSERT INTO player_injuries (identifier) VALUES (?)', { identifier } },
        { 'INSERT INTO player_styles (identifier, style) VALUES (?, ?)', { identifier, json.encode(style) } },
        { 'INSERT INTO player_alignments (identifier) VALUES (?)', { identifier } }
    }
    for _, account in ipairs(config.new_characters.accounts) do
        queries[#queries + 1] = { 'INSERT INTO player_accounts (identifier, account_type, balance) VALUES (?, ?, ?)', { identifier, account.account_type, account.balance }}
    end
    for _, role in ipairs(config.new_characters.roles) do
        queries[#queries + 1] = { 'INSERT INTO player_roles (identifier, role_id, role_type, rank, metadata) VALUES (?, ?, ?, ?, ?)', { identifier, role.role_id, role.role_type, role.rank, json.encode(role.metadata or {}) } }
    end
    local success = MySQL.transaction.await(queries)
    if not success then return debug_log('error', 'Failed to create character in database.') end
    debug_log('success', ('Character created: %s (%s %s %s)'):format(identifier, options.first_name, options.middle_name or '', options.last_name))
    return { first_name = options.first_name, middle_name = options.middle_name or '', last_name = options.last_name }
end

characters.create_character = create_character
exports('create_character', create_character)

--- Fetches a players characters.
---@param source number: The player source ID.
---@return table: A table of characters with details.
local function get_characters(source)
    local user = exports.fivem_utils:get_user(source)
    if not user then debug_log('error', ('User not found for source: %d'):format(source)) return end
    local unique_id = user.unique_id
    local query = [[
        SELECT c.*, cs.style, cs.has_customised, pa.title AS alignment_title
        FROM players c
        LEFT JOIN player_styles cs ON c.identifier = cs.identifier
        LEFT JOIN player_alignments pa ON c.identifier = pa.identifier
        WHERE c.unique_id = ?
    ]]
    local params = { unique_id }
    local chars = MySQL.query.await(query, params)
    if not chars or #chars == 0 then debug_log('warn', ('No characters found for user with unique_id: %s'):format(unique_id)) return {} end
    local mapped_chars = {}
    for _, character in ipairs(chars) do
        mapped_chars[#mapped_chars + 1] = {
            char_id = character.char_id,
            profile_picture = character.profile_picture,
            title = ('%s %s %s'):format(character.first_name, character.middle_name or '', character.last_name),
            description = { ('%s'):format(character.alignment_title or 'Not Assigned') },
            values = {
                { key = 'Identifier', value = character.identifier },
                { key = 'Sex', value = character.sex },
                { key = 'Date Of Birth', value = character.date_of_birth },
                { key = 'Nationality', value = character.nationality }
            },
            data = {
                identity = character,
                style = character.style and type(character.style) == 'string' and json.decode(character.style) or {}
            }
        }
    end
    return mapped_chars
end

characters.get_characters = get_characters
exports('get_characters', get_characters)

--- Deletes a character from the database.
---@param source number: The source player ID.
---@param char_id number: The character ID to delete.
---@return boolean: Whether the deletion was successful.
function delete_character(source, char_id)
    local user = get_user(source)
    if not user then return false end
    local unique_id = user.unique_id
    local rows_deleted = MySQL.update.await('DELETE FROM players WHERE unique_id = ? AND char_id = ?', { unique_id, char_id })
    if rows_deleted and rows_deleted > 0 then
        return true
    end
    return false
end

characters.delete_character = delete_character
exports('delete_character', delete_character)

--- Saves the players character customization.
---@param source number: The source player ID.
---@param style table: The customization data to save.
---@return boolean: Indicates whether this was the players first customization.
local function save_character_customisation(source, style)
    local player = player_registry[source]
    if not player then
        debug_log('error', ('Player not found for source: %s'):format(source))
        return false, false
    end
    local is_first_customisation = not player.styles:has_customised()
    local style_updated = player.styles:set_style(style)
    if not style_updated then debug_log('error', ('Failed to update style for player: %s'):format(source)) return false, false end
    player.styles:mark_as_customised()
    return true, is_first_customisation
end

characters.save_character_customisation = save_character_customisation
exports('save_character_customisation', save_character_customisation)

return characters
