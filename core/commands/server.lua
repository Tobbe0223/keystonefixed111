--- @section Public

-- Displays the players server ID
COMMANDS.register('id', { 'member', 'mod', 'admin', 'dev', 'owner' }, 'Check your current server ID.', {}, function(source, args, raw)
    NOTIFICATIONS.send(source, { type = 'info', header = 'Server ID', message = ('Your server ID is %d'):format(source), duration = 5000 })
end)

-- Logs the player out of their current character
COMMANDS.register('logout', { 'member', 'mod', 'admin', 'dev', 'owner' }, 'Logout of your current character.', {}, function(source, args, raw)
    NOTIFICATIONS.send(source, { type = 'info', header = 'SYSTEM', message = 'Logging out, and returning to character selection.', duration = 2500 })
    SetTimeout(2000, function()
        local player = player_registry[source]
        if player then
            player:logout()
        end
    end)
end)

--- @section Staff

-- Command to spawn a vehicle
COMMANDS.register('vehicle', { 'mod', 'admin', 'dev', 'owner' }, 'Spawn a vehicle at your location and place you inside.', {
    { name = 'model', help = 'Vehicle model name or hash.' }
}, function(source, args)
    local model = args[1]
    if not model then
        NOTIFICATIONS.send(source, { type = 'error', header = 'Commands', message = 'Usage: /vehicle [model].', duration = 3500 })
        return
    end
    TriggerEvent('keystone:sv:spawn_vehicle', source, model)
end)

-- Command to delete the vehicle the player is in or the nearest vehicle
COMMANDS.register('dv', { 'mod', 'admin', 'dev', 'owner' }, 'Delete the vehicle you are in or the nearest one.', {}, function(source)
    TriggerEvent('keystone:sv:delete_vehicle', source)
end)

-- Command to give an item to the player
COMMANDS.register('additem', { 'mod', 'admin', 'dev', 'owner' }, 'Give someone an item.', {
    { name = 'target_id', help = 'The source ID of the player.' },
    { name = 'item_id', help = 'The ID of the item to give.' },
    { name = 'amount', help = 'The amount of the item to give.' }
}, function(source, args)
    local target_id, item_id, amount = args[1], args[2], tonumber(args[3]) or 1
    if not item_id then NOTIFICATIONS.send(source, { type = 'error', header = 'SYSTEM', message = 'Usage: /additem [target_id] [item_id] [amount].', duration = 3500 }) return end
    local player = player_registry[source]
    if not player then NOTIFICATIONS.send(source, { type = 'error', header = 'SYSTEM', message = 'Player not found.', duration = 3500 }) return end
    local success = player.inventory:add_item(item_id, amount)
    if not success then
        NOTIFICATIONS.send(source, { type = 'error', header = 'SYSTEM', message = 'Failed to add item to inventory.', duration = 3500 })
        return
    end
    NOTIFICATIONS.send(source, { type = 'success', header = 'SYSTEM', message = ('You received %dx %s.'):format(amount, item_id), duration = 5000 })
end)

-- Command to remove an item from the player
COMMANDS.register('removeitem', { 'mod', 'admin', 'dev', 'owner' }, 'Remove an item from someone.', {
    { name = 'target_id', help = 'The source ID of the player.' },
    { name = 'item_id', help = 'The ID of the item to remove.' },
    { name = 'amount', help = 'The amount of the item to remove.' }
}, function(source, args)
    local target_id, item_id, amount = args[1], args[2], tonumber(args[3]) or 1
    if not item_id then NOTIFICATIONS.send(source, { type = 'error', header = 'SYSTEM', message = 'Usage: /removeitem [target_id] [item_id] [amount].', duration = 3500 }) return end
    local player = player_registry[source]
    if not player then NOTIFICATIONS.send(source, { type = 'error', header = 'SYSTEM', message = 'Player not found.', duration = 3500 }) return end
    local success = player.inventory:remove_item(item_id, amount)
    if not success then
        NOTIFICATIONS.send(source, { type = 'error', header = 'SYSTEM', message = 'Failed to remove item from inventory.', duration = 3500 })
        return
    end
    NOTIFICATIONS.send(source, { type = 'success', header = 'SYSTEM', message = ('Successfully removed %dx %s.'):format(amount, item_id), duration = 5000 })
end)

-- Command to give an item to the player
COMMANDS.register('revive', { 'mod', 'admin', 'dev', 'owner' }, 'Revive a player or self.', {
    { name = 'target_id', help = 'The source ID of the player.' }
}, function(source, args)
    local target_id = args[1] or source
    local player = player_registry[target_id]
    if not player then NOTIFICATIONS.send(source, { type = 'error', header = 'SYSTEM', message = 'Player not found.', duration = 3500 }) return end
    local success = player.statuses:revive_player()
    if not success then
        NOTIFICATIONS.send(source, { type = 'error', header = 'SYSTEM', message = 'Failed to revive player.', duration = 3500 })
        return
    end
    NOTIFICATIONS.send(source, { type = 'success', header = 'SYSTEM', message = ('You revived %s.'):format(source), duration = 5000 })
end)

--- @section Events

--- Event to spawn a vehicle at the players location and place them inside
--- @param source number: Players source ID.
--- @param model string: Vehicle model name.
RegisterServerEvent('keystone:sv:spawn_vehicle', function(source, model)
    if not model or model == '' then  NOTIFICATIONS.send(source, { type = 'error', header = 'Vehicle Spawn', message = 'Invalid vehicle model.', duration = 3500 }) return end
    local vehicle_data = keystone.data.vehicles
    local veh_data = vehicle_data and vehicle_data[model:lower()]
    local vehicle_type, label = veh_data and veh_data.type or nil, veh_data and veh_data.label or model
    if not vehicle_type then debug_log('error', ('[Spawn Vehicle] Model not found in shared VEHICLES list: %s, attempting normal spawn.'):format(model)) end
    local player_ped = GetPlayerPed(source)
    local coords = GetEntityCoords(player_ped)
    local heading = GetEntityHeading(player_ped)
    local model_hash = GetHashKey(model)
    local vehicle = CreateVehicleServerSetter(model_hash, vehicle_type or 'automobile', coords.x, coords.y, coords.z, heading)
    if not DoesEntityExist(vehicle) then  NOTIFICATIONS.send(source, { type = 'error', header = 'Vehicle Spawn', message = 'Failed to create vehicle.', duration = 3500 }) return end
    Wait(200)
    SetPedIntoVehicle(player_ped, vehicle, -1)
    NOTIFICATIONS.send(source, { type = 'success', header = 'Vehicle Spawn', message = ('Vehicle %s spawned successfully.'):format(label), duration = 5000 })
end)

--- Deletes a vehicle.
--- @param source number: Players source ID.
RegisterNetEvent('keystone:sv:delete_vehicle', function(source)
    local player_ped = GetPlayerPed(source)
    local vehicle = GetVehiclePedIsIn(player_ped, false)
    if vehicle and DoesEntityExist(vehicle) then
        local model = GetEntityModel(vehicle)
        DeleteEntity(vehicle)
        NOTIFICATIONS.send(source, { type = 'success', header = 'Delete Vehicle', message = 'Vehicle deleted successfully.', duration = 5000 })
        return
    end
    NOTIFICATIONS.send(source, { type = 'error', header = 'Delete Vehicle', message = 'No vehicle found to delete.', duration = 3500 })
end)
