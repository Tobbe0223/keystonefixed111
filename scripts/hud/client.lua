--- @section Constants

local HUD_COMPONENTS <const> = { 1, 2, 3, 4, 7, 9, 13, 19, 20, 21, 22 }
local DISABLED_CONTROLS <const> = { 37 }
local DISABLE_AMMO <const> = true

--- @section Variables

local is_hud_focused = false 
local is_driving = false
local vehicle_mileages = {}
local radar_shown = false
local indicator_states = { -- Indicator states havent been implemented yet, want to redo the speedo entirely.
    left = false,
    right = false,
    hazards = false
}

--- @section Local Functions

--- Disable HUD components and controls.
local function disable_components()
    while true do
        for i = 1, #HUD_COMPONENTS do
            HideHudComponentThisFrame(HUD_COMPONENTS[i])
        end
        for i = 1, #DISABLED_CONTROLS do
            DisableControlAction(2, DISABLED_CONTROLS[i], true)
        end
        DisplayAmmoThisFrame(DISABLE_AMMO)
        Wait(0)
    end
end

--- Gets the distance to the current waypoint if set.
--- @param player: The players ped.
local function get_waypoint_distance(player)
    local waypoint = GetFirstBlipInfoId(8)
    if DoesBlipExist(waypoint) then
        local coords = GetBlipInfoIdCoord(waypoint)
        local player_coords = GetEntityCoords(player)
        local distance = #(player_coords - coords) / 1609.34
        return string.format('%.1f miles', distance)
    end
end

--- Update radar UI when the player is in a vehicle.
--- @param player: The players ped.
--- @param vehicle: The players vehicle.
local function update_radar_ui(player, player_vehicle)
    DisplayRadar(true)
    radar_shown = true
    local direction = CL_PLAYER.get_cardinal_direction(player_vehicle)
    local road_name = CL_PLAYER.get_street_name(player)
    local distance = get_waypoint_distance(player) or ''
    SendNUIMessage({
        action = 'update_map',
        direction = direction,
        road_name = road_name,
        distance = distance
    })
end

--- Hide radar UI when the player is not in a vehicle.
local function hide_radar_ui()
    DisplayRadar(false)
    radar_shown = false
    SendNUIMessage({ action = 'hide_map' })
end

--- Update vehicle mileage
--- @param vehicle_plate string: Plate for the vehicle.
--- @param speed number: Speed vehicle is traveling at.
--- @param dt number: Distance travelled. 
local function update_mileage(vehicle_plate, speed, dt)
    local vehicle_data = vehicle_mileages[vehicle_plate]
    if not vehicle_data then
        vehicle_mileages[vehicle_plate] = { mileage = 0, accumulated_distance = 0 }
        vehicle_data = vehicle_mileages[vehicle_plate]
    end
    local distance_traveled = speed * (dt / 3600)
    vehicle_data.accumulated_distance = vehicle_data.accumulated_distance + distance_traveled
    if vehicle_data.accumulated_distance >= 1.0 then
        local miles = math.floor(vehicle_data.accumulated_distance)
        vehicle_data.mileage = vehicle_data.mileage + miles
        vehicle_data.accumulated_distance = vehicle_data.accumulated_distance - miles
    end
end

--- Updates speedo whilst driving.
--- @param speed_unit string: String name for speed type mph or kph
--- @param player_vehicle: The vehicle the player is driving
local function update_speedo(speed_unit, player_vehicle)
    if not is_driving then return end
    local speed_mps = GetEntitySpeed(player_vehicle)
    local vehicle_plate = GetVehicleNumberPlateText(player_vehicle)
    if not vehicle_mileages[vehicle_plate] then vehicle_mileages[vehicle_plate] = { mileage = 0, accumulated_distance = 0 } end
    local speed = speed_mps * (speed_unit == 'mph' and 2.23694 or 3.6)
    update_mileage(vehicle_plate, speed, 1)
    local rpm = GetVehicleCurrentRpm(player_vehicle) * 100
    local gear = GetVehicleCurrentGear(player_vehicle)
    local engine_health = GetVehicleEngineHealth(player_vehicle) / 10
    local body_health = GetVehicleBodyHealth(player_vehicle) / 10
    local fuel_level = GetVehicleFuelLevel(player_vehicle)
    local formatted_mileage = string.format('%06d', vehicle_mileages[vehicle_plate].mileage)
    SendNUIMessage({
        action = 'update_speedo',
        speed = math.floor(speed),
        rpm = rpm,
        gear = gear,
        engine_health = engine_health,
        body_health = body_health,
        fuel = fuel_level,
        mileage = formatted_mileage
    })
