local player = {}

--- Saves all players.
--- Runs automatically on resource stop.
local function save_all_players()
    local players = get_players()
    for source in pairs(players) do
        local player = player_registry[source]
        if not player then debug_log('warn', ('No player object found for source %s. Skipping.'):format(source)) return end
        local ped = GetPlayerPed(source)
        if DoesEntityExist(ped) then
            local coords, heading = GetEntityCoords(ped), GetEntityHeading(ped)
            player:set_data('spawns', { last_location = { x = coords.x, y = coords.y, z = coords.z, w = heading } })
        end
        if player:save() then debug_log('success', ('Successfully saved player %s.'):format(player.identifier)) return end
        debug_log('error', ('Failed to save player %s!'):format(player.identifier))
    end
end

player.save_all_players = save_all_players
exports('save_all_players', save_all_players)

return player
