--- @section Events

--- Syncs status updates.
--- @param data table: Statuses data table.
RegisterServerEvent('keystone:sv:sync_statuses')
AddEventHandler('keystone:sv:sync_statuses', function(data)
    local source = source
    local player = player_registry[source]
    if not player then return end
    local keys = {}
    for key in pairs(data) do
        keys[#keys + 1] = key
    end
    CreateThread(function()
        for i, key in ipairs(keys) do
            Wait(250 * i)
            local single_update = { [key] = data[key] }
            player.statuses:set_status(single_update)
            if key == 'health' and data.health and data.health.remove and player.statuses:get_status('health') <= 10 then
                player.statuses:down_player()
            end
        end
    end)
end)

--- Syncs injury updates.
--- @param data table: Injury data table.
RegisterServerEvent('keystone:sv:sync_injuries')
AddEventHandler('keystone:sv:sync_injuries', function(data)
    local source = source
    local player = player_registry[source]
    if not player then return end
    local success = player.injuries:set_injuries(data)
    if success then
        debug_log('info', ('[Injury] Updated injuries for player %s: %s'):format(source, json.encode(data)))
    else
        debug_log('error', ('[Injury] Failed to update injuries for player %s'):format(source))
    end
end)

--- @section Callbacks

--- Callback to respawn player.
--- @param source number: Players source id.
--- @param data table: Unused.
--- @param cb function: Callback function to trigger.
CALLBACKS.register('keystone:sv:respawn_player', function(source, data, cb)
    local player = player_registry[source]
    if not player then return cb(false) end
    if not player.flags:get_flag('is_dead') and not player.flags:get_flag('is_downed') then
        return cb(false)
    end
    player.statuses:respawn_player()
    cb(true)
end)

--- Callback to respawn player.
--- @param source number: Players source id.
--- @param data table: Unused.
--- @param cb function: Callback function to trigger.
CALLBACKS.register('keystone:sv:request_assistance', function(source, data, cb)
    local player = player_registry[source]
    if not player then return cb(false) end
    if not player.flags:get_flag('is_downed') or player.flags:get_flag('is_dead') then
        return cb(false)
    end
    debug_log('info', ('[Assistance] Player %s has requested medical assistance.'):format(source))
    cb(true)
end)

--- Callback to respawn player.
--- @param source number: Players source id.
--- @param data table: Unused.
--- @param cb function: Callback function to trigger.
CALLBACKS.register('keystone:sv:player_give_up', function(source, data, cb)
    local player = player_registry[source]
    if not player then return cb(false) end
    if not player.flags:get_flag('is_downed') or player.flags:get_flag('is_dead') then
        return cb(false)
    end
    player.flags:set_flags({ is_downed = false, is_dead = true })
    debug_log('info', ('Player %s has given up, they are now dead.'):format(source))
    Wait(2000)
    TriggerClientEvent('keystone:cl:player_died', source)
    cb(true)
end)