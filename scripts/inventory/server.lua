local other_inventories = {}
local usable_items = {}
local player_using_item = {}

--- @section Functions

--- Registers an item as usable
--- @param item_id string: The unique identifier for the item.
--- @param use function: The function executed when the item is used.
local function register_item(item_id, use)
    if not item_id or type(use) ~= 'function' then debug_log('error', ('[Inventory] Invalid parameters: item_id is missing or use is not a function.'):format()) return end
    usable_items[item_id] = use
    debug_log('success', ('[Inventory] Item %s registered successfully.'):format(item_id))
end
exports('register_item', register_item)

--- Uses a registered item by invoking its callback function.
--- @param source number: The player using the item.
--- @param key number: The key of the item being used.
local function trigger_usable_item(source, key)
    local player = player_registry[source]
    if not player then debug_log('error', ('[Inventory] Player object missing for source %s.'):format(source)) return end
    local item = player.inventory:get_item(key)
    if not item then debug_log('error', ('[Inventory] No item found in key %s for source %s.'):format(key, source)) return end
    local use = usable_items[item.id]
    if not use then debug_log('error', ('[Inventory] Attempted to use unregistered item %s by source %s.'):format(item.id, source)) return end
    local success, err = pcall(use, source, key)
    if not success then debug_log('error', ('[Inventory] Error using item %s by source %s: %s').format(item.id, source, err)) end
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

RegisterServerEvent('keystone:sv:inventory_move_item')
AddEventHandler('keystone:sv:inventory_move_item', function(data)
    local source = source
    local player = player_registry[source]
    
    print("[Inventory Move] Event Triggered | Source:", source)
    
    if not player then 
        print("[Inventory Move] Player not found in registry!")
        return 
    end

    local is_source_player = data.source_inventory == 'player'
    local is_target_player = data.target_inventory == 'player'
    local same_inventory = data.source_inventory == data.target_inventory

    print(("[Inventory Move] Source Inventory: %s | Target Inventory: %s | Same Inventory: %s"):format(
        data.source_inventory, data.target_inventory, tostring(same_inventory)
    ))

    if not same_inventory and not (is_source_player or is_target_player) then 
        print("[Inventory Move] Invalid inventory movement: Source and Target are not player inventories.")
        return 
    end

    local source_inv = is_source_player and player.inventory or other_inventories[data.source_inventory]
    local target_inv = is_target_player and player.inventory or other_inventories[data.target_inventory]

    if not source_inv then 
        print("[Inventory Move] Source inventory not found! Inventory ID:", data.source_inventory)
        return 
    end
    if not target_inv then 
        print("[Inventory Move] Target inventory not found! Inventory ID:", data.target_inventory)
        return 
    end

    local item_key, item_to_move = source_inv:get_item(data.source_x, data.source_y)
    if not item_key or not item_to_move then 
        print("[Inventory Move] Item not found at given position: ", data.source_x, data.source_y)
        return 
    end

    print(("[Inventory Move] Moving Item: %s | Amount: %d | From (%d, %d) to (%d, %d)"):format(
        item_to_move.id, item_to_move.amount, data.source_x, data.source_y, data.target_x, data.target_y
    ))

    if same_inventory then
        print("[Inventory Move] Moving item within the same inventory.")
        source_inv:move_item(data.source_x, data.source_y, data.target_x, data.target_y)
        return
    end

    print("[Inventory Move] Removing item from source inventory...")
    local success = source_inv:remove_item(item_key, item_to_move.amount)
    if not success then 
        print("[Inventory Move] Failed to remove item from source inventory.")
        return 
    end

    print("[Inventory Move] Adding item to target inventory...")
    success = target_inv:add_item(item_to_move.id, item_to_move.amount, item_to_move.data, data.target_x, data.target_y)
    if not success then
        print("[Inventory Move] Failed to add item to target inventory. Returning item to source...")
        source_inv:add_item(item_to_move.id, item_to_move.amount, item_to_move.data, data.source_x, data.source_y)
        return
    end

    if is_source_player or is_target_player then 
        print("[Inventory Move] Syncing player data...")
        player:sync_data() 
    end

    if not is_source_player then
        print("[Inventory Move] Updating source inventory in database...")
        MySQL.update('UPDATE other_inventories SET items = ? WHERE unique_id = ?', {
            json.encode(source_inv:get_inventory().items),
            data.source_inventory
        })
    end
    if not is_target_player then
        print("[Inventory Move] Updating target inventory in database...")
        MySQL.update('UPDATE other_inventories SET items = ? WHERE unique_id = ?', {
            json.encode(target_inv:get_inventory().items),
            data.target_inventory
        })
    end

    print("[Inventory Move] Item move successful!")
end)

--- Handles item usage requests from the client.
RegisterServerEvent('keystone:sv:trigger_usable_item')
AddEventHandler('keystone:sv:trigger_usable_item', function(key)
    local src = source
    if key == nil or type(key) ~= 'number' then debug_log('error', ('[Inventory] Invalid key received in keystone:sv:trigger_usable_item event from source %s.').format(src)) return end
    trigger_usable_item(src, key)
end)

--- Runs when consumables animation finishes.
RegisterServerEvent('keystone:sv:consumables_animation_finished')
AddEventHandler('keystone:sv:consumables_animation_finished', function(data)
    local src = source
    local key = tonumber(data.key)
    if not key then debug_log('error', ('[Animation Finished] Slot missing in data from source '%s'.'):format(src)) return end
    local player = player_registry[source]
    if not player then debug_log('error', ('[Animation Finished] Missing player object for player '%s'.'):format(src)) return end
    local item = player.inventory:get_item(key)
    if not item then clear_item_usage(src) return end
    if not player_using_item[src] or player_using_item[src] ~= item.id then debug_log('error', ('[Animation Finished] Unexpected animation completion for item '%s' by source '%s'.'):format(item.id, src)) return end
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
    debug_log('success', '[Item Registry] All usable items have been registered.', { registered_items = registered_items })
    return
end)

--- @section Other Inventories

--- Loads other inventories. 
--- Currently not fully implemented.
local function load_other_inventories()
    local result = MySQL.query.await('SELECT * FROM other_inventories')
    if not result or #result == 0 then return end
    for _, row in ipairs(result) do
        other_inventories[row.unique_id] = {
            owner = row.owner,
            inventory_type = row.inventory_type,
            grid_columns = row.grid_columns,
            grid_rows = row.grid_rows,
            weight = row.weight,
            max_weight = row.max_weight,
            items = json.decode(row.items) or {}
        }
    end
    debug_log('success', ('[Inventory] Loaded %d other inventories from the database.'):format(#result))
    TriggerClientEvent('keystone:cl:receive_all_inventories', -1, other_inventories)
end
load_other_inventories()

--- Syncs other inventories with client.
RegisterNetEvent('keystone:sv:sync_other_inventories')
AddEventHandler('keystone:sv:sync_other_inventories', function()
    local source = source
    TriggerClientEvent('keystone:cl:receive_all_inventories', source, other_inventories)
end)