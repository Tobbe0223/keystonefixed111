--[[
----------------------------------------------
 _  _________   ______ _____ ___  _   _ _____ 
| |/ / ____\ \ / / ___|_   _/ _ \| \ | | ____|
| ' /|  _|  \ V /\___ \ | || | | |  \| |  _|  
| . \| |___  | |  ___) || || |_| | |\  | |___ 
|_|\_\_____| |_| |____/ |_| \___/|_| \_|_____|
----------------------------------------------                                               
                Framework Core
                    V1.0.0              
----------------------------------------------

    Notes:

    Main configuration file for the framework core.
    This is stored server side and required sections are called back to the client on load.

    Everything is split into its own section, and all options are noted.
    It should be straight forward to follow. 
]]

config = config or {}

--- @section Debugging

--[[
    Notes: 

    Contains settings to handle debugging throughout the core.
    Currently only covers debug_prints, it will be expanded over time.
]]

config.debug_prints = true -- Enables/Disables debug prints for the core.

--- @section Routing Buckets

--[[
    Notes: 

    Routing buckets allow you to create separate 'instances' or 'mini-worlds' inside the main world.
    Players and entities inside a bucket can only interact with others in the same bucket unless explicitly moved.

    Whats the point though?
    - Making private lobbies or arenas where for some different game modes?
    - Event zones or mission areas isolated from the main world?
    - Staff only worlds for testing?
    - Whatever else you can think of really..
]] 

config.routing_buckets = {
    main = {
        label = 'Main World', -- Display name for the routing bucket.
        bucket = 0, -- Bucket ID (0 is the 'world' where everyone exists by default).
        mode = 'relaxed', -- Controls entity creation behavior ('strict', 'relaxed', or 'inactive').
        population_enabled = true, -- Enables or disables AI population (pedestrians, vehicles, etc.).
        player_cap = false, -- Maximum players allowed; false means no cap.
        staff_only = false, -- Restricts access to staff if set to a table of roles (e.g., { 'admin', 'mod' }).
        vip_only = false, -- Restricts access based on VIP level; false means open to everyone.
        spawn = vector4(-268.47, -956.98, 31.22, 208.54), -- Default spawn location for this bucket.
        respawn = vector4(341.28, -1396.83, 32.51, 48.78) -- Default respawn location for this bucket.
    }
}

--- @section New Characters

--[[
    Notes:

    Handles all default data for new characters.

    - Setup default roles and accounts, make sure to change these to whats applicable to your server idea or just drop them entirely if not needed.
    - Setup data for player inventory and starter items. Currently covers a section for a grid based inventory which is not yet complete, it will be asap.
]]

config.new_characters = {
    accounts = { -- Default accounts assigned to new characters, add or change accounts in `accounts.lua`.
        { 
            account_type = 'general', -- Account types are unique
            balance = 20000 -- Starting balance of the account
        },
        { account_type = 'savings', balance = 0 }, 
    },
    alignment = 500, -- Default alignment level for new characters
    roles = {
        {
            role_id = 'civilian', -- Unique ID for role.
            role_type = 'civ', -- Type of group.
            rank = 0, -- Default rank for the role.
            metadata = { -- Additional metadata if needed.
               -- on_duty = true -- Example: You could add a on_duty marker to be checked against later or whatever else.
            },
        },
    },
    inventory = {
        grid_columns = 10,
        grid_rows = 10,
        weight = 0, -- Starting weight.
        max_weight = 80000, -- Max weight player can carry.
        items = { -- Any items characters should start with.
            ['1'] = { id = 'cash', amount = 500, grid = { x = 0, y = 0 }, is_hotbar = true, hotbar_slot = 1 },
            ['2'] = { id = 'burger', amount = 5, grid = { x = 1, y = 0 }, is_hotbar = true, hotbar_slot = 2 },
            ['3'] = { id = 'water', amount = 5, grid = { x = 2, y = 0 }, is_hotbar = false, hotbar_slot = '' }
        }
    }
}

--- @section Character Customisation

--[[
    Notes:

    Default cam position is shared with multi-character and customisation location.

    near_dof + high_dof controls the depth of field to add a slight blur. 
]]

