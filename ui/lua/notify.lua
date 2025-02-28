--- @section NUI Callbacks

--- Handles notifications from UI through utils bridge.
RegisterNUICallback('notify', function(data)
    NOTIFICATIONS.send({ type = data.type, header = data.header, message = data.message, duration = data.duration })
end)