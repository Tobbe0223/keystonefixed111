--- @section Customisation UI

--- Customisation UI.
--- You can modify the groupings if you want, I just made them so they are sort of relevant to one another and keep numbers down.
local FIRST_CUSTOMISATION_UI = {
    resource = GetCurrentResourceName(),
    header = {},
    footer = {
        actions = {
            { 
                id = 'disconnect', 
                key = 'ESCAPE', 
                label = 'Disconnect',
                modal = {
                    title = 'Confirm Disconnect',
                    description = 'Are you sure you want to disconnect?',
                    on_confirm = { action = 'disconnect' },
                    on_cancel = {
                        type = 'info',
                        header = 'Disconnect Cancelled',
                        message = 'You are no longer disconnecting.',
                        duration = 3000,
                    },
                } 
            },
            { 
                id = 'save_character_customisation', 
                params = { should_exit = true }, 
                key = 'Enter', 
                label = 'Save Customisation',
                modal = {
                    title = 'Confirm Customisation',
                    description = 'Are you sure you have finished customising?',
                    on_confirm = { action = 'save_character_customisation' },
                    on_cancel = {
                        type = 'info',
                        header = 'Save Cancelled',
                        message = 'Character customisation saving has been cancelled.',
                        duration = 3000,
                    },
                }
            },
            { id = 'change_customisation_camera', params = { cam = 'body_cam' }, key = 'B', label = 'Body Cam' },
            { id = 'change_customisation_camera', params = { cam = 'face_cam' }, key = 'M', label = 'Face Cam' },
            { id = 'change_customisation_camera', params = { cam = 'leg_cam' }, key = 'N', label = 'Leg Cam' },
            { id = 'change_ped_rotation', params = { direction = 'reset' }, key = 'R', label = 'Reset Rotation' },
            { id = 'change_ped_rotation', params = { direction = 'right' }, key = 'ArrowRight', label = 'Rotate Right' },
            { id = 'change_ped_rotation', params = { direction = 'left' }, key = 'ArrowLeft', label = 'Rotate Left' }
        },
    },
    content = {
        genetics = {
            id = 'customise_character',
            type = 'input_groups',
            title = 'Genetics',
            groups = {
                {
                    header = 'Heritage',
                    expandable = true,
                    inputs = {
                        { category = 'genetics', id = 'mother', label = 'Mother', type = 'number' },
                        { category = 'genetics', id = 'father', label = 'Father', type = 'number' },
                        { category = 'genetics', id = 'resemblance', label = 'Resemblance', type = 'number' },
                        { category = 'genetics', id = 'skin_tone', label = 'Skin Tone', type = 'number' }
                    }           
                },
                {
                    header = 'Eyes',
                    expandable = true,
                    inputs = {
                        { category = 'genetics', id = 'eye_colour', label = 'Eye Colour', type = 'number' },
                        { category = 'genetics', id = 'eye_opening', label = 'Eye Opening', type = 'number'},
                        { category = 'genetics', id = 'eyebrow_height', label = 'Eyebrow Height', type = 'number' },
                        { category = 'genetics', id = 'eyebrow_depth', label = 'Eyebrow Depth', type = 'number' },
                    }           
                },
                {
                    header = 'Nose',
                    expandable = true,
                    inputs = {
                        { category = 'genetics', id = 'nose_width', label = 'Nose Width', type = 'number' },
                        { category = 'genetics', id = 'nose_peak_height', label = 'Nose Peak Height', type = 'number' },
                        { category = 'genetics', id = 'nose_peak_length', label = 'Nose Peak Length', type = 'number' },
                        { category = 'genetics', id = 'nose_bone_height', label = 'Nose Bone Height', type = 'number' },
                        { category = 'genetics', id = 'nose_peak_lower', label = 'Nose Peak Lower', type = 'number' },
                        { category = 'genetics', id = 'nose_twist', label = 'Nose Twist', type = 'number' },
                    }           
                },
                {
                    header = 'Cheeks',
                    expandable = true,
                    inputs = {
                        { category = 'genetics', id = 'cheek_bone', label = 'Cheek Bone', type = 'number' },
                        { category = 'genetics', id = 'cheek_bone_sideways', label = 'Sideways Bone Size', type = 'number' },
                        { category = 'genetics', id = 'cheek_bone_width', label = 'Cheek Bone Width', type = 'number' },
                    }           
                },
                {
                    header = 'Lips',
                    expandable = true,
                    inputs = {
                        { category = 'genetics', id = 'lip_thickness', label = 'Lip Thickness', type = 'number' },
                    }           
                },
                {
                    header = 'Jaw',
                    expandable = true,
                    inputs = {
                        { category = 'genetics', id = 'jaw_bone_width', label = 'Jaw Bone Width', type = 'number' },
                        { category = 'genetics', id = 'jaw_bone_shape', label = 'Jaw Bone Shape', type = 'number' },
                    }           
                },
                {
                    header = 'Chin',
                    expandable = true,
                    inputs = {
                        { category = 'genetics', id = 'chin_bone', label = 'Chin Bone', type = 'number' },
                        { category = 'genetics', id = 'chin_bone_length', label = 'Chin Bone Length', type = 'number' },
                        { category = 'genetics', id = 'chin_bone_shape', label = 'Chin Bone Shape', type = 'number' },
                        { category = 'genetics', id = 'chin_hole', label = 'Chin Hole', type = 'number'},
                    }           
                },
                {
                    header = 'Neck',
                    expandable = true,
                    inputs = {
                        { category = 'genetics', id = 'neck_thickness', label = 'Neck Thickness', type = 'number' }
                    }           
                }
            }
        },
        barber = {
            id = 'customise_character',
            type = 'input_groups',
            title = 'Barber',
            groups = {
                {
                    header = 'Hair',
                    expandable = true,
                    inputs = {
                        { category = 'barber', id = 'hair', label = 'Hair', type = 'number' },
                        { category = 'barber', id = 'hair_colour', label = 'Hair Colour', type = 'number' },
                        { category = 'barber', id = 'fade', label = 'Fade', type = 'number' },
                        { category = 'barber', id = 'fade_opacity', label = 'Fade Opacity', type = 'number' },
                        { category = 'barber', id = 'fade_colour', label = 'Fade Colour', type = 'number' }
                    }           
                },
                {
                    header = 'Eyebrows',
                    expandable = true,
                    inputs = {
                        { category = 'barber', id = 'eyebrow', label = 'Eyebrow', type = 'number' },
                        { category = 'barber', id = 'eyebrow_opacity', label = 'Eyebrow Opacity', type = 'number' },
                        { category = 'barber', id = 'eyebrow_colour', label = 'Eyebrow Colour', type = 'number' }
                    }           
                },
                {
                    header = 'Facial Hair',
                    expandable = true,
                    inputs = {
                        { category = 'barber', id = 'facial_hair', label = 'Facial Hair', type = 'number' },
                        { category = 'barber', id = 'facial_hair_opacity', label = 'Facial Hair Opacity', type = 'number' },
                        { category = 'barber', id = 'facial_hair_colour', label = 'Facial Hair Colour', type = 'number' }
                    }           
                },
                {
                    header = 'Chest Hair',
                    expandable = true,
                    inputs = {
                        { category = 'barber', id = 'chest_hair', label = 'Chest Hair', type = 'number' },
                        { category = 'barber', id = 'chest_hair_opacity', label = 'Chest Hair Opacity', type = 'number' },
                        { category = 'barber', id = 'chest_hair_colour', label = 'Chest Hair Colour', type = 'number' }
                    }           
                },
                {
                    header = 'Make Up',
                    expandable = true,
                    inputs = {
                        { category = 'barber', id = 'make_up', label = 'Make Up', type = 'number' },
                        { category = 'barber', id = 'make_up_opacity', label = 'Make Up Opacity', type = 'number' },
                        { category = 'barber', id = 'make_up_colour', label = 'Make Up Colour', type = 'number' },
                        { category = 'barber', id = 'blush', label = 'Blush', type = 'number' },
                        { category = 'barber', id = 'blush_opacity', label = 'Blush Opacity', type = 'number' },
                        { category = 'barber', id = 'blush_colour', label = 'Blush Colour', type = 'number' },
                        { category = 'barber', id = 'lipstick', label = 'Lipstick', type = 'number' },
                        { category = 'barber', id = 'lipstick_opacity', label = 'Lipstick Opacity', type = 'number' },
                        { category = 'barber', id = 'lipstick_colour', label = 'Lipstick Colour', type = 'number' }
                    }           
                },
                {
                    header = 'Skin',
                    expandable = true,
                    inputs = {
                        { category = 'barber', id = 'blemishes', label = 'Blemishes', type = 'number' },
                        { category = 'barber', id = 'blemishes_opacity', label = 'Blemishes Opacity', type = 'number' },
                        { category = 'barber', id = 'body_blemishes', label = 'Body Blemishes', type = 'number' },
                        { category = 'barber', id = 'body_blemishes_opacity', label = 'Body Blemishes Opacity', type = 'number' },
                        { category = 'barber', id = 'ageing', label = 'Ageing', type = 'number' },
                        { category = 'barber', id = 'ageing_opacity', label = 'Ageing Opacity', type = 'number' },
                        { category = 'barber', id = 'complexion', label = 'Complexion', type = 'number' },
                        { category = 'barber', id = 'complexion_opacity', label = 'Complexion Opacity', type = 'number' },
                        { category = 'barber', id = 'sun_damage', label = 'Sun Damage', type = 'number' },
                        { category = 'barber', id = 'sun_damage_opacity', label = 'Sun Damage Opacity', type = 'number' },
                        { category = 'barber', id = 'moles', label = 'Moles', type = 'number' },
                        { category = 'barber', id = 'moles_opacity', label = 'Moles Opacity', type = 'number' }
                    }           
                },
            }
        },
        clothing = {
            id = 'customise_character',
            type = 'input_groups',
            title = 'Clothing',
            groups = {
                {
                    header = 'Head',
                    expandable = true,
                    inputs = {
                        { category = 'clothing', id = 'mask_style', label = 'Mask Style', type = 'number' },
                        { category = 'clothing', id = 'mask_texture', label = 'Mask Texture', type = 'number' },
                        { category = 'clothing', id = 'neck_style', label = 'Neck Style', type = 'number' },
                        { category = 'clothing', id = 'neck_texture', label = 'Neck Texture', type = 'number' },
                    }           
                },
                {
                    header = 'Chest',
                    expandable = true,
                    inputs = {
                        { category = 'clothing', id = 'vest_style', label = 'Vest Style', type = 'number' },
                        { category = 'clothing', id = 'vest_texture', label = 'Vest Texture', type = 'number' },
                        { category = 'clothing', id = 'shirt_style', label = 'Shirt Style', type = 'number' },
                        { category = 'clothing', id = 'shirt_texture', label = 'Shirt Texture', type = 'number' },
                        { category = 'clothing', id = 'jacket_style', label = 'Jacket Style', type = 'number' },
                        { category = 'clothing', id = 'jacket_texture', label = 'Jacket Texture', type = 'number' },
                    }           
                },
                {
                    header = 'Legs',
                    expandable = true,
                    inputs = {
                        { category = 'clothing', id = 'legs_style', label = 'Legs Style', type = 'number' },
                        { category = 'clothing', id = 'legs_texture', label = 'Legs Texture', type = 'number' },
                        { category = 'clothing', id = 'shoes_style', label = 'Shoes Style', type = 'number' },
                        { category = 'clothing', id = 'shoes_texture', label = 'Shoes Texture', type = 'number' }
                    }           
                },
                {
                    header = 'Accessories',
                    expandable = true,
                    inputs = {
                        { category = 'clothing', id = 'hands_style', label = 'Hands Style', type = 'number' },
                        { category = 'clothing', id = 'hands_texture', label = 'Hands Texture', type = 'number' },
                        { category = 'clothing', id = 'bag_style', label = 'Bag Style', type = 'number' },
                        { category = 'clothing', id = 'bag_texture', label = 'Bag Texture', type = 'number' },
                        { category = 'clothing', id = 'decals_style', label = 'Decals Style', type = 'number' },
                        { category = 'clothing', id = 'decals_texture', label = 'Decals Texture', type = 'number' },
                        { category = 'clothing', id = 'hats_style', label = 'Hats Style', type = 'number' },
                        { category = 'clothing', id = 'hats_texture', label = 'Hats Texture', type = 'number' },
                        { category = 'clothing', id = 'glasses_style', label = 'Glasses Style', type = 'number' },
                        { category = 'clothing', id = 'glasses_texture', label = 'Glasses Texture', type = 'number' },
                        { category = 'clothing', id = 'earwear_style', label = 'Earwear Style', type = 'number' },
                        { category = 'clothing', id = 'earwear_texture', label = 'Earwear Texture', type = 'number' },
                        { category = 'clothing', id = 'watches_style', label = 'Watches Style', type = 'number' },
                        { category = 'clothing', id = 'watches_texture', label = 'Watches Texture', type = 'number' },
                        { category = 'clothing', id = 'bracelets_style', label = 'Bracelets Style', type = 'number' },
                        { category = 'clothing', id = 'bracelets_texture', label = 'Bracelets Texture', type = 'number' }
                    }           
                },
            }
        }
    }
};