end

--- Updates a players injury status.
--- @param area string: String name of the body part to apply injury.
--- @param value: Amount of injury to apply to area.
local function set_injury(area, value)
    SendNUIMessage({
        action = 'set_injury',
        area = area,
        value = value
    })
end

--- Update hud.
local function update_hud()
    while true do
        local player = PlayerPedId()
        local player_vehicle = GetVehiclePedIsIn(player, false)
        local is_driver = player_vehicle ~= 0 and GetPedInVehicleSeat(player_vehicle, -1) == player
        local show_radar = is_driver and not is_ui_open
        if show_radar then
            update_radar_ui(player, player_vehicle)
            is_driving = true
            if is_driving then
                update_speedo('mph', player_vehicle)
            end
        elseif (not show_radar and radar_shown) or is_ui_open then
            hide_radar_ui()
            is_driving = false
        end
        Wait(250)
    end
end

--- Initialize the minimap.
local function init_map()
    DisplayRadar(false)
    radar_shown = false
    Wait(150)
    local default_aspect_ratio = 1920 / 1080
    local res_x, res_y = GetActiveScreenResolution()
    local aspect_ratio = res_x / res_y
    local map_offset = 0
    if aspect_ratio > default_aspect_ratio then
        map_offset = ((default_aspect_ratio - aspect_ratio) / 3.6) - 0.008
    end
    local minimap_width = 0.200
    local minimap_height = minimap_width * res_x / res_y
    REQUESTS.texture('map', false)
    SetMinimapClipType(0)
    AddReplaceTexture('platform:/textures/graphics', 'radarmasksm', 'map', 'radarmasksm')
    AddReplaceTexture('platform:/textures/graphics', 'radarmask1g', 'map', 'radarmasksm')
    SetMinimapComponentPosition('minimap', 'R', 'T', -0.008 + map_offset, 0.025, minimap_width / 1.715, minimap_height / 1.715)
    SetMinimapComponentPosition('minimap_mask', 'R', 'T', -0.015 + map_offset, 0.0650, minimap_width, minimap_height)
    SetMinimapComponentPosition('minimap_blur', 'R', 'T', 0.065 + map_offset, -0.035, minimap_width, minimap_height)
    SetBlipAlpha(GetNorthRadarBlip(), 0)
    SetBigmapActive(true, false)
    SetMinimapClipType(0)
    Wait(50)
    SetBigmapActive(false, false)
    local minimap = RequestScaleformMovie('minimap')
    BeginScaleformMovieMethod(minimap, 'HIDE_SATNAV')
    EndScaleformMovieMethod()
    CreateThread(disable_components)
end

--- Initialize hud.
function init_hud()
    local p_data = TABLES.deep_copy(player_data)
    p_data.statuses.health = p_data.statuses.health / 2
    SendNUIMessage({
        action = 'init_hud',
        player_data = p_data,
        disabled_statuses = {}
    })
    CreateThread(update_hud)
end

--- Inits hud on load; triggered by player_joined event.
function initilize_hud()
    SetTimeout(1500, function()
        init_map()
        init_hud()
    end)
end

--- Disables hud; triggered when logging out.
function disable_hud()
    SendNUIMessage({ action = 'close_hud' })
    DisplayRadar(false)
    radar_shown = false
end

--- @section Events

--- Updates vehicle mileages.
--- @param plate: Plate of the vehicle
--- @param mileage: Current vehicle mileage
RegisterNetEvent('keystone:cl:update_vehicle_mileage', function(plate, mileage)
    if vehicle_mileages[plate] then
        vehicle_mileages[plate].mileage = mileage
    end
end)

--- Updates a players injury status
--- @param body_part: The name of the body part to update.
--- @param value: Value to apply as injury status.
RegisterNetEvent('keystone:cl:update_injury_status', function(area, value)
    set_injury(body_part, is_injured)
end)

