local locale = {}

local SELECTED_LANGUAGE <const> = GetConvar('locale', 'en-EN'):lower()
local LANGUAGE <const> = SELECTED_LANGUAGE:gsub('en%-', '')

--- Loads the locale file based on the server configured language.
if IS_SERVER then
    local function load_locale(language)
        local file_path = ('locales/%s.lua'):format(language)
        local file_content = LoadResourceFile(GetCurrentResourceName(), file_path)
        if not file_content then return load_locale('en') end
        local success, locale_table = pcall(function() return assert(load(file_content))() end)
        if not success or type(locale_table) ~= 'table' then return load_locale('en') end
        locale = locale_table
    end

    load_locale(LANGUAGE)
end

--- Retrieves a string from the loaded language file.
--- @param key string: String name for locale entry.
--- @param ... any: Optional arguments for string formatting.
--- @return string: The locale text.
function L(key, ...)
    return locale[key] and string.format(locale[key], ...) or key
end

exports('locale', L)