local player_functions = get_module('player')

--- Player registry
player_registry = {}

--- @section Get Functions

--- Retrieves the user object from fivem_utils for a given source.
--- @param source number: The players source ID.
--- @return table|nil: The user object containing unique_id and other user details.
function get_user(source)
    local user = exports.fivem_utils:get_user(source)
    if not user then
        debug_log('error', (L('no_user_found')):format(source))
        return nil
    end
    return user
end

keystone.get_user = get_user
exports('get_user', get_user)

--- Get all registered players.
--- @return table: A shallow copy of all connected players.
function get_players()
    return player_registry
end

keystone.get_players = get_players
exports('get_players', get_players)

--- Get a specific player.
--- @return table|nil: Player or nil.
function get_player(source)
    return player_registry[source] or nil
end

keystone.get_player = get_player
exports('get_player', get_player)

--- @section Create Player

--- Create a new player object and add it to the registry.
--- @param source number: The players source ID.
--- @param unique_id string: The players unique identifier.
--- @param char_id number: The players character ID.
--- @return table|nil: The created Player instance.
function create_player(source, unique_id, char_id)
    local player = Player.new(source, unique_id, char_id)
    if not player then return nil end
    if wait_for(function() return player.init and player:init() == true end, 5) then
        player_registry[source] = player
        TriggerEvent('keystone:sv:player_joined', source)
        return player
    end
    debug_log('error', ('Error: Player %s initialization timed out.'):format(source))
    return nil
end

keystone.create_player = create_player
exports('create_player', create_player)

--- @section Events

--- Player joined event.
--- @param source number: Players source id.
RegisterServerEvent('keystone:sv:player_joined')
AddEventHandler('keystone:sv:player_joined', function(source)
    local player = player_registry[source]
    if not player then  debug_log('error', ('Player object missing for %s.'):format(source))  return  end
    if not player._data.styles.has_customised then
        SetPlayerRoutingBucket(source, source + 1)
        TriggerClientEvent('keystone:cl:setup_character_customisation', source, config.character_customisation.customisation_location, {
            profile_picture = player._data.identity.profile_picture or 'https://placehold.co/64x64',
            name = ('%s %s %s'):format(player._data.identity.first_name, player._data.identity.middle_name or '', player._data.identity.last_name),
            identifier = player.identifier,
            source = player.source
        })
        TriggerClientEvent('keystone:cl:player_joined', source)
        return
    end
    SetPlayerRoutingBucket(source, config.routing_buckets.main.bucket)
    TriggerClientEvent('keystone:cl:spawn_player', source, player._data.spawns.last_location)
    TriggerClientEvent('keystone:cl:player_joined', source)
end)

--- Sends shared date to client on load.
RegisterNetEvent('keystone:sv:request_shared_data')
AddEventHandler('keystone:sv:request_shared_data', function()
    local src = source
    TriggerClientEvent('keystone:cl:receive_shared_data', src, keystone.data)
end)

--- @section Event Handlers

--- Saves player and updates last location on drop.
--- @param reason string: Reason they were dropped.
AddEventHandler('playerDropped', function(reason)
    local source = source
    local player = player_registry[source]
    if player then
        local coords = GetEntityCoords(GetPlayerPed(source))
        local heading = GetEntityHeading(GetPlayerPed(source))
        player:set_data('spawns', { last_location = { x = coords.x, y = coords.y, z = coords.z, w = heading } })
        player:save()
        player_registry[source] = nil
    end
end)

--- Saves all players on resource stop.
AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    player_functions.save_all_players()
    player_registry = {}
end)
