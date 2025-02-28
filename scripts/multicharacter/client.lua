--- @section Constants

local MULTICHARACTER_PED_LOCATION = config.character_customisation.multicharacter_ped_location

--- @section Variables

local load_screen = false
local first_load = false
local is_multichar_active = false
current_sex = 'm'
preview_ped = 'mp_m_freemode_01'


--- @section Multicharacter UI

--- @todo move stuff into config values and locales

local MULTICHARACTER_UI = {
    resource = GetCurrentResourceName(),
    header = {
        header_left = {
            image = 'assets/images/key_logo100x.jpg',
            info_1 = 'Keystone',
            info_2 = 'FiveM Framework'
        },
        header_right = {
            flex_direction = 'row',
            options = { { icon = 'fa-solid fa-user', value = 1 } }
        }
    },
    footer = {
        actions = {
            {
                id = 'disconnect',
                key = 'ESCAPE',
                label = 'Disconnect',
                modal = {
                    title = 'Confirm Disconnect',
                    description = 'Are you sure you want to disconnect from the server?',
                    on_confirm = { action = 'disconnect' },
                    on_cancel = {
                        type = 'info',
                        header = 'Disconnect Cancelled',
                        message = 'You are no longer disconnecting.',
                        duration = 3000
                    }
                }
            }
        }
    },
    content = {
        characters = {
            type = 'cards',
            title = 'Characters',
            layout = 'row',
            search = { placeholder = 'Search characters by name...' },
            cards = {}
        },
        create_character = {
            id = 'create_character',
            type = 'form',
            title = 'Character Identity',
            fields = {
                { id = 'first_name', type = 'text', label = 'First Name', placeholder = 'Enter first name...', required = true },
                { id = 'middle_name', type = 'text', label = 'Middle Name', placeholder = 'Enter middle name...', required = false },
                { id = 'last_name', type = 'text', label = 'Last Name', placeholder = 'Enter last name...', required = true },
                { id = 'dob', type = 'date', label = 'Date of Birth', required = true },
                { id = 'sex', type = 'select', label = 'Sex', options = { 'm', 'f' }, required = true },
                { id = 'nationality', type = 'select', label = 'Nationality', options = {}, required = true }
            }
        }
    }
}

--- Sets up the character creation environment.
function setup_character_select()
    is_multichar_active = true
    SetNuiFocus(true, true)
    DisplayRadar(false)
    CALLBACKS.trigger('keystone:sv:fetch_characters', nil, function(characters)
        if not characters or type(characters) ~= 'table' then debug_log('error', 'Error: Invalid character data format.') return end
        local selected_character = characters[1] or nil
        current_sex = selected_character and selected_character.data and selected_character.identity and selected_character.identity.sex or 'm'
        preview_ped = current_sex == 'm' and 'mp_m_freemode_01' or 'mp_f_freemode_01'
        local model = GetHashKey(preview_ped)
        if not IsModelValid(model) then debug_log('error', 'Error: Invalid model.') return end
        REQUESTS.model(model)
        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)
        local appearance = selected_character and selected_character.style or STYLES.get_style(current_sex)
        if appearance then
            CHARACTER_CREATION.set_ped_appearance(PlayerPedId(), appearance)
        else
            debug_log('error', 'Error: Failed to retrieve appearance.')
        end
        local ped = PlayerPedId()
        SetEntityCoords(ped, MULTICHARACTER_PED_LOCATION.x, MULTICHARACTER_PED_LOCATION.y, MULTICHARACTER_PED_LOCATION.z, false, false, false, true)
        SetEntityHeading(ped, MULTICHARACTER_PED_LOCATION.w + 25.0)
        Wait(100)
        setup_camera(MULTICHARACTER_PED_LOCATION.w, 'default_cam')
        SetEntityHeading(ped, MULTICHARACTER_PED_LOCATION.w - 25.0)
        local updated_ui = MULTICHARACTER_UI
        updated_ui.content.characters.cards = {}
        if #characters > 0 then
            for _, character in ipairs(characters) do
                updated_ui.content.characters.cards[#updated_ui.content.characters.cards + 1] = {
                    image = {
                        src = character.profile_picture or 'assets/images/avatar_placeholder.jpg',
                        size = { width = '64px', height = '64px', border = '2px solid rgba(0, 0, 0, 0.5);' },
                        is_profile_picture = true
                    },
                    title = character.title or 'Unknown Character',
                    layout = 'row',
                    on_hover = {
                        char_id = character.char_id,
                        title = character.title or 'Unknown Character',
                        description = character.description or { 'No description available.' },
                        values = character.values or {},
                        actions = {
                            { id = 'play_character', key = 'P', label = 'Play' },
                            { id = 'view_character', key = 'G', label = 'View' },
                            {
                                id = 'delete_character',
                                key = 'Z',
                                label = 'Delete',
                                modal = {
                                    title = 'Confirm Deletion',
                                    description = string.format('Are you sure you want to delete %s?', character.title),
                                    on_confirm = { action = 'delete_character' },
                                    on_cancel = {
                                        type = 'info',
                                        header = 'Delete Cancelled',
                                        message = 'Character delete has been cancelled.',
                                        duration = 3000
                                    }
                                }
                            }
                        }
                    }
                }
            end
        else
            updated_ui.content.characters.cards[#updated_ui.content.characters.cards + 1] = {
                title = 'No Characters Found',
                layout = 'row',
                image = {
                    src = 'assets/images/avatar_placeholder.jpg',
                    size = { width = '3vw', height = '3vw', border = '2px solid rgba(0, 0, 0, 0.5);' }
                },
                on_hover = nil
            }
        end
        build_ui(updated_ui)
    end)
