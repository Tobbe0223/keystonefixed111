--- @section Constants

--- Interaction keys for DUI.
--- Any actions here will be displayed on the DUI when players are in range.
local INTERACTION_KEYS <const> = {
    clothing = {
        { 
            key = 'E',
            label = 'Change Clothing',
            action_type = 'client',
            action = 'keystone:cl:open_clothing_store'
        }
    }
}

--- Clothing store locations.
--- Only did one just as an example, the point here isnt to fill it, just to show things work.
local LOCATIONS <const> = {
    { 
        id = 'clothing_strawberry_innocence_blvd', 
        coords = vector4(71.98, -1398.64, 29.36, 300.48),
        type = 'clothing',
        header = { primary = 'STORE', secondary = 'CLOTHING' },
        image = 'key_mascotx100.png'
    }
}

--- Clothing UI.
--- Utils functions will support all clothing groups included tattoos.
--- This setup could be added too or replicated to make other "clothing" places, barbers, plastic surgeons etc.
--- Tattoos are currently limited to 1 tattoo per slot, have plans to change this.
local CLOTHING_UI = {
    resource = GetCurrentResourceName(),
    header = {},
    footer = {
        actions = {
            { id = 'close_ui', key = 'ESCAPE', label = 'Exit', params = { dui_location_id = '' } },
            { 
                id = 'save_character_customisation', 
                params = { should_exit = true, dui_location_id = '' }, 
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

local current_location = nil

--- @section Events

--- Opens the clothing store.
RegisterNetEvent('keystone:cl:open_clothing_store', function()
    DoScreenFadeOut(2000)
    Wait(2000)
    local ped = PlayerPedId()
    local heading = GetEntityHeading(ped)
    Wait(50)
    setup_camera(heading, 'body_cam')
    local current_location = nil
    for _, data in pairs(LOCATIONS) do
        if dui_locations[data.id] then
            dui_locations[data.id].is_hidden = true
            current_location = data.id
        end
    end
    local found_close, found_save = false, false
    for _, action in ipairs(CLOTHING_UI.footer.actions) do
        if action.id == 'close_ui' then
            action.params.dui_location_id = current_location
            found_close = true
        elseif action.id == 'save_character_customisation' then
            action.params.dui_location_id = current_location
            found_save = true
        end
        if found_close and found_save then
            break
        end
    end
    CLOTHING_UI.header.header_left = {
        image = player_data.identity.profile_picture,
        info_1 = player_data.identity.name,
        info_2 = player_data.identity.identifier
    }
    CLOTHING_UI.header.header_right = {
        flex_direction = 'row',
        options = {{ icon = 'fa-solid fa-id-card', value = GetPlayerServerId(PlayerId()) }}
    }
    DoScreenFadeIn(2000)
    build_ui(CLOTHING_UI)
end)

--- Initializes clothing stores; triggered on player joined.
function init_clothing_stores()
    for _, data in pairs(LOCATIONS) do
        remove_dui_zone(data.id)
        add_dui_zone({
            image = data.image or nil,
            id = data.id,
            coords = data.coords,
            header = data.header,
            icon = data.image or '',
            keys = INTERACTION_KEYS[data.type] or {},
            outline = true
        })
    end
end