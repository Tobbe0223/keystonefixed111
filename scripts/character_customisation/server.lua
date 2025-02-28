local character_functions = get_module('characters')

--- Server callback to handle saving character customization via NUI.
--- @param source number: The source player ID.
--- @param data table: The data required to save customization.
--- @param cb function: The callback function to return the result.
CALLBACKS.register('keystone:sv:save_character_customisation', function(source, data, cb)
    if not data or not data.style then
        debug_log('error', ('Invalid data received for character customization from source %s.'):format(source))
        return cb({ success = false, first_customisation = false, message = 'Invalid customization data provided.' })
    end
    local success, first_customisation = character_functions.save_character_customisation(source, data.style)
    if not success then
        cb({ success = false, first_customisation = false, message = 'Failed to save character customization.' })
        return
    end
    cb({ success = true, first_customisation = first_customisation })
end)