Player = {}

Player.__index = Player

--- Creates a new Player instance.
--- @param source number: The players source ID.
--- @param unique_id string: The players unique identifier.
--- @param char_id number: The players character ID.
--- @return table: The new Player object.
function Player.new(source, unique_id, char_id)
    if not source then debug_log('error', 'Player creation failed: source ID is nil') return nil end
    if not unique_id then debug_log('error', 'Player creation failed: unique identifier is nil') return nil end
    if not char_id then debug_log('error', 'Player creation failed: character ID is nil') return nil end

    local self = setmetatable({
        source = source,
        unique_id = unique_id,
        char_id = char_id,
        identifier = ('%s_%s'):format(unique_id, char_id),
        _data = {
            accounts = {},
            alignment = {},
            effects = {},
            flags = {},
            identity = {},
            injuries = {},
            inventory = {},
            roles = {},
            spawns = {},
            statuses = {},
            styles = {}
        }        
    }, Player)

    self.accounts = Accounts.new(self)
    self.alignment =Alignment.new(self)
    self.effects = Effects.new(self)
    self.flags = Flags.new(self)
    self.identity = Identity.new(self)
    self.injuries = Injuries.new(self)
    self.inventory = Inventory.new(self)
    self.roles = Roles.new(self)
    self.spawns = Spawns.new(self)
    self.statuses = Statuses.new(self)
    self.styles = Styles.new(self)

    player_registry[self.source] = self
    return self
end

--- Initialize the players data.
function Player:init()
    local identifier = self.identifier
    local data = MySQL.query.await([[
        SELECT 
            p.*, 
            s.style, s.outfits, s.has_customised,
            inv.grid_columns, inv.grid_rows, inv.weight, inv.max_weight, inv.items,
            JSON_OBJECTAGG(acc.account_type, JSON_OBJECT('balance', acc.balance, 'metadata', acc.metadata)) AS accounts,
            JSON_OBJECTAGG(r.role_id, JSON_OBJECT('role_type', r.role_type, 'rank', r.rank, 'metadata', r.metadata)) AS roles,
            st.health, st.armour, st.hunger, st.thirst, st.stress, st.stamina, st.oxygen, st.hygiene,
            f.is_dead, f.is_downed, f.is_handcuffed, f.is_ziptied, f.is_wanted, f.is_jailed, f.is_safezone, f.is_grouped, 
            i.head, i.upper_torso, i.lower_torso, i.forearm_right, i.hand_right, i.thigh_right, i.calf_right, i.foot_right, i.forearm_left, i.hand_left, i.thigh_left, i.calf_left, i.foot_left,
            JSON_ARRAYAGG(JSON_OBJECT('spawn_id', sp.spawn_id, 'x', sp.x, 'y', sp.y, 'z', sp.z, 'w', sp.w)) AS spawns,
            JSON_ARRAYAGG(JSON_OBJECT('effect_id', e.effect_id, 'effect_type', e.effect_type, 'label', e.label, 'description', e.description, 'icon', e.icon, 'applied', e.applied)) AS effects,
            a.lawfulness, a.morality, a.title, a.lawful_actions, a.unlawful_actions, a.moral_actions, a.immoral_actions
        FROM players p
        LEFT JOIN player_styles s ON p.identifier = s.identifier
        LEFT JOIN player_inventories inv ON p.identifier = inv.identifier
        LEFT JOIN player_accounts acc ON p.identifier = acc.identifier
        LEFT JOIN player_roles r ON p.identifier = r.identifier
        LEFT JOIN player_statuses st ON p.identifier = st.identifier
        LEFT JOIN player_flags f ON p.identifier = f.identifier
        LEFT JOIN player_injuries i ON p.identifier = i.identifier
        LEFT JOIN player_effects e ON p.identifier = e.identifier
        LEFT JOIN player_spawns sp ON p.identifier = sp.identifier
        LEFT JOIN player_alignments a ON p.identifier = a.identifier
        WHERE p.identifier = ?
        GROUP BY p.identifier
    ]], { identifier })

    local player_data = self._data
    local result = data and data[1] or {}

    player_data.identity = {
        first_name = result.first_name or 'John',
        middle_name = result.middle_name or nil,
        last_name = result.last_name or 'Doe',
        sex = result.sex or 'm',
        date_of_birth = result.date_of_birth or '2000-01-01',
        nationality = result.nationality or 'United Kingdom',
        profile_picture = result.profile_picture or 'assets/images/avatar_placeholder.jpg'
    }

    player_data.styles = {
        style = json.decode(result.style or '{}'),
        outfits = json.decode(result.outfits or '{}'),
        has_customised = result.has_customised
    }

    player_data.inventory = {
        grid_columns = result.grid_columns or config.new_characters.inventory.grid.columns,
        grid_rows = result.grid_rows or config.new_characters.inventory.grid.rows,
        weight = result.weight or config.new_characters.inventory.weight,
        max_weight = result.max_weight or config.new_characters.inventory.max_weight,
        items = json.decode(result.items) or config.new_characters.inventory.items
    }

    player_data.accounts = json.decode(result.accounts or '{}')
    if not next(player_data.accounts) then
        player_data.accounts = {}
        for _, default_account in ipairs(config.new_characters.accounts) do
            player_data.accounts[default_account.account_type] = {
                balance = default_account.balance,
                metadata = {}
            }
        end
    end

    player_data.roles = json.decode(result.roles or '{}')
    if not next(player_data.roles) then
        player_data.roles = {}
        for _, default_role in ipairs(config.new_characters.roles) do
            player_data.roles[default_role.role_id] = {
                role_type = default_role.role_type,
                rank = default_role.rank,
                metadata = default_role.metadata or {}
            }
        end
    end

    player_data.statuses = {
        health = result.health or 200,
        armour = result.armour or 0,
        hunger = result.hunger or 100,
        thirst = result.thirst or 100,
        stress = result.stress or 0,
        stamina = result.stamina or 100,
        oxygen = result.oxygen or 100,
        hygiene = result.hygiene or 100
    }

    player_data.flags = {
        is_dead = result.is_dead == 1,
        is_downed = result.is_downed == 1,
        is_handcuffed = result.is_handcuffed == 1,
        is_ziptied = result.is_ziptied == 1,
        is_wanted = result.is_wanted == 1,
        is_jailed = result.is_jailed == 1,
        is_safezone = result.is_safezone == 1,
        is_grouped = result.is_grouped == 1
    }

    player_data.injuries = {
        head = result.head or 0,
        upper_torso = result.upper_torso or 0,
        lower_torso = result.lower_torso or 0,
        forearm_right = result.forearm_right or 0,
        hand_right = result.hand_right or 0,
        thigh_right = result.thigh_right or 0,
        calf_right = result.calf_right or 0,
        foot_right = result.foot_right or 0,
        forearm_left = result.forearm_left or 0,
        hand_left = result.hand_left or 0,
        thigh_left = result.thigh_left or 0,
        calf_left = result.calf_left or 0,
        foot_left = result.foot_left or 0
    }

    player_data.effects = json.decode(result.effects or '{}')

    player_data.spawns = {}
    local spawn_locations = json.decode(result.spawns or '{}') or {}
    for _, spawn in ipairs(spawn_locations) do
        player_data.spawns[spawn.spawn_id] = { x = spawn.x, y = spawn.y, z = spawn.z, w = spawn.w }
    end

    if not next(player_data.spawns) then
        player_data.spawns.last_location = { x = -268.47, y = -956.98, z = 31.22, w = 208.54 }
    end

    player_data.alignment = {
        lawfulness = result.lawfulness or 500,
        morality = result.morality or 500,
        title = result.title or 'True Neutral',
        lawful_actions = result.lawful_actions or 0,
        unlawful_actions = result.unlawful_actions or 0,
        moral_actions = result.moral_actions or 0,
        immoral_actions = result.immoral_actions or 0
    }

    debug_log('success', ('Loaded player: %s (New: %s)'):format(self.identifier, not data))
    self:sync_data()
    return true
