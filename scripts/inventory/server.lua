local other_inventories = {}
local usable_items = {}
local player_using_item = {}

--- @section Functions

--- Registers an item as usable
--- @param item_id string: The unique identifier for the item.
--- @param use function: The function executed when the item is used.
local function register_item(item_id, use)
    if not item_id or type(use) ~= 'function' then debug_log('error', ('Invalid parameters: item_id is missing or use is not a function.'):format()) return end
    usable_items[item_id] = use
    debug_log('success', ('Item %s registered successfully.'):format(item_id))
end
exports('register_item', register_item)

--- Uses a registered item by invoking its callback function.
--- @param source number: The player using the item.
--- @param key number: The key of the item being used.
local function trigger_usable_item(source, key)
    local player = player_registry[source]
    if not player then debug_log('error', ('Player object missing for source %s.'):format(source)) return end
    local item = player.inventory:get_item(key)
    if not item then debug_log('error', ('No item found in key %s for source %s.'):format(key, source)) return end
    local use = usable_items[item.id]
    if not use then debug_log('error', ('Attempted to use unregistered item %s by source %s.'):format(item.id, source)) return end
    local success, err = pcall(use, source, key)
    if not success then debug_log('error', ('Error using item %s by source %s: %s').format(item.id, source, err)) end
end

--- Marks a player as using an item.
--- @param source number: The player or source ID.
--- @param item_id string: The item being used.
local function mark_item_usage(source, item_id)
    if player_using_item[source] then
        debug_log('error', ('[Item Usage] Player %s is already using an item.').format(source))
        return false
    end
    player_using_item[source] = item_id
    return true
end

--- Clears a players item usage state.
--- @param source number: The player or source ID.
local function clear_item_usage(source)
    player_using_item[source] = nil
end

--- Plays an animation on the client for the specified source.
--- @param source number: The player entity or source to play the animation on.
--- @param animation_config table: Configuration for the animation.
--- @param key number: The inventory key associated with the animation.
local function trigger_play_animation(source, animation_config, key)
    if not (animation_config and animation_config.anim) then return debug_log('error', '[Play Animation] No animation configuration or anim is missing.') end
    if key ~= nil and animation_config.callback then
        animation_config.callback.params = setmetatable({ key = key }, {__index = animation_config.callback.params})
    end
    TriggerClientEvent('keystone:cl:play_animation', source, animation_config)
end

--- Applies modifiers (statuses, flags, and injuries) to a player.
--- @param source number: The player source to apply the modifiers to.
--- @param modifiers table: Modifiers containing statuses, flags, and injuries.
local function apply_modifiers(source, modifiers)
    local player = player_registry[source]
    if not player then return debug_log('error', ('[Apply Modifiers] Player object missing for source %s.').format(source))  end
    local statuses = modifiers.statuses or {}
    local flags = modifiers.flags or {}
    local injuries = modifiers.injuries or {}
    if next(statuses) then
        player.statuses:set_statuses(statuses)
    end
    if next(flags) then
        player.flags:set_flags(flags)
    end
    if next(injuries) then
        player.injuries:set_injuries(injuries) 
    end
    clear_item_usage(source)
end

--- Uses an item if the player is not already using another item.
--- @param source number: The player using the item.
--- @param key number: The key of the item being used.
function use_item(source, key)
    local player = player_registry[source]
    if not player then debug_log('error', ('[Use Item] Player object missing for player %s.').format(source)) return end
    local item = player.inventory:get_item(key)
    if not item then clear_item_usage(source) return end
    if not mark_item_usage(source, item.id) then debug_log('error', ('[Use Item] Player %s attempted to use %s but is already using another item.').format(source, item.id)) return end
    local item_config = keystone.data.consumables[item.id]
    if not item_config then clear_item_usage(source) return end
    if item_config.animation and item_config.animation.dict and item_config.animation.anim then trigger_play_animation(source, item_config.animation, key) return end
    if item_config.modifiers then apply_modifiers(source, item_config.modifiers) end
    if item_config.remove then
        local amount = item_config.remove or 1
        player.inventory:remove_item(tonumber(key), amount)
        if item_config.notify and item_config.notify.success then
            NOTIFICATIONS.send(source, item_config.notify.success)
        end
    end
    clear_item_usage(source)
end

--- @section Events