--- Updates vehicle indicators.
--- @param src: Source player received from server
--- @param indicator: The indicator to update
--- @param state: The state for the indicator
RegisterNetEvent('keystone:cl:update_indicators', function(src, indicator, state)
    local player_ped = GetPlayerPed(GetPlayerFromServerId(src))
    if not DoesEntityExist(player_ped) then debug_log('error', 'Player ped does not exist for source: ', src) return end
    local player_vehicle = GetVehiclePedIsIn(player_ped, false)
    if not DoesEntityExist(player_vehicle) then debug_log('error', 'Player vehicle does not exist for source: ', src) return end
    local indicators = { left_indicator = 1, right_indicator = 0, hazards = {0, 1} }
    local lights = indicators[indicator]
    if type(lights) == 'table' then
        for _, lightIndex in ipairs(lights) do
            SetVehicleIndicatorLights(player_vehicle, lightIndex, state)
        end
    else
        SetVehicleIndicatorLights(player_vehicle, lights, state)
    end
end)

--- @section Keymapping

RegisterCommand('left_indicator', function()
    local player = PlayerPedId()
    local player_vehicle = GetVehiclePedIsIn(player, false)
    if player_vehicle ~= 0 and GetPedInVehicleSeat(player_vehicle, -1) == player then
        indicator_states.left = not indicator_states.left
        TriggerServerEvent('keystone:sv:sync_indicators', 'left_indicator', indicator_states.left)
        SendNUIMessage({ 
            action = 'update_indicator',
            indicator = 'left_indicator',
            colour = indicator_states.left and 'orange' or 'white',
            animation = indicator_states.left and 'flash 0.8s infinite' or 'none'
        })
    end
end, false)
RegisterKeyMapping('left_indicator', 'Toggle Left Indicator', 'keyboard', 'B')

RegisterCommand('right_indicator', function()
    local player = PlayerPedId()
    local player_vehicle = GetVehiclePedIsIn(player, false)
    if player_vehicle ~= 0 and GetPedInVehicleSeat(player_vehicle, -1) == player then
        indicator_states.right = not indicator_states.right
        TriggerServerEvent('keystone:sv:sync_indicators', 'right_indicator', indicator_states.right)
        SendNUIMessage({ 
            action = 'update_indicator',
            indicator = 'right_indicator',
            colour = indicator_states.right and 'orange' or 'white',
            animation = indicator_states.right and 'flash 0.8s infinite' or 'none'
        })
    end
end, false)
RegisterKeyMapping('right_indicator', 'Toggle Right Indicator', 'keyboard', 'N')

RegisterCommand('hazards', function()
    local player = PlayerPedId()
    local player_vehicle = GetVehiclePedIsIn(player, false)
    if player_vehicle ~= 0 and GetPedInVehicleSeat(player_vehicle, -1) == player then
        indicator_states.hazards = not indicator_states.hazards
        TriggerServerEvent('keystone:sv:sync_indicators', 'hazards', indicator_states.hazards)
        SendNUIMessage({ 
            action = 'update_indicator',
            indicator = 'left_indicator',
            colour = indicator_states.hazards and 'orange' or 'white',
            animation = indicator_states.hazards and 'flash 0.8s infinite' or 'none'
        })
        SendNUIMessage({ 
            action = 'update_indicator',
            indicator = 'right_indicator',
            colour = indicator_states.hazards and 'orange' or 'white',
            animation = indicator_states.hazards and 'flash 0.8s infinite' or 'none'
        })
    end
end, false)
RegisterKeyMapping('hazards', 'Toggle Hazard Lights', 'keyboard', 'M')

RegisterCommand('toggle_engine', function()
    local player = PlayerPedId()
    local player_vehicle = GetVehiclePedIsIn(player, false)
    if player_vehicle ~= 0 and GetPedInVehicleSeat(player_vehicle, -1) == player then
        local engine_status = GetIsVehicleEngineRunning(player_vehicle)
        SetVehicleEngineOn(player_vehicle, not engine_status, false, true)
        SendNUIMessage({ 
        action = 'update_indicator',
        indicator = 'engine_state',
        colour = engine_status and '#1f1e1e' or 'orange'
    })
    end
end, false)
RegisterKeyMapping('toggle_engine', 'Toggle Engine On/Off', 'keyboard', 'Y')

--- @section Testing

--- Test command to init hud if needed.
RegisterCommand('test_player_hud', function()
    init_hud()
end)
