local INCLUDE_STATUSES_IN_INVENTORY = true  
local INCLUDE_FLAGS_IN_INVENTORY = true  
local INCLUDE_INJURIES_IN_INVENTORY = true  
local INCLUDE_ACCOUNTS_IN_INVENTORY = true  
local INCLUDE_ROLES_IN_INVENTORY = true  

local INVENTORY_UI = {
    resource = GetCurrentResourceName(),
    header = {
        header_left = { image = '', info_1 = '', info_2 = '' },
        header_right = { flex_direction = 'row', options = {} },
    },
    footer = { actions = { { id = 'close_ui', key = 'ESCAPE', label = 'Exit' } } },
    content = {
        inventory = {
            type = 'inventory',
            player = { columns = 0, rows = 0, weight = 0, max_weight = 0, items = {} },
            other = nil,
        },
        statuses = nil,
        flags = nil,
        injuries = nil,
        accounts = nil,
        roles = nil
    },
}

local other_inventories = {}

--- @section Functions

--- Maps inventory items for UI representation.
--- @param inventory table: The inventory data containing items.
--- @return table: A formatted table of items ready for UI display.
local function map_inventory_items(inventory)
    local items = type(inventory.items) == 'table' and inventory.items or {}
    local formatted_items = {}
    for item_key, item in pairs(items) do
        local item_metadata = keystone.data.items[item.id]
        if not item_metadata then
            debug_log('error', ('Metadata not found for item ID: %s'):format(item.id))
        else
            local grid = item.grid or {}
            local x, y = grid.x or 0, grid.y or 0
            local width = item_metadata.grid and item_metadata.grid.width or 1
            local height = item_metadata.grid and item_metadata.grid.height or 1
            local total_weight = (item.amount or 1) * item_metadata.weight
            local weight_label = total_weight >= 1000 and string.format('%.2fkg', total_weight / 1000) or string.format('%dg', total_weight)
            local quality_or_durability = item.data and (item.data.quality or item.data.durability) or item_metadata.data and (item_metadata.data.quality or item_metadata.data.durability)
            local quality_or_durability_label = (item.data and item.data.quality or item_metadata.data and item_metadata.data.quality) and 'Quality' or 'Durability'
            local is_hotbar = item.is_hotbar or false
            local hotbar_slot = item.hotbar_slot or nil

            formatted_items[#formatted_items + 1] = {
                key = item_key,
                id = item.id,
                rarity = item_metadata.rarity and string.lower(item_metadata.rarity) or 'common',
                weight = item_metadata.weight,
                amount = item.amount or 0,
                stackable = item_metadata.stackable,
                quality = quality_or_durability,
                x = x,
                y = y,
                width = width,
                height = height,
                is_hotbar = is_hotbar,
                hotbar_slot = hotbar_slot,
                image = {
                    src = string.format('assets/images/items/%s', item_metadata.image or 'default_item.png'),
                    size = { width = 'auto', height = 'auto', border = 'transparent' }
                },
                on_hover = {
                    title = item_metadata.label or 'Unknown Item',
                    description = type(item_metadata.description) == 'table' and item_metadata.description 
                        or { item_metadata.description or 'No description available.' },
                    values = {
                        { key = 'Amount', value = item.amount },
                        { key = 'Weight', value = string.format('%d x %dg = %s', item.amount, item_metadata.weight, weight_label) }
                    },
                    actions = {}
                }
            }

            if item_metadata.rarity then
                formatted_items[#formatted_items].on_hover.values[#formatted_items[#formatted_items].on_hover.values + 1] = { 
                    key = 'Rarity', value = item_metadata.rarity 
                }
            end

            if quality_or_durability then
                formatted_items[#formatted_items].on_hover.values[#formatted_items[#formatted_items].on_hover.values + 1] = { 
                    key = quality_or_durability_label, value = quality_or_durability 
                }
            end

            if item_metadata.actions then
                for action, _ in pairs(item_metadata.actions) do
                    formatted_items[#formatted_items].on_hover.actions[#formatted_items[#formatted_items].on_hover.actions + 1] = {
                        id = config.inventory_item_actions[action] and config.inventory_item_actions[action].id or '',
                        key = config.inventory_item_actions[action] and config.inventory_item_actions[action].key or '',
                        label = config.inventory_item_actions[action] and config.inventory_item_actions[action].label or 'Action'
                    }
                end
            end
        end
    end
    return formatted_items
