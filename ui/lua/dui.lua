--- @section Constants

local DUI_RANGE <const> = 1.5
local DUI_RANGE_SQUARED <const> = DUI_RANGE * DUI_RANGE

--- @section Native Localization

local GetActiveScreenResolution = GetActiveScreenResolution
local CreateDui = CreateDui
local CreateRuntimeTxd = CreateRuntimeTxd
local CreateRuntimeTextureFromDuiHandle = CreateRuntimeTextureFromDuiHandle
local GetDuiHandle = GetDuiHandle
local IsControlJustReleased = IsControlJustReleased
local TriggerEvent = TriggerEvent
local TriggerServerEvent = TriggerServerEvent
local SetDrawOrigin = SetDrawOrigin
local HasStreamedTextureDictLoaded = HasStreamedTextureDictLoaded
local DrawInteractiveSprite = DrawInteractiveSprite
local SendDuiMessage = SendDuiMessage
local DoesEntityExist = DoesEntityExist
local SetEntityDrawOutline = SetEntityDrawOutline
local SetEntityDrawOutlineColor = SetEntityDrawOutlineColor
local SetEntityDrawOutlineShader = SetEntityDrawOutlineShader
local Wait = Wait
local GetEntityCoords = GetEntityCoords
local ClearDrawOrigin = ClearDrawOrigin

--- @section Tables
dui_locations = {}

--- @section Functions

--- Creates a DUI object for a specified location.
--- @param location_id string: The unique ID of the location.
--- @return table: A table containing the DUI object and texture data.
local function create_dui(location_id)
    local txd_name, txt_name = location_id, location_id
    local dui_url = 'https://cfx-nui-' .. keystone.name .. '/ui/index.html'
    local screen_width, screen_height = GetActiveScreenResolution()
    local dui_object = CreateDui(dui_url, screen_width, screen_height)
    local txd = CreateRuntimeTxd(txd_name)
    CreateRuntimeTextureFromDuiHandle(txd, txt_name, GetDuiHandle(dui_object))
    return { dui_object = dui_object, txd_name = txd_name, txt_name = txt_name }
end

--- Adds a new zone to the DUI system.
--- @param options table: A table containing zone options.
function add_dui_zone(options)
    if not options.id or not options.coords or not options.header then return end
    local valid_keys = {}
    for _, key_data in ipairs(options.keys or {}) do
        local key_control = KEY_LIST[string.lower(key_data.key)]
        if key_control then
            key_data.key_control = key_control
            valid_keys[#valid_keys + 1] = key_data
        end
    end
    local entity = nil
    if options.entity and options.model then
        entity = GetClosestObjectOfType( options.coords.x, options.coords.y, options.coords.z, 1.0, GetHashKey(options.model), false, false, false)
    end
    dui_locations[options.id] = {
        image = options.image or nil,
        id = options.id,
        model = options.model,
        entity = entity or nil,
        coords = options.coords,
        header = options.header,
        icon = options.icon or '',
        keys = valid_keys,
        outline = options.outline,
        dui_object = create_dui(options.id),
        in_proximity = false,
        additional = options.additional or {}
    }
end

exports('add_dui_zone', add_dui_zone)

--- Removes a DUI zone by its ID.
--- @param id string: The unique ID of the zone to remove.
function remove_dui_zone(id)
    if not dui_locations[id] then return end
    dui_locations[id] = nil
end

exports('remove_dui_zone', remove_dui_zone)

--- Handles key press interactions for a location.
--- @param location table: The location table.
local function handle_key_presses(location)
    for i = 1, #location.keys do
        local key_data = location.keys[i]
        if IsControlJustReleased(0, key_data.key_control) then
            if key_data.action_type == 'client' then
                return TriggerEvent(key_data.action, location.id)
            end
            if key_data.action_type == 'server' then
                return TriggerServerEvent(key_data.action, location.id)
            end
        end
    end
end

--- Renders a single zones DUI.
--- @param location table: The location table.
--- @param player_coords vector3: The players coordinates.
local function render_dui(location, player_coords)
    if is_placing then return end
    local dui = location.dui_object
    if not dui then return end
    SetDrawOrigin(location.coords.x, location.coords.y, player_coords.z + 0.5)
    if HasStreamedTextureDictLoaded(dui.txd_name) then
        DrawInteractiveSprite(dui.txd_name, dui.txt_name, 0, 0, 0.8, 0.8, 0.0, 255, 255, 255, 255)
    end
    local new_message = json.encode({
        action = 'show_dui',
        options = {
            image = location.image or nil,
            header = location.header,
            model = location.model,
            icon = location.icon,
            keys = location.keys,
            outline = location.outline,
            additional = location.additional or {}
        }
    })
    if location.last_message ~= new_message then
        SendDuiMessage(dui.dui_object, new_message)
        location.last_message = new_message
    end
end

--- Syncs DUI updates from server with client UI.
--- @param id string: Zone ID.
--- @param updated_data table: The new data.
RegisterNetEvent('keystone:cl:sync_dui_data', function(id, updated_data)
    if not dui_locations[id] then return end
    for key, value in pairs(updated_data) do
        dui_locations[id][key] = value
    end
end)

--- Toggles an entitys outline visibility.
--- @param entity number: The entity ID.
--- @param state boolean: Whether to enable or disable the outline.
local function toggle_outline(entity, state)
    if not entity or not DoesEntityExist(entity) then return end
    SetEntityDrawOutline(entity, state)
    if state then
        SetEntityDrawOutlineColor(255, 255, 255, 255)
        SetEntityDrawOutlineShader(1)
    end
end

--- @section Threads

--- Handles rendering DUI.
local function dui_render_loop()
    while true do
        local player_coords = GetEntityCoords(PlayerPedId())
        local has_rendered = false
        for _, location in pairs(dui_locations) do
            if location.is_destroyed then 
                remove_zone(location.id)
            end
            if not location.is_destroyed and not location.is_hidden then
                local dx, dy, dz = player_coords.x - location.coords.x, player_coords.y - location.coords.y, player_coords.z - location.coords.z
                local distance_squared = dx * dx + dy * dy + dz * dz
                if distance_squared <= DUI_RANGE_SQUARED then
                    if not location.in_proximity then
                        location.in_proximity = true
                    end
                    render_dui(location, player_coords)
                    handle_key_presses(location)
                    has_rendered = true
                    if location.outline and location.entity then 
                        toggle_outline(location.entity, true) 
                    end
                elseif location.in_proximity then
                    location.in_proximity = false
                    if location.outline and location.entity then 
                        toggle_outline(location.entity, false) 
                    end
                end
            end
        end
        if has_rendered then 
            ClearDrawOrigin() 
        end
        Wait(0)
    end
end

--- Inits render loop.
SetTimeout(2000, function()
    CreateThread(dui_render_loop)
end)