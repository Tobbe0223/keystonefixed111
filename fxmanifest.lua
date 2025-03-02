--[[
----------------------------------------------
 _  _________   ______ _____ ___  _   _ _____ 
| |/ / ____\ \ / / ___|_   _/ _ \| \ | | ____|
| ' /|  _|  \ V /\___ \ | || | | |  \| |  _|  
| . \| |___  | |  ___) || || |_| | |\  | |___ 
|_|\_\_____| |_| |____/ |_| \___/|_| \_|_____|
----------------------------------------------                                               
                Framework Core
                    V0.0.3              
----------------------------------------------
]]

fx_version 'cerulean'
games { 'gta5', 'rdr3' }

name 'keystone'
version '0.0.3'
description 'Keystone - Framework Core'
author 'keystone'
repository 'https://github.com/keystonehub/keystone'
lua54 'yes'

loadscreen 'ui/loadscreen.html' -- Comment out if not using default loading screen
loadscreen_manual_shutdown 'yes' -- Comment out if not using default loading screen

ui_page 'ui/index.html'
nui_callback_strict_mode 'true'

files {
    'ui/**/**/**',
    'stream/*' 
}

shared_script 'config.lua'
shared_script 'imports.lua'
shared_script 'init.lua'

--- Registry
client_script 'core/registry/client.lua'
server_script 'core/registry/server.lua'

client_scripts {
    --- Utils
    'utils/**/client.lua',

    --- UI
    'ui/lua/*.lua',

    --- Modules
    'core/modules/**/client.lua',

    --- Commands
    'core/commands/client.lua',

    --- Scripts
    'scripts/**/client.lua',

    --- Data
    'core/data/*',
    
    'test/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    
    --- Utils
    --'utils/**/server.lua',

    --- Classes
    'core/classes/*.lua',

    --- Modules
    'core/modules/**/server.lua',
    
    --- Commands
    'core/commands/server.lua',

    --- Scripts
    'scripts/**/server.lua',

    --- Data
    'core/data/*',

    'test/server.lua'
}

shared_scripts {
    --- Utils
    'utils/**/shared.lua',

    --- Scripts
    'scripts/**/shared.lua',
}

dependencies {
    'oxmysql',
    'fivem_utils'
}