--- Handles item movement.
RegisterServerEvent('keystone:sv:inventory_move_item')
AddEventHandler('keystone:sv:inventory_move_item', function(data)
    local src = source
    local player = player_registry[src]
    if not player then debug_log('error', L('player_missing', src)) return end

    -- Within player
    if data.source_inventory == 'player' and data.target_inventory == 'player' then
        local success = player.inventory:move_item(data.source_x, data.source_y, data.target_x, data.target_y)
        if not success then debug_log('error', L('item_move_failed')) return end
        return
    end

    local other_key

    -- Player to other
    if data.source_inventory == 'player' and data.target_inventory == 'other' then
        if data.plate then
            other_key = data.other_type .. "_" .. data.plate
        end
        local other_inv = other_inventories[other_key]
        local source_item = player.inventory:get_item({ grid_x = data.source_x, grid_y = data.source_y })
        if not source_item then debug_log('error', ('Error: Source item not found at (%d, %d)'):format(data.source_x, data.source_y)) return end
        add_item_to_other_inventory(other_key, source_item.id, source_item.amount, source_item.data, data.target_x, data.target_y)
        player.inventory:remove_item({ grid_x = data.source_x, grid_y = data.source_y }, source_item.amount)
        return
    end

    -- Other to player
    if data.source_inventory == 'other' and data.target_inventory == 'player' then
        if data.plate then
            other_key = data.other_type .. "_" .. data.plate
        end
        local other_inv = other_inventories[other_key]
        local item_to_move = get_item_from_other_inventory(other_inv, { grid_x = data.source_x, grid_y = data.source_y })
        if not item_to_move then debug_log('error', ('Error: Item not found in other inventory at position (%d, %d)'):format(data.source_x, data.source_y)) return end
        if not player.inventory:add_item(item_to_move.id, item_to_move.amount, item_to_move.data, data.target_x, data.target_y) then debug_log('error', 'Failed to transfer item to player inventory.') return end
        if not remove_item_from_other_inventory(other_inv, { grid_x = data.source_x, grid_y = data.source_y }, item_to_move.amount) then debug_log('error', 'Failed to remove item from other inventory after adding to player inventory.') return end
    end
    
    -- Within other
    if data.source_inventory == 'other' and data.target_inventory == 'other' then
        if data.plate then
            other_key = data.other_type .. "_" .. data.plate
        end
        local other_inv = other_inventories[other_key]
        if move_item_in_other_inventory(other_inv, data.source_x, data.source_y, data.target_x, data.target_y) then return end
        debug_log('error', 'Failed to move item within inventory.')
    end    
end)

--- Handles item usage requests from the client.
RegisterServerEvent('keystone:sv:trigger_usable_item')
AddEventHandler('keystone:sv:trigger_usable_item', function(key)
    local src = source
    if key == nil or type(key) ~= 'number' then debug_log('error', ('Invalid key received in keystone:sv:trigger_usable_item event from source %s.').format(src)) return end
    trigger_usable_item(src, key)
end)

--- Runs when consumables animation finishes.
RegisterServerEvent('keystone:sv:consumables_animation_finished')
AddEventHandler('keystone:sv:consumables_animation_finished', function(data)
    local src = source
    local key = tonumber(data.key)
    if not key then debug_log('error', ('Slot missing in data from source "%s".'):format(src)) return end
    local player = player_registry[source]
    if not player then debug_log('error', ('Missing player object for player "%s".'):format(src)) return end
    local item = player.inventory:get_item(key)
    if not item then clear_item_usage(src) return end
    if not player_using_item[src] or player_using_item[src] ~= item.id then debug_log('error', ('Unexpected animation completion for item "%s" by source "%s".'):format(item.id, src)) return end
    local item_config = keystone.data.consumables[item.id]
    if not item_config then
        if item_config and item_config.notify and item_config.notify.failed then
            NOTIFICATIONS.send(src, item_config.notify.failed)
        end
        clear_item_usage(src)
        return
    end
    if item_config.modifiers then apply_modifiers(src, item_config.modifiers) end
    if item_config.remove then
        local amount = item_config.remove or 1
        player.inventory:remove_item(key, amount)
        if item_config.notify and item_config.notify.success then
            NOTIFICATIONS.send(src, item_config.notify.success)
        end
    end
    clear_item_usage(src)
end)

--- @section Register Items

