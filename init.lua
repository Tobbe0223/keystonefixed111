--- Utility loader for module and class management
--- This script initializes and manages the loading of modules and classes.

--- @section Constants

local RESOURCE_NAME <const> = GetCurrentResourceName()
local IS_SERVER <const> = IsDuplicityVersion()

--- @section Localised Natives

local GetLocalTime = GetLocalTime

--- Debug note levels and colour.
local DEBUG_COLOURS = {
    reset = '^7', -- White (default)
    debug = '^6', -- Violet
    info = '^5', -- Cyan
    success = '^2', -- Green
    warn = '^3', -- Yellow
    error = '^8' -- Red 
}

--- @section Keystone Object

keystone = {
    name = RESOURCE_NAME,
    context = IS_SERVER and 'server' or 'client',
    classes = {}, -- Stores all loaded classes
    modules = {}, -- Stores all loaded modules
    data = {} -- Stores all loaded data
}

--- @section Utility Functions

--- Get the current time for logging.
--- @return string: The formatted current time in 'YYYY-MM-DD HH:MM:SS' format.
local function get_current_time()
    if IS_SERVER then
        return os.date('%Y-%m-%d %H:%M:%S')
    elseif GetLocalTime then
        local year, month, day, hour, minute, second = GetLocalTime()
        return string.format('%04d-%02d-%02d %02d:%02d:%02d', year, month, day, hour, minute, second)
    end
    return "0000-00-00 00:00:00"
end

exports('get_current_time', get_current_time)
keystone.get_current_time = get_current_time

--- Logs debug messages with levels and optional data.
--- @param level string: The log level ('debug', 'info', 'success', 'warn', 'error').
--- @param message string: The message to log.
--- @param data table|nil: Optional data to include in the log.
function debug_log(level, message, data)
    if not config.debug_prints then return end
    local resource_name = GetInvokingResource() or 'KEYSTONE'
    if resource_name == 'mapmanager' then return end 

    print(('%s[%s] [%s] [%s]: %s%s'):format(DEBUG_COLOURS[level] or '^7', get_current_time(), resource_name:upper(), level:upper(), DEBUG_COLOURS.reset or '^7', message), data and json.encode(data) or '')
end

keystone.debug_log = debug_log
exports('debug_log', debug_log)

--- @section Class & Module Loading

--- Load a class and cache it.
--- @param class_name string: The name of the class to load.
--- @return boolean: True if the class was loaded, false otherwise.
local function load_class(class_name)
    if keystone.classes[class_name] then debug_log('info', ('Class already cached: %s'):format(class_name)) return true end
    local path = ('core/classes/%s.lua'):format(class_name)
    local content = LoadResourceFile(keystone.name, path)
    if not content then debug_log('error', ('Class not found: %s'):format(class_name)) return false end
    local fn, err = load(content, ('@@%s/%s.lua'):format(keystone.name, class_name), 't', _G)
    if not fn then debug_log('error', ('Error loading class (%s): %s'):format(class_name, err)) return false end
    fn()
    if not _G[class_name] then debug_log('error', ('Class (%s) did not define itself correctly.'):format(class_name)) return false end
    keystone.classes[class_name] = _G[class_name]
    debug_log('success', ('Class loaded: %s'):format(class_name))
    return true
end

--- Load a module and cache it.
--- @param module_name string: The name of the module to load.
--- @return table|nil: The loaded module or nil if loading fails.
local function load_module(module_name)
    if keystone.modules[module_name] then debug_log('info', ('Module already cached: %s'):format(module_name)) return keystone.modules[module_name] end
    local path = ('core/modules/%s/%s.lua'):format(module_name, keystone.context)
    local content = LoadResourceFile(keystone.name, path)
    if not content then  debug_log('error', ('Module not found: %s'):format(module_name)) return nil end
    local fn, err = load(content, ('@@%s/%s.lua'):format(keystone.name, module_name), 't', _G)
    if not fn then  debug_log('error', ('Error loading module (%s): %s'):format(module_name, err)) return nil end
    local result = fn()
    if type(result) ~= 'table' then  debug_log('error', ('Module (%s) did not return a table.'):format(module_name)) return nil end
    keystone.modules[module_name] = result
    debug_log('success', ('Module loaded: %s'):format(module_name))
    return result
end

--- Load a specific data module.
--- @param name string: The name of the data file (without extension).
--- @return table|nil: The loaded data module or nil if loading fails.
local function load_data(name)
    if keystone.data[name] then return keystone.data[name] end
    local path = ('core/data/%s.lua'):format(name)
    local content = LoadResourceFile(RESOURCE_NAME, path)
    if not content then debug_log('error', (L('resource_file_missing')):format(path)) return nil end
    local fn, err = load(content, ('@@%s/%s'):format(RESOURCE_NAME, path), 't', _G)
    if not fn then debug_log('error', (L('error_loading_resource_file')):format(path, err)) return nil end
    keystone.data[name] = fn()
    debug_log('success', ('Data loaded: %s'):format(name))
    return keystone.data[name]
end

--- @section Preloading Functions

--- Loads classes.
local function load_classes()
    for _, name in ipairs({ 'Accounts', 'Effects', 'Flags', 'Identity', 'Injuries', 'Inventory', 'Roles', 'Statuses', 'Styles', 'Player' }) do
        load_class(name)
    end
end

--- Loads modules if required.
local function load_modules()
    for _, name in ipairs({ 'accounts', 'characters', 'player' }) do
        load_module(name)
    end
end

--- Loads all shared data.
local function load_shared()
    for _, name in ipairs({ 'accounts', 'consumables', 'effects', 'items', 'roles', 'spawns', 'vehicles' }) do
        load_data(name)
    end
end

--- Inits the core.
local function init()
    load_classes()
    load_modules()
    load_shared()
end

if IS_SERVER then
    AddEventHandler('onResourceStart', init)
end

--- @section Get Exports

--- Get shared data.
--- @param category string: The string category to get.
function get_shared_data(category)
    return keystone.data[category] or load_data(name)
end

keystone.get_shared_data = get_shared_data
exports('get_shared_data', get_shared_data)

--- Retrieve or load a core module dynamically.
--- @param core_name string: The name of the module to retrieve.
--- @return table|nil: The requested module or nil if it couldnt be loaded.
local function get_core()
    return TABLES.deep_copy(keystone)
end

exports('get_core', get_core)
keystone.get_core = get_core

--- Retrieve all loaded modules.
--- @return table: The keystone table containing loaded modules.
function get_modules()
    return TABLES.deep_copy(keystone.modules)
end

exports('get_modules', get_modules)
keystone.get_modules = get_modules

--- Retrieve a specific module.
--- @param module_name string: The name of the module to retrieve.
--- @return table|nil: The requested module or nil if not found.
function get_module(module_name)
    return keystone.modules[module_name] or load_module(module_name)
end

exports('get_module', get_module)
keystone.get_module = get_module

--- Retrieve all loaded classes.
--- @return table: The keystone table containing loaded classes.
function get_classes()
    return keystone.classes
end

exports('get_classes', get_classes)
keystone.get_classes = get_classes

--- Retrieve a specific class.
--- @param class_name string: The name of the class to retrieve.
--- @return table|nil: The requested class or nil if not found.
function get_class(class_name)
    return keystone.classes[class_name] or load_class(class_name)
end

exports('get_class', get_class)
keystone.get_class = get_class
