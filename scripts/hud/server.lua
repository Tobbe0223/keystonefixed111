--- Stores vehicle mileages
GlobalState.vehicle_mileages = {}

--- Updates vehicle mileage by plate.
--- @param plate: Plate of vehicle to update.
--- @param mileage: New mileage value.
RegisterServerEvent('keystone:sv:update_vehicle_mileage', function(plate, mileage)
    local current_mileage = GlobalState.vehicle_mileages[plate] or 0
    if math.abs(current_mileage - mileage) >= 1 then
        GlobalState.vehicle_mileages[plate] = mileage
        TriggerClientEvent('keystone:cl:update_vehicle_mileage', -1, plate, mileage)
    end
end)

--- Request vehicle mileages from global state.
RegisterServerEvent('keystone:sv:request_vehicle_mileages', function()
    local src = source
    TriggerClientEvent('keystone:cl:update_vehicle_mileage', src, GlobalState.vehicle_mileages)
end)

--- Sync vehicle indicators.
--- @param indicator: The indicator being activated.
--- @param state: State of the indicator.
RegisterServerEvent('keystone:sv:sync_indicators', function(indicator, state)
    local src = source
    TriggerClientEvent('keystone:cl:update_indicators', -1, src, indicator, state)
end)