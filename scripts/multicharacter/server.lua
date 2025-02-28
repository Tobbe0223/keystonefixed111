local character_functions = get_module('characters')

--- @section Events

--- Event to handle playing a character.
--- @param char_id number: The ID of the character to be played.
RegisterServerEvent('keystone:sv:play_character', function(char_id)
    local src = source;
    local user = get_user(src)
    local unique_id = user.unique_id;
    create_player(src, unique_id, char_id)
end)

--- @section Callbacks

--- Server callback to fetch a players characters.
---@param source number: The players source ID.
---@param data table: Data passed from the client.
---@param cb function: The callback function to return data.
CALLBACKS.register('keystone:sv:fetch_characters', function(source, data, cb)
    local characters = character_functions.get_characters(source)
    if not characters or #characters == 0 then
        debug_log('warn', ('No characters found for source: %s'):format(source))
        return cb({ { title = 'No Characters Found' } })
    end
    cb(characters)
end)

--- Server callback to delete a character.
---@param source number: The source player ID.
---@param data table: The data containing the character ID to delete.
---@param cb function: The callback function to return the result.
CALLBACKS.register('keystone:sv:delete_character', function(source, data, cb)
    if not data or not data.char_id then
        debug_log('error', ('Invalid data received for character deletion from source %s.'):format(source))
        return cb({ success = false, message = 'Invalid character data provided.' })
    end
    local deleted = delete_character(source, data.char_id)
    cb({ success = deleted })
end)

--- Server callback to create a character.
---@param source number: The source player ID.
---@param data table: The character data sent from the client.
---@param cb function: The callback function to return the result.
CALLBACKS.register('keystone:sv:create_character', function(source, data, cb)
    if not data or not data.first_name or not data.last_name or not data.sex or not data.date_of_birth then
        return cb({ success = false, message = 'Invalid character data provided.' })
    end
    local user = get_user(source)
    if not user then
        return cb({ success = false, message = 'Failed to retrieve user data.' })
    end
    local char_data = character_functions.create_character({
        source = source,
        unique_id = user.unique_id,
        first_name = data.first_name,
        middle_name = data.middle_name or '',
        last_name = data.last_name,
        sex = data.sex,
        date_of_birth = data.date_of_birth,
        nationality = data.nationality or 'Unknown'
    })
    if not char_data then
        cb({ success = false, message = 'Character creation failed. Please try again later.' })
        return 
    end
    cb({ success = true })
end)