--- @section Variables

local is_customisation_active = false

--- @section Functions

--- Cleans up the customisation environment.
function cleanup_character_creation()
    destroy_active_camera()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close_ui' })
    is_customisation_active = false
end

--- @section NUI Callbacks

--- Updates character appearance data.
RegisterNUICallback('customise_character', function(data, cb)
    CHARACTER_CREATION.update_ped_data(current_sex, data.category, data.id, data.value)
    cb({ success = true })
end)

--- Changes the camera position.
RegisterNUICallback('change_customisation_camera', function(data, cb)
    setup_camera(config.character_customisation.customisation_location.w, data.cam)
    cb({ success = true })
end)

--- Rotates the ped during customisation.
RegisterNUICallback('change_ped_rotation', function(data, cb)
    CHARACTER_CREATION.rotate_ped(data.direction)
    cb({ success = true })
end)

--- Saves the current character customisation.
RegisterNUICallback('save_character_customisation', function(data, cb)
    local style = STYLES.get_style(current_sex)
    CALLBACKS.trigger('keystone:sv:save_character_customisation', { style = style }, function(response)
        if not response.success then cb({ success = false }) return end
        if data.should_exit then
            cleanup_character_creation()
            if response.first_customisation then
                local ped = PlayerPedId()
                DoScreenFadeOut(2000)
                SetTimeout(2000, function()
                    SetEntityCoords(ped, config.routing_buckets.main.spawn.x, config.routing_buckets.main.spawn.y, config.routing_buckets.main.spawn.z, false, false, false, true)
                    SetEntityHeading(ped, config.routing_buckets.main.spawn.w)
                    DoScreenFadeIn(2000)
                end)
            end
        end
        cb({ success = true })
    end)
end)

