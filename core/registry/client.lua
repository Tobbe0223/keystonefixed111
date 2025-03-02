player_data = {}

--- Retrieves player data.
--- @param source number: The players source ID.
--- @param category string|nil: The data category to retrieve (optional).
--- @return table|nil: The requested data category or the full player data if no category is specified.
function get_player_data(category)
    return category and player_data[category] or player_data
end

exports('get_player_data', get_player_data)

--- @section Events

--- Receives player data from server.
--- @param data table: Player data table.
RegisterNetEvent('keystone:cl:update_player_data', function(data)
    player_data = data
end)

--- Player joined event.
RegisterNetEvent('keystone:cl:player_joined')
AddEventHandler('keystone:cl:player_joined', function()
    debug_log('info', 'Player has joined client.')
    init_player()
end)

--- Player joined event.
RegisterNetEvent('keystone:cl:logout')
AddEventHandler('keystone:cl:logout', function()
    debug_log('info', 'Player has logged out.')
    NOTIFICATIONS.send({
        type = 'info',
        header = 'SYSTEM',
        message = 'You are being logged out..',
        duration = 3000
    })
    Wait(2000)
    DoScreenFadeOut(1000)
    SetTimeout(1000, function()
        disable_hud()
        setup_character_select()
        DoScreenFadeIn(1000)
    end)
end)

--- Spawns the player at a given location.
--- @param location table: A table containing 'x', 'y', 'z', and 'w' coordinates for the spawn point.
RegisterNetEvent('keystone:cl:spawn_player')
AddEventHandler('keystone:cl:spawn_player', function(location)
    SetNuiFocus(false, false)
    DoScreenFadeOut(2000)
    SetTimeout(2000, function()
        local ped = PlayerPedId()
        SetEntityCoords(ped, location.x, location.y, location.z, false, false, false, true)
        SetEntityHeading(ped, location.w)
        destroy_active_camera()
        DoScreenFadeIn(2000)
    end)
end)

--- Receives and stores shared data from the server.
--- @param data table: The data being received.
RegisterNetEvent('keystone:cl:receive_shared_data')
AddEventHandler('keystone:cl:receive_shared_data', function(data)
    keystone.data = data
end)

--- @section Initializaiton

--- Inits player on player joined.
function init_player()
    --- Static data
    TriggerServerEvent('keystone:sv:request_shared_data')
    TriggerServerEvent('keystone:sv:request_other_inventories')
    COMMANDS.get_chat_suggestions()

    --- Clothing Stores
    init_clothing_stores()

    --- Threads
    CreateThread(initilize_hud)
    CreateThread(init_statuses)
    CreateThread(game_world_disables)
end
