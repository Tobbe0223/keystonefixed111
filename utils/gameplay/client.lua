--- @section Functions

--- Disables the usual stuff throughout the game world.
--- Will add to this later.
function game_world_disables()
    while true do
        local player_id = PlayerId()
        local ped = PlayerPedId()

        -- Disables wanted levels and police interactions.
        ClearPlayerWantedLevel(player_id)
        SetPlayerWantedLevel(player_id, 0, false)
        SetPlayerWantedLevelNow(player_id, false)
        SetPoliceIgnorePlayer(ped, true)
        SetDispatchCopsForPlayer(ped, false)

        Wait(3000)
    end
end