--- @section Variables

is_ui_open = false

--- @section Functions

--- Builds a UI based on given data.
--- @param data table: UI data, containing content, optional header, and optional footer.
function build_ui(data)
    if not data then debug_log('error', 'Error: data missing') return end
    local ui_data = data
    ui_data.action = 'build'
    SendNUIMessage(ui_data)
    SetNuiFocus(true, true)
end

exports('build_ui', build_ui)

--- @section Events

--- Builds the UI based on the data received from the server.
--- @param data table: Data for building the UI.
RegisterNetEvent('keystone:cl:build_ui')
AddEventHandler('keystone:cl:build_ui', function(data)
    if not data then debug_log('error', 'Error: data missing') return end
    build_ui(data)
end)

--- @section NUI Callbacks

--- Removes NUI focus when closing any UI.
--- @param data table: Data sent from the NUI.
--- @param cb function: Callback function to respond to the NUI.
RegisterNUICallback('close_ui', function(data, cb)
    SetNuiFocus(false, false)
    is_ui_open = false
    local vehicle_data = VEHICLES.get_vehicle_details(false)
    if vehicle_data and vehicle_data.plate and vehicle_data.distance and vehicle_data.distance <= 3.0 then
        local door_index = vehicle_data.is_rear_engine and 4 or 5
        SetVehicleDoorShut(vehicle_data.vehicle, door_index, false)
    end

    if data.dui_location_id then
        if dui_locations[data.dui_location_id] then
            dui_locations[data.dui_location_id].is_hidden = false
        end
        cleanup_character_creation()
    end

    cb({ status = 'success' })
end)

--- Handles player disconnection via the NUI.
RegisterNUICallback('disconnect', function()
    TriggerServerEvent('keystone:sv:disconnect')
end)

--- Toggles the ui builder state.
RegisterNetEvent('keystone:cl:toggle_ui_state', function(state)
    is_ui_open = state
end)