end

--- Maps inventory items for other inventories.
--- @param inventory table: The inventory data containing items.
--- @return table: A formatted table of items ready for UI display.
local function map_other_items(inventory)
    local items = type(inventory.items) == 'table' and inventory.items or {}
    local formatted_items = {}
    for item_key, item in pairs(items) do
        local item_metadata = keystone.data.items[item.id]
        if item_metadata then
            formatted_items[#formatted_items + 1] = {
                key = item_key,
                id = item.id,
                rarity = item_metadata.rarity and string.lower(item_metadata.rarity) or 'common',
                weight = item_metadata.weight,
                amount = item.amount or 0,
                stackable = item_metadata.stackable,
                x = item.grid and item.grid.x or 0,
                y = item.grid and item.grid.y or 0,
                width = item_metadata.grid and item_metadata.grid.width or 1,
                height = item_metadata.grid and item_metadata.grid.height or 1,
                image = {
                    src = string.format('assets/images/items/%s', item_metadata.image or 'test_item.png'),
                    size = { width = 'auto', height = 'auto', border = 'transparent' }
                }
            }
        end
    end
    return formatted_items
end


--- Maps account data for inventory UI display.
--- @param accounts table: The players accounts data.
--- @return table: A formatted table of account details.
local function map_account_data_for_inventory(accounts)
    if not accounts or type(accounts) ~= 'table' then return {} end
    local mapped_accounts = {}
    for account_type, account_data in pairs(accounts) do
        local shared_data = keystone.data.accounts[account_type] or {}
        if not shared_data then
            debug_log('error', ('No static data found for account type: %s'):format(account_type))
        else
            mapped_accounts[#mapped_accounts + 1] = {
                account_type = account_type,
                label = shared_data.label or account_type,
                balance = tonumber(account_data.balance) or 0,
                allow_negative = shared_data.allow_negative and true or false,
                interest_rate = shared_data.interest_rate or 0,
                interest_interval_hours = shared_data.interest_interval_hours or 0
            }
        end
    end
    return mapped_accounts
end

--- Maps role data for inventory UI display.
--- @param roles table: The players roles data.
--- @return table: A formatted table of role details.
local function map_roles_for_inventory(roles)
    if not roles or type(roles) ~= 'table' then return {} end
    local mapped_roles = {}
    for role_id, role_data in pairs(roles) do
        local shared_data = keystone.data.roles[role_id]
        if not shared_data then
            debug_log('error', ('No static data found for role ID: %s'):format(role_id))
        else
            local role_title = shared_data.label or role_id
            local grade_label = (shared_data.grades and shared_data.grades[role_data.grade] and shared_data.grades[role_data.grade].label) or 'Unspecified'
            local role_image = shared_data.image or 'https://placehold.co/64x64'
            local can_remove = shared_data.flags and shared_data.flags.can_remove ~= false
            mapped_roles[#mapped_roles + 1] = {
                title = role_title,
                layout = 'row',
                image = {
                    src = role_image,
                    size = { width = '64px', height = '64px', border = '2px solid rgba(0, 0, 0, 0.5);' }
                },
                on_hover = {
                    id = role_id,
                    title = role_title,
                    description = shared_data.description or { 'No description available.' },
                    values = {
                        { key = 'Role Type', value = shared_data.type or 'Unknown' },
                        { key = 'Grade', value = grade_label }
                    }
                }
            }
        end
    end
    return mapped_roles
end