end

--- Saves the players data.
function Player:save()
    local identifier = self.identifier
    if not identifier then return end
    local queries = {
        { 
            'UPDATE player_inventories SET grid_columns = ?, grid_rows = ?, weight = ?, max_weight = ?, items = ? WHERE identifier = ?', 
            { self._data.inventory.grid_columns, self._data.inventory.grid_rows, self._data.inventory.weight, self._data.inventory.max_weight, json.encode(self._data.inventory.items), identifier }
        },
        { 
            'UPDATE player_statuses SET health = ?, armour = ?, hunger = ?, thirst = ?, stress = ?, stamina = ?, oxygen = ?, hygiene = ? WHERE identifier = ?', 
            { self._data.statuses.health, self._data.statuses.armour, self._data.statuses.hunger, self._data.statuses.thirst, self._data.statuses.stress, self._data.statuses.stamina, self._data.statuses.oxygen, self._data.statuses.hygiene, identifier }
        },
        { 
            'UPDATE player_flags SET is_dead = ?, is_downed = ?, is_handcuffed = ?, is_ziptied = ?, is_wanted = ?, is_jailed = ?, is_safezone = ?, is_grouped = ? WHERE identifier = ?', 
            { self._data.flags.is_dead and 1 or 0, self._data.flags.is_downed and 1 or 0, self._data.flags.is_handcuffed and 1 or 0, self._data.flags.is_ziptied and 1 or 0, self._data.flags.is_wanted and 1 or 0, self._data.flags.is_jailed and 1 or 0, self._data.flags.is_safezone and 1 or 0, self._data.flags.is_grouped and 1 or 0, identifier }
        },
        { 
            'UPDATE player_injuries SET head = ?, upper_torso = ?, lower_torso = ?, forearm_right = ?, hand_right = ?, thigh_right = ?, calf_right = ?, foot_right = ?, forearm_left = ?, hand_left = ?, thigh_left = ?, calf_left = ?, foot_left = ? WHERE identifier = ?', 
            { self._data.injuries.head, self._data.injuries.upper_torso, self._data.injuries.lower_torso, self._data.injuries.forearm_right, self._data.injuries.hand_right, self._data.injuries.thigh_right, self._data.injuries.calf_right, self._data.injuries.foot_right, self._data.injuries.forearm_left, self._data.injuries.hand_left, self._data.injuries.thigh_left, self._data.injuries.calf_left, self._data.injuries.foot_left, identifier }
        },
        { 
            'UPDATE player_styles SET style = ?, outfits = ?, has_customised = ? WHERE identifier = ?', 
            { json.encode(self._data.styles.style), json.encode(self._data.styles.outfits), self._data.styles.has_customised and 1 or 0, identifier }
        }
    }

    for account_type, account_data in pairs(self._data.accounts) do
        queries[#queries + 1] = { 'UPDATE player_accounts SET balance = ?, metadata = ? WHERE identifier = ? AND account_type = ?', { account_data.balance, json.encode(account_data.metadata), identifier, account_type }}
    end

    for role_id, role in pairs(self._data.roles) do
        queries[#queries + 1] = { 'UPDATE player_roles SET role_type = ?, rank = ?, metadata = ? WHERE identifier = ? AND role_id = ?', { role.role_type, role.rank, json.encode(role.metadata or {}), identifier, role_id }}
    end

    for spawn_id, spawn in pairs(self._data.spawns) do
        queries[#queries + 1] = { 'UPDATE player_spawns SET x = ?, y = ?, z = ?, w = ? WHERE identifier = ? AND spawn_id = ?', { spawn.x, spawn.y, spawn.z, spawn.w, identifier, spawn_id }}
    end

    local success = MySQL.transaction.await(queries)
    if not success then return debug_log('error', ('Save failed for player: %s! Check MySQL logs.'):format(identifier)) end
end

exports('save_player', function(source)
    local player = player_registry[source]
    if player then player:save() return true end
    return false
end)

--- Retrieves player data securely.
--- @param category string|nil: The category of data to retrieve (optional).
--- @return table|nil: The requested data or all player data if no category is provided.
function Player:get_data(category)
    return category and self._data[category] or self._data
end

exports('get_data', function(source, category)
    local player = player_registry[source]
    if player then return player:get_data(category) end
    return nil
end)

--- Sets player data securely.
--- @param category string: The category to update.
--- @param updates table: The new values to merge into the category.
function Player:set_data(category, updates)
    if not category or type(self._data[category]) ~= 'table' then return false end
    local key, value = next(updates)
    while key do
        self._data[category][key] = value
        key, value = next(updates, key)
    end
    self:sync_data(category)
    return true
end

exports('set_data', function(source, category, updates)
    local player = player_registry[source]
    if not player or type(updates) ~= 'table' then return false end
    return player:set_data(category, updates)
end)

--- Syncs player data to the client securely.
--- @param category string|nil: The category of data to sync (optional).
function Player:sync_data()
    TriggerClientEvent('keystone:cl:update_player_data', self.source, self._data)
end

--- Log out the player.
function Player:logout()
    self:save()
    player_registry[self.source] = nil
    TriggerClientEvent('keystone:cl:logout', self.source)
end

exports('logout', function(source)
    local player = player_registry[source]
    if player then player:logout() return true end
    return false
end)

--- Kick the player from the server.
--- @param reason string: The reason they were kicked.
function Player:kick(reason)
    DropPlayer(self.source, reason or 'You have been kicked from the server.')
    player_registry[self.source] = nil
end

exports('kick', function(source, target_id, reason)
    local player = player_registry[target_id]
    if not player then debug_log('error', ('Failed to find player %d in registry.'):format(source)) return false end
    player:kick(reason)
    return true
end)

--- Bans the player and logs the ban.
--- @param banned_by string: The admin/mod/user who issued the ban.
--- @param reason string: The reason for the ban.
--- @param duration string|nil: Duration string (e.g., '10m', '2h', '1d', 'perm').
function Player:ban(banned_by, duration, reason)
    if not banned_by or not reason then return false end
    local duration_seconds = parse_duration(duration)
    local expires_at = duration_seconds and (os.time() + duration_seconds) or nil
    local update_success = MySQL.update.await('UPDATE utils_users SET banned = 1, banned_by = ?, reason = ? WHERE unique_id = ?', {banned_by, reason, self.unique_id})
    if not update_success then return false end
    local insert_success = MySQL.insert.await('INSERT INTO utils_bans (unique_id, banned_by, reason, expires_at, expired, appealed) VALUES (?, ?, ?, ?, ?, ?)', {self.unique_id, banned_by, reason, expires_at and os.date('%Y-%m-%d %H:%M:%S', expires_at) or nil, 0, 0})
    if not insert_success then return false end
    self:kick(('You have been banned by %s.\nReason: %s\n%s'):format(banned_by, reason, expires_at and ('Expires at: %s'):format(os.date('%Y-%m-%d %H:%M:%S', expires_at)) or 'This ban is permanent.'))
    return true
end

exports('ban', function(source, target_id, banned_by, duration, reason)
    local player = player_registry[tonumber(target_id)]
    if not player then return false end
    return player:ban(banned_by, duration, reason)
end)