config.character_customisation = {
    multicharacter_ped_location = vector4(-1350.78, -1134.93, 20.93, 269.71), -- Default location for multicharacter ped.
    customisation_location = vector4(-705.47, -152.20, 36.40, 300.47), -- Default forced location for character customisation.
    customisation_camera_positions = { -- Default camera locations for character customisation.
        default_cam = {
            offset = vector3(0.55, 0.63, 0.50), -- Camera offset from 180 of players position.
            height_adjustment = 0, -- Additional height adjustment if required.
            near_dof = 0.5, -- Depth of field near distance (creates background blur).
            far_dof = 1.3 -- Depth of field far distance.
        },
        face_cam = { offset = vector3(0.0, 0.55, 0.60), height_adjustment = 0, near_dof = 0.4, far_dof = 1.3 },
        body_cam = { offset = vector3(0.0, 1.65, 0.15), height_adjustment = 0, near_dof = 0.7, far_dof = 1.9 },
        leg_cam = { offset = vector3(0.0, 0.85, -0.50), height_adjustment = 0, near_dof = 0.7, far_dof = 1.5 }
    }
}

--- @section Character Statuses

--[[
    Notes:

    Covers everything related to player statuses (hunger, thirst, stress, etc.).

    Have some plans to add additional stuff to the status system as time goes on however right now its basic.
]]

config.character_statuses = {
    reduction_interval = 5, -- Amount of time taken in minutes to reduce statuses.
    disable_globally = { -- Statuses listed here will be disabled throughout the core (hud, status updates etc..).
        -- 'hygiene', 'stress'
    },
    reductions = { -- Periodic status reductions: Remove a status from here to stop it being reduced each update.
        health = { min = 10, max = 20 }, -- Health is only reduced if hunger/thirst is 0.
        hunger = { min = 3, max = 10 }, 
        thirst = { min = 3, max = 10 },  
        stress = { min = 3, max = 10 },
        hygiene = { min = 3, max = 10 }
    }
}

--- @section Character Alignment

--[[
    Notes:

    Alignment is planned to be influenced throughout other resources.
    
    Some examples:
    - Modifying store prices. 
    - Refusing sales.
    - Increased xp gains
    - etc..
]]

config.character_alignment = {
    lawfulness_map = { -- Lawfulness thresholds and titles.
        { threshold = 0, title = 'Chaotic' }, 
        { threshold = 250, title = 'Rebel' },
        { threshold = 500, title = 'Neutral' }, 
        { threshold = 750, title = 'Social' }, 
        { threshold = 1000, title = 'Lawful' } 
    },
    morality_map = { -- Morality thresholds and titles.
        { threshold = 0, title = 'Evil' },
        { threshold = 250, title = 'Impure' },
        { threshold = 500, title = 'Neutral' },
        { threshold = 750, title = 'Moral' },
        { threshold = 1000, title = 'Good' } 
    },
    npc_influence = { -- Alignment system npc influence toggles.
        
    --- @todo: Just placeholder for now.. will implement at some point

        stores = { -- Store specific toggles.
            prices = true, -- If enabled, prices at stores will be adjusted depending on a players alignment.
            refusals = true -- If enabled, NPC storekeepers can refuse sales depending on alignment.
        }
    }
}

--- @section Inventory Actions

--[[
    Notes:

    Setup actions to be used by the inventory as default.
    
    Only use has been implemented fully so far, the rest are to come in updates.
]]

config.inventory_item_actions = { -- On hover actions for items; Define which actions can be used per item in `shared/data/items.lua`
    use = { 
        id = 'inventory_use_item', -- NUI Callback to trigger.
        key = 'F', -- Key to press.
        label = 'Use' -- Label for the key.
    },
    place = { id = 'inventory_place_item', key = 'P', label = 'Place' },
    drop = { id = 'inventory_drop_item', key = 'D', label = 'Drop' },
    destroy = { id = 'inventory_destroy_item', key = 'K', label = 'Destroy' },
    repair = { id = 'inventory_repair_item', key = 'R', label = 'Repair' },
    modify = { id = 'inventory_modify_item', key = 'M', label = 'Modify' },
    inspect = { id = 'inventory_inspect_item', key = 'I', label = 'Inspect' }
}