--- Maps statuses into a formatted table for inventory UI.
--- @param statuses table: The players statuses.
--- @return table: A table with `columns` and `rows` keys.
local function map_statuses_for_inventory_as_table(statuses)
    if not statuses or type(statuses) ~= 'table' then return { columns = {}, rows = {} } end
    local mapped_statuses = { columns = { 'Status', 'Value' }, rows = {} }
    for key, value in pairs(statuses) do
        local formatted_key = key:sub(1, 1):upper() .. key:sub(2)
        mapped_statuses.rows[#mapped_statuses.rows + 1] = { formatted_key, value }
    end
    return mapped_statuses
end

--- Maps flags into a formatted table for inventory UI.
--- @param flags table: The players flags.
--- @return table: A table with `columns` and `rows` keys.
local function map_flags_for_inventory_as_table(flags)
    if not flags or type(flags) ~= 'table' then return { columns = {}, rows = {} } end
    local mapped_flags = { columns = { 'Flag', 'Value' }, rows = {} }
    for key, value in pairs(flags) do
        local formatted_key = key:gsub('^is_', ''):gsub('_', ' '):gsub("(%a)([%w_']*)", function(first, rest)
            return first:upper() .. rest
        end)
        mapped_flags.rows[#mapped_flags.rows + 1] = { formatted_key, value and 'Yes' or 'No' }
    end
    return mapped_flags
end

--- Maps injuries into a formatted table for inventory UI.
--- @param injuries table: The players injuries.
--- @return table: A table with `columns` and `rows` keys.
local function map_injuries_for_inventory_as_table(injuries)
    if not injuries or type(injuries) ~= 'table' then return { columns = {}, rows = {} } end
    local mapped_injuries = { columns = { 'Body Part', 'Injury Level' }, rows = {} }
    for key, value in pairs(injuries) do
        local formatted_key = key:gsub('_', ' '):gsub("(%a)([%w_']*)", function(first, rest)
            return first:upper() .. rest
        end)
        mapped_injuries.rows[#mapped_injuries.rows + 1] = { formatted_key, value }
    end
    return mapped_injuries
end

--- Retrieves an item from the players inventory by its ID, grid key, or metadata.
--- @param criteria string|number|table: The criteria to match the item.
--- @return table|nil: The matched item, or nil if not found.
local function get_item(criteria)
    local p_data = get_player_data()
    local items = p_data.inventory.items or {}
    local handlers = {
        ['string'] = function()
            for key, item in pairs(items) do
                if item.id == criteria then
                    return item
                end
            end
            return nil
        end,
        ['number'] = function()
            local key = tostring(criteria)
            local item = items[key]
            if item then
                return item
            end
            return nil
        end,
        ['table'] = function()
            for key, item in pairs(items) do
                local match = true
                for k, v in pairs(criteria) do
                    if not item.data or item.data[k] ~= v then
                        match = false
                        break
                    end
                end
                if match then
                    return item
                end
            end
            return nil
        end
    }
    local result = handlers[type(criteria)] and handlers[type(criteria)]() or nil
    if not result then
        debug_log('error', '[get_item] No item matched the given criteria.')
    end
    return result
end

--- @section NUI Callbacks

RegisterNUICallback('inventory_move_item', function(data)
    if not data or type(data) ~= 'table' then return end
    TriggerServerEvent('keystone:sv:inventory_move_item', data)
end)


-- NUI Callback for using an item from the inventory
RegisterNUICallback('inventory_use_item', function(data, cb)
    if not data or not data.key then
        NOTIFICATIONS.send({ type = 'error', header = 'Item Error', message = ('Invalid data. An item key must be provided. Data: %s'):format(json.encode(data)), duration = 3000 })
        return
    end
    local item = get_item(tonumber(data.key))
    if not item then
        NOTIFICATIONS.send({ type = 'error', header = 'Item Error', message = 'Item not found in the specified grid position.', duration = 3000 })
        return
    end
    local item_data = keystone.data.items[item.id]
    if not item_data or not item_data.actions or not item_data.actions.use then
        NOTIFICATIONS.send({ type = 'error', header = 'Item Error', message = ('The item "%s" is not usable.'):format(item.id), duration = 3000 })
        return
    end
    local usable_data = keystone.data.consumables[item.id]
    if not usable_data or usable_data.close_inventory ~= false then
        SetNuiFocus(false, false)
        SendNUIMessage({ action = 'close_ui' })
    end
    TriggerServerEvent('keystone:sv:trigger_usable_item', tonumber(data.key))
end)

--- @section Events 

--- Event handler to trigger an animation using the provided configuration.
RegisterNetEvent('keystone:cl:play_animation')
AddEventHandler('keystone:cl:play_animation', function(animation_config)
    if not (animation_config.dict and animation_config.anim) then 
        debug_log('error', '[Play Animation] Invalid or incomplete animation configuration received.')
        return
    end
    local function callback()
        if not animation_config.callback then debug_log('info', '[Play Animation] Animation completed, no callback specified.') return end
        local callback_type = animation_config.callback.type
        local callback_name = animation_config.callback.name
        local callback_params = animation_config.callback.params or {}
        local handlers = {
            server = function()
                TriggerServerEvent(callback_name, callback_params)
            end,
            client = function()
                TriggerEvent(callback_name, callback_params)
            end
        }
        if handlers[callback_type] then
            handlers[callback_type]()
        else
            debug_log('error', ('[Play Animation] Invalid or unsupported callback type "%s".').format(callback_type))
        end
    end
    CL_PLAYER.play_animation(PlayerPedId(), animation_config, callback)
end)

--- @section Open Inventory

function open_inventory(player_inventory, other_inventory, accounts, roles, statuses, flags, injuries)
    if not player_inventory or not player_inventory.items then debug_log('error', 'Error: Player inventory is missing or improperly structured.') return end
    local p_data = get_player_data()
    local identity_data = p_data.identity
    if not identity_data then debug_log('error', 'Error: Failed to retrieve player identity data.') return end
    
    INVENTORY_UI.header.header_left = {
        image = identity_data.profile_picture or 'assets/images/default_avatar.png',
        info_1 = string.format('%s %s %s', identity_data.first_name or '', identity_data.middle_name or '', identity_data.last_name or 'Unknown'),
        info_2 = p_data.identifier or 'Unknown ID'
    }

    INVENTORY_UI.header.header_right = {
        flex_direction = 'row',
        options = {
            { icon = 'fa-solid fa-user', value = GetPlayerServerId(PlayerId()) }
        }
    }

    INVENTORY_UI.content.inventory.player = {
        columns = player_inventory.grid_columns or 10,
        rows = player_inventory.grid_rows or 10,
        weight = player_inventory.weight or 0,
        max_weight = player_inventory.max_weight or 0,
        items = map_inventory_items(player_inventory)
    }

    INVENTORY_UI.content.inventory.other = other_inventory and {
        title = other_inventory.title or 'Other Inventory',
        columns = other_inventory.grid_columns or 10,
        rows = other_inventory.grid_rows or 10,
        weight = other_inventory.weight or 0,
        max_weight = other_inventory.max_weight or 0,
        items = other_inventory.items or {}
    } or nil

    -- Include Accounts
    if INCLUDE_ACCOUNTS_IN_INVENTORY and next(accounts) then
        local mapped_accounts = map_account_data_for_inventory(accounts)
        INVENTORY_UI.content.accounts = {
            type = 'cards',
            title = 'Accounts',
            layout = 'row',
            search = { placeholder = 'Search accounts by type...' },
            cards = {}
        }
        for index, account in ipairs(mapped_accounts) do
            INVENTORY_UI.content.accounts.cards[#INVENTORY_UI.content.accounts.cards + 1] = {
                title = string.format('%s Account', account.label),
                image = { src = 'https://placehold.co/64x64', size = { width = '64px', height = 'auto', border = '2px solid rgba(0,0,0,0.5)' } },
                description = string.format('Balance: $%.2f', account.balance),
                on_hover = {
                    title = string.format('%s Account', account.label),
                    account_type = account.account_type,
                    card_index = index,
                    values = {
                        { key = 'Balance', value = string.format('%.2f', account.balance) },
                        { key = 'Interest Rate', value = string.format('%.2f%%', account.interest_rate) },
                        { key = 'Allow Negative', value = account.allow_negative and 'Yes' or 'No' }
                    }
                }
            }
        end
    end

    -- Include Roles
    if INCLUDE_ROLES_IN_INVENTORY and next(roles) then
        INVENTORY_UI.content.roles = {
            type = 'cards',
            title = 'Roles',
            layout = 'row',
            search = { placeholder = 'Search roles...' },
            cards = map_roles_for_inventory(roles)
        }
    end

    -- Include Statuses
    if INCLUDE_STATUSES_IN_INVENTORY and next(statuses) then
        local status_table_data = map_statuses_for_inventory_as_table(statuses)
        INVENTORY_UI.content.statuses = {
            type = 'table',
            title = 'Statuses',
            columns = status_table_data.columns,
            rows = status_table_data.rows
        }
    end

    -- Include Flags
    if INCLUDE_FLAGS_IN_INVENTORY and next(flags) then
        local flags_table_data = map_flags_for_inventory_as_table(flags)
        INVENTORY_UI.content.flags = {
            type = 'table',
            title = 'Flags',
            columns = flags_table_data.columns,
            rows = flags_table_data.rows
        }
    end

    -- Include Injuries
    if INCLUDE_INJURIES_IN_INVENTORY and next(injuries) then
        local injuries_table_data = map_injuries_for_inventory_as_table(injuries)
        INVENTORY_UI.content.injuries = {
            type = 'table',
            title = 'Injuries',
            columns = injuries_table_data.columns,
            rows = injuries_table_data.rows
        }
    end

    build_ui(INVENTORY_UI)
end

--- @section Other Inventories

RegisterNetEvent('keystone:cl:receive_all_inventories')
AddEventHandler('keystone:cl:receive_all_inventories', function(inventories)
    if not inventories or type(inventories) ~= 'table' then return end
    other_inventories = inventories
    debug_log('success', ('[Inventory] Received %d other inventories from the server.'):format(#inventories))
end)


local function get_other_inventory()
    local player = PlayerPedId()
    local other_id = nil
    local inventory_type = nil
    if IsPedInAnyVehicle(player, false) then
        local vehicle_data = VEHICLES.get_vehicle_details(true)
        if vehicle_data and vehicle_data.plate then
            other_id = 'glovebox_' .. vehicle_data.plate
            inventory_type = 'glovebox'
        end
    end
    if not other_id then
        local vehicle_data = VEHICLES.get_vehicle_details(false)
        if vehicle_data and vehicle_data.plate and vehicle_data.distance and vehicle_data.distance <= 2.5 then
            other_id = 'trunk_' .. vehicle_data.plate
            inventory_type = 'trunk'
            local door_index = vehicle_data.is_rear_engine and 4 or 5
            SetVehicleDoorOpen(vehicle_data.vehicle, door_index, false, false)
        end
    end
    if not other_id or not other_inventories[other_id] then return nil end
    local inventory_data = other_inventories[other_id]
    return {
        title = string.format("%s Inventory", inventory_type:gsub("^%l", string.upper)),
        columns = inventory_data.grid_columns or 6,
        rows = inventory_data.grid_rows or 6,
        weight = inventory_data.weight or 0,
        max_weight = inventory_data.max_weight or 0,
        items = map_other_items(inventory_data)
    }
end

function init_other_inventories()
    TriggerServerEvent('keystone:sv:sync_other_inventories')
end

--- @section Keymapping

-- Register Command to Open Inventory
RegisterCommand('open_inventory', function()
    local p_data = get_player_data()
    local player_inventory = p_data.inventory or {}
    local other_inventory = get_other_inventory()
    local accounts = INCLUDE_ACCOUNTS_IN_INVENTORY and (p_data.accounts or {}) or {}
    local roles = INCLUDE_ROLES_IN_INVENTORY and (p_data.roles or {}) or {}
    local statuses = INCLUDE_STATUSES_IN_INVENTORY and (p_data.statuses or {}) or {}
    local flags = INCLUDE_FLAGS_IN_INVENTORY and (p_data.flags or {}) or {}
    local injuries = INCLUDE_INJURIES_IN_INVENTORY and (p_data.injuries or {}) or {}
    open_inventory(player_inventory, other_inventory, accounts, roles, statuses, flags, injuries)
    TriggerEvent('keystone:cl:toggle_ui_state', true)
end, false)

RegisterKeyMapping('open_inventory', 'Open Inventory', 'keyboard', 'TAB')