--- Registers all consumables as usable on load.
CreateThread(function()
    while not next(keystone.data.consumables) do
        Wait(1000)
    end
    local registered_items = {}
    for item_id, item_config in pairs(keystone.data.consumables) do
        if item_config then
            register_item(item_id, function(source, key)
                use_item(source, key)
            end)
            registered_items[#registered_items + 1] = item_id
        end
    end
    debug_log('success', 'All usable items have been registered.', { registered_items = registered_items })
    return
end)

--- @section Other Inventories

--- Loads other inventories.
--- Currently not fully implemented.
local function load_other_inventories()
    local result = MySQL.query.await('SELECT * FROM other_inventories')
    if not result or #result == 0 then return end
    for _, row in ipairs(result) do
        local key = row.inventory_type .. "_" .. row.unique_id
        other_inventories[key] = {
            owner = row.owner,
            inventory_type = row.inventory_type,
            grid_columns = row.grid_columns,
            grid_rows = row.grid_rows,
            weight = row.weight,
            max_weight = row.max_weight,
            items = json.decode(row.items) or {}
        }
    end
    debug_log('success', ('Loaded %d other inventories from the database.'):format(#result))
    TriggerClientEvent('keystone:cl:receive_all_inventories', -1, other_inventories)
end
load_other_inventories()

--- Gets an item from the other inventory by grid position.
--- @param inv table: The other inventory table.
--- @param criteria table: A table with grid_x and grid_y keys.
--- @return table|nil: The found item or nil if not found.
function get_item_from_other_inventory(inv, criteria)
    for key, item in pairs(inv.items) do
        if criteria.grid_x and criteria.grid_y and item.grid and 
           item.grid.x == criteria.grid_x and item.grid.y == criteria.grid_y then
            return item
        end
    end
    return nil
end

--- Moves an item within the same other inventory.
--- @param inv table: The other inventory table.
--- @param source_x number: Source grid X coordinate.
--- @param source_y number: Source grid Y coordinate.
--- @param target_x number: Target grid X coordinate.
--- @param target_y number: Target grid Y coordinate.
function move_item_in_other_inventory(inv, source_x, source_y, target_x, target_y)
    local source_key, target_key
    local items = inv.items
    for key, item in pairs(items) do
        if item.grid.x == source_x and item.grid.y == source_y then
            source_key = key
        end
        if item.grid.x == target_x and item.grid.y == target_y then
            target_key = key
        end
        if source_key and target_key then break end
    end
    if not source_key then
        debug_log('error', ('Error: Source item not found at position (%d, %d)'):format(source_x, source_y))
        return false
    end
    local item_to_move = items[source_key]
    if target_key then
        local target_item = items[target_key]
        if item_to_move.id == target_item.id and target_item.stackable then
            local max_stack = target_item.stackable == true and math.huge or target_item.stackable
            local total_qty = target_item.amount + item_to_move.amount
            target_item.amount = math.min(total_qty, max_stack)
            if total_qty > max_stack then
                item_to_move.amount = total_qty - max_stack
            else
                items[source_key] = nil
            end
        else
            items[source_key].grid.x, items[source_key].grid.y = target_x, target_y
            items[target_key].grid.x, items[target_key].grid.y = source_x, source_y
        end
    else
        items[source_key].grid.x = target_x
        items[source_key].grid.y = target_y
    end
    debug_log('info', ('Item moved or swapped within the inventory from (%d, %d) to (%d, %d)'):format(source_x, source_y, target_x, target_y))
    TriggerClientEvent('keystone:cl:receive_all_inventories', -1, other_inventories)
    return true
end

--- Removes an item from the other inventory by grid position.
--- @param inv table: The other inventory table.
--- @param criteria table: A table with grid_x and grid_y keys.
--- @param amount number: The amount to remove.
--- @return boolean: True if removal succeeded; false otherwise.
function remove_item_from_other_inventory(inv, criteria, amount)
    for key, item in pairs(inv.items) do
        if criteria.grid_x and criteria.grid_y and item.grid and 
           item.grid.x == criteria.grid_x and item.grid.y == criteria.grid_y then
            if item.amount >= amount then
                item.amount = item.amount - amount
                if item.amount <= 0 then inv.items[key] = nil end
                return true
            else
                return false
            end
        end
    end
    return false
end

--- Adds an item to the other inventory at the specified target coordinates.
--- @param inv_id string: The unique identifier for the inventory (e.g. 'trunk_05CYM680').
--- @param id string: The item ID.
--- @param amount number: The amount to add.
--- @param data table: Additional item data.
--- @param target_x number: Target grid X coordinate.
--- @param target_y number: Target grid Y coordinate.
--- @return boolean: True if the item was added successfully; false otherwise.
function add_item_to_other_inventory(inv_id, id, amount, data, target_x, target_y)
    if amount <= 0 then debug_log('info', 'No amount to add; skipping add_item_to_other_inventory for item ' .. id) return true end
    local inv = other_inventories[inv_id]
    if not inv then debug_log('error', 'Other inventory not found for id: ' .. tostring(inv_id)) return false end
    local item_data = keystone.data.items[id]
    if not item_data then debug_log('error', 'Item data not found for id: ' .. tostring(id)) return false end
    debug_log('info', 'Attempting to add item ' .. id .. ' x' .. amount .. ' to inventory ' .. inv_id .. ' at cell (' .. target_x .. ',' .. target_y .. ')')
    if item_data.stackable then
        for key, item in pairs(inv.items) do
            if item.id == id then
                local max_stack = (item_data.stackable == true) and math.huge or item_data.stackable
                local addable = math.min(amount, max_stack - item.amount)
                if addable > 0 then
                    debug_log('info', 'Merging ' .. addable .. ' of item ' .. id .. ' into existing stack.')
                    item.amount = item.amount + addable
                    amount = amount - addable
                    if amount <= 0 then
                        debug_log('info', 'All items merged successfully.')
                        TriggerClientEvent('keystone:cl:receive_all_inventories', -1, other_inventories)
                        return true
                    end
                end
            end
        end
    end
    while amount > 0 do
        local add_amount = 1
        if item_data.stackable then
            local max_stack = (item_data.stackable == true) and math.huge or item_data.stackable
            add_amount = math.min(amount, max_stack)
        end
        local next_key = 0
        for key, _ in pairs(inv.items) do
            local num = tonumber(key)
            if num and num > next_key then next_key = num end
        end
        local new_key = tostring(next_key + 1)
        debug_log('info', 'Creating new entry for item ' .. id .. ' x' .. add_amount .. ' at cell (' .. target_x .. ',' .. target_y .. ').')
        inv.items[new_key] = { id = id, amount = add_amount, grid = { x = target_x, y = target_y }, is_hotbar = false, hotbar_slot = '' }
        amount = amount - add_amount
    end
    TriggerClientEvent('keystone:cl:receive_all_inventories', -1, other_inventories)
    debug_log('info', 'Finished adding item ' .. id .. ' to inventory ' .. inv_id)
    return true
end

--- Retrieves (or creates) the vehicle inventory based on vehicle data and inventory type.
--- @param vehicle_data table: The vehicle details (must include plate, model, class, and inv_type).
--- @param inv_type string: The type of inventory ('glovebox' or 'trunk').
--- @return table|nil: The inventory table or nil if missing required data.
function get_vehicle_inventory(vehicle_data, inv_type)
    if not vehicle_data then debug_log('error', 'Vehicle data is missing.') return nil end
    if not inv_type then debug_log('error', 'Vehicle inventory type is missing.') return nil end
    local plate = vehicle_data.plate
    if not plate then debug_log('error', 'Vehicle plate is missing.') return nil end
    local defaults = get_vehicle_storage(vehicle_data.model, vehicle_data.class)
    local grid_defaults = (inv_type == 'glovebox') and defaults.glovebox.grid or defaults.trunk.grid
    local max_weight = (inv_type == 'glovebox') and defaults.glovebox.max_weight or defaults.trunk.max_weight
    local inv_key = inv_type .. "_" .. plate
    veh_inventory = other_inventories[inv_key]
    if not veh_inventory then
        veh_inventory = {
            title = inv_key,
            owner = nil,
            inventory_type = inv_type,
            grid_columns = grid_defaults.columns,
            grid_rows = grid_defaults.rows,
            weight = 0,
            max_weight = max_weight,
            items = {}
        }
        other_inventories[inv_key] = veh_inventory
        TriggerClientEvent('keystone:cl:receive_all_inventories', -1, other_inventories)
        debug_log('info', ('No other inventory found for %s creating new entry.'):format(inv_key))
    end
    return veh_inventory
end

--- Registers a callback to retrieve the vehicle inventory.
--- Expects data.vehicle_data and data.vehicle_data.inv_type.
CALLBACKS.register('keystone:sv:get_vehicle_inventory', function(source, data, cb)
    if not (data and data.vehicle_data) then debug_log('error', 'Vehicle data is missing in callback.') cb(false) return end
    local inv = get_vehicle_inventory(data.vehicle_data, data.vehicle_data.inv_type)
    if not inv then cb(false) return end
    cb(true, inv)
end)

--- Syncs other inventories with client.
RegisterServerEvent('keystone:sv:request_other_inventories')
AddEventHandler('keystone:sv:request_other_inventories', function()
    local source = source
    TriggerClientEvent('keystone:cl:receive_all_inventories', source, other_inventories)
end)