end

--- NUI Callback for creating a character.
RegisterNUICallback('create_character', function(data, cb)
    if not data then debug_log('error', 'Error: No data provided for character creation.') return end
    data.style = STYLES.get_style(current_sex)
    data.date_of_birth = ('%d-%d-%d'):format(data.dob_dd, data.dob_mm, data.dob_yyyy)
    CALLBACKS.trigger('keystone:sv:create_character', data, function(response)
        if response.success then
            NOTIFICATIONS.send({
                type = 'success',
                header = 'Character Created',
                message = ('Character %s %s %s created successfully.'):format(data.first_name, data.middle_name or '', data.last_name),
                duration = 3500
            })
            TriggerEvent('keystone:cl:reset_character_ui')
        else
            NOTIFICATIONS.send({
                type = 'error',
                header = 'Character Creation Failed',
                message = response.message or 'An error occurred during character creation.',
                duration = 3500
            })
        end
    end)
end)

--- NUI Callback for deleting a character
RegisterNUICallback('delete_character', function(data, cb)
    if not data then debug_log('error', 'Error: No data provided for character deletion.') return end
    CALLBACKS.trigger('keystone:sv:delete_character', { char_id = data.char_id }, function(response)
        if response.success then
            NOTIFICATIONS.send({
                type = 'success',
                header = 'Character Deleted',
                message = ('Character %s deleted successfully.'):format(data.title),
                duration = 3500
            })
            TriggerEvent('keystone:cl:reset_character_ui')
        else
            NOTIFICATIONS.send({
                type = 'error',
                header = 'Character Delete Failed',
                message = response.message or 'An error occurred during character deletion.',
                duration = 3500
            })
        end
    end)
end)

--- NUI Callback to trigger play event.
RegisterNUICallback('play_character', function(data, cb)
    if not data or not data.char_id then debug_log('error', 'Error: Invalid data received for play_character:', json.encode(data)) return end
    TriggerServerEvent('keystone:sv:play_character', data.char_id)
    SendNUIMessage({ action = 'close_ui' })
end)

--- @section Events

--- Resets the character creation environment
RegisterNetEvent('keystone:cl:reset_character_ui')
AddEventHandler('keystone:cl:reset_character_ui', function()
    SendNUIMessage({ action = 'close_ui' })
    DoScreenFadeOut(1000)
    SetTimeout(1000, function()
        SetTimeout(1000, function()
            DoScreenFadeIn(1000)
            setup_character_select()
        end)
    end)
end)

--- @section Event Handlers

--- Setups multichar on client map start.
AddEventHandler('onClientMapStart', function()
    if not load_screen and not first_load then
        ShutdownLoadingScreenNui()
        ShutdownLoadingScreen()
        setup_character_select()
        load_screen = true
        first_load = true
        Wait(100)
    end
    DoScreenFadeOut(1000)
    SetTimeout(1000, function()
        SetTimeout(1000, function()
            DoScreenFadeIn(1000)
            setup_character_select()
        end)
    end)
end)

--- @section Testing

--- Test command to reload char select after restarting core.
RegisterCommand('test_char_select', function()
    setup_character_select()
end, false)
