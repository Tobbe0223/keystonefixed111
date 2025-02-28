--- @section FiveM Utils Modules

--- UI Bridges.
--- Allows the core to make use of the notify and drawtext_ui bridges within utils.
NOTIFICATIONS = exports.fivem_utils:get_module('notifications')
DRAWTEXT = exports.fivem_utils:get_module('drawtext')

--- Core Modules.
--- The core does not use its own callbacks or commands system instead it uses utils.
CALLBACKS = exports.fivem_utils:get_module('callbacks')
COMMANDS = exports.fivem_utils:get_module('commands')

--- Character Customisation
--- Used by multichar + customisation location.
CHARACTER_CREATION = exports.fivem_utils:get_module('character_creation')

--- Styles Module.
--- Used by character customisation locations.
STYLES = exports.fivem_utils:get_module('styles')

-- Vehicles Module.
VEHICLES = exports.fivem_utils:get_module('vehicles')

--- General Utility.
KEYS = exports.fivem_utils:get_module('keys')
KEY_LIST = KEYS.get_keys()
TABLES = exports.fivem_utils:get_module('tables')
REQUESTS = exports.fivem_utils:get_module('requests')
CL_PLAYER = exports.fivem_utils:get_module('player')