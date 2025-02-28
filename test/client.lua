local status_display = false
local status_display_thread = nil

--- Toggles the display of statuses, flags, and injuries on screen.
--- @param toggle boolean Whether to enable or disable the display.
function toggle_status_display(toggle)
    if toggle then
        status_display = true
        CreateThread(function()
            while status_display do
                Citizen.Wait(0)

                local statuses = get_player_data('statuses') or {}
                local flags = get_player_data('flags') or {}
                local injuries = get_player_data('injuries') or {}

                local draw_y = 0.05 -- Initial Y position for DrawText
                local draw_x = 0.01 -- X position for DrawText

                --- Helper function for drawing text on screen.
                --- @param text string The text to display
                --- @param x number The X coordinate
                --- @param y number The Y coordinate
                --- @param r number Red color value (default: 255)
                --- @param g number Green color value (default: 255)
                --- @param b number Blue color value (default: 255)
                --- @param a number Alpha value (default: 255)
                --- @param scale number Scale of the text (default: 0.35)
                local function draw_text(text, x, y, r, g, b, a, scale)
                    SetTextFont(4)
                    SetTextScale(scale or 0.35, scale or 0.35)
                    SetTextColour(r or 255, g or 255, b or 255, a or 255)
                    SetTextOutline()
                    SetTextEntry('STRING')
                    AddTextComponentString(text)
                    DrawText(x, y)
                end

                -- Display Statuses
                draw_text('Statuses:', draw_x, draw_y, 255, 0, 0) -- Red header for statuses
                draw_y = draw_y + 0.025
                for key, value in pairs(statuses) do
                    draw_text(key .. ': ' .. tostring(value), draw_x, draw_y)
                    draw_y = draw_y + 0.02
                end

                -- Display Flags
                draw_y = draw_y + 0.02 -- Add spacing before next section
                draw_text('Flags:', draw_x, draw_y, 255, 0, 0) -- Red header for flags
                draw_y = draw_y + 0.025
                for key, value in pairs(flags) do
                    draw_text(key .. ': ' .. (value and 'Yes' or 'No'), draw_x, draw_y)
                    draw_y = draw_y + 0.02
                end

                -- Display Injuries
                draw_y = draw_y + 0.02 -- Add spacing before next section
                draw_text('Injuries:', draw_x, draw_y, 255, 0, 0) -- Red header for injuries
                draw_y = draw_y + 0.025
                for key, value in pairs(injuries) do
                    draw_text(key .. ': ' .. tostring(value), draw_x, draw_y)
                    draw_y = draw_y + 0.02
                end
            end
        end)
    elseif not toggle then
        status_display = false
        status_display_thread = nil
    end
end

-- Command to toggle the status display
RegisterCommand('toggle_status_display', function()
    toggle_status_display(not status_display)
end, false)

-- Event for external toggle control
RegisterNetEvent('boii:cl:toggle_status_display')
AddEventHandler('boii:cl:toggle_status_display', function()
    toggle_status_display(not status_display)
end)