--- Updates the character's profile picture.
--- @param data table Data containing the new image source ('img_src').
RegisterNUICallback('change_character_profile_picture', function(data, cb)
    if not data or not data.img_src then
        debug_log('error', 'No data provided for changing profile picture.')
        cb({ success = false })
        return
    end
    CALLBACKS.trigger('keystone:sv:change_profile_picture', { img_src = data.img_src }, function(success)
        if not success then
            NOTIFICATIONS.send({
                type = 'error',
                header = 'Character Customisation',
                message = 'Failed to update profile picture. Contact an admin if this issue persists.',
                duration = 3500,
            })
            debug_log('error', 'Failed to update profile picture.')
            cb({ success = false })
            return
        end
        NOTIFICATIONS.send({
            type = 'success',
            header = 'Character Customisation',
            message = 'Profile picture updated successfully.',
            duration = 3500,
        })
        debug_log('info', 'Profile picture updated successfully.')
        cb({ success = true })
    end)
end)

--- @section Events

--- Sets up the character customisation environment.
--- @param location table: Customisation location.
--- @param player_data table: Players data.
RegisterNetEvent('keystone:cl:setup_character_customisation')
AddEventHandler('keystone:cl:setup_character_customisation', function(location, player_data)
    is_customisation_active = true
    DoScreenFadeOut(2000)
    Wait(2000)
    local ped = PlayerPedId()
    SetEntityCoords(ped, location.x, location.y, location.z, false, false, false, true)
    SetEntityHeading(ped, location.w)
    Wait(50)
    setup_camera(location.w, 'body_cam')
    FIRST_CUSTOMISATION_UI.header.header_left = {
        image = player_data.profile_picture,
        info_1 = player_data.name,
        info_2 = player_data.identifier
    }
    FIRST_CUSTOMISATION_UI.header.header_right = {
        flex_direction = 'row',
        options = {{ icon = 'fa-solid fa-id-card', value = tostring(player_data.source) }}
    }
    DoScreenFadeIn(2000)
    build_ui(FIRST_CUSTOMISATION_UI)
end)