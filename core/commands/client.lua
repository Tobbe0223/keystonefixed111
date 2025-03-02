--- @section Events

--- Handles copy to clipboard.
RegisterNetEvent('keystone:cl:copy_to_clipboard')
AddEventHandler('keystone:cl:copy_to_clipboard', function(data)
    SendNUIMessage({ action = 'copy_to_clipboard', content = data })
    NOTIFICATIONS.send({ type = 'success', header = 'Clipboard', message = 'Coordinates copied to clipboard!', duration = 3000 })
end)
