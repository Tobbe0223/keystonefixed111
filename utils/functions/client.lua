local CURRENT_ACTIVE_CAM = nil

--- Sets up a camera based on the given position_key preset.
---@param z_location number The Z coordinate location for camera rotation.
---@param position_key string The key of `config.character_customisation.customisation_camera_positions` to use.
function setup_camera(z_location, position_key)
    local cam_config = config.character_customisation.customisation_camera_positions[position_key]
    if not cam_config then debug_log('error', ('Camera position_key "%s" does not exist.'):format(position_key)) return end
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then debug_log('error', 'Ped does not exist. Cannot set up camera.') return end
    local offset_x, offset_y, offset_z = cam_config.offset.x, cam_config.offset.y, cam_config.offset.z
    local height_adjustment = cam_config.height_adjustment or 0
    local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(ped, offset_x, offset_y, offset_z + height_adjustment))
    if not x or not y or not z then debug_log('error', ('Failed to calculate camera coordinates. Offset values used: %s'):format(json.encode(cam_config.offset))) return end
    if DoesCamExist(CURRENT_ACTIVE_CAM) then
        DestroyCam(CURRENT_ACTIVE_CAM, false)
    end
    CURRENT_ACTIVE_CAM = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamActive(CURRENT_ACTIVE_CAM, true)
    SetCamCoord(CURRENT_ACTIVE_CAM, x, y, z)
    SetCamRot(CURRENT_ACTIVE_CAM, -5.0, 0.0, z_location + 180.0)
    RenderScriptCams(true, false, 0, true, true)
    SetCamUseShallowDofMode(CURRENT_ACTIVE_CAM, true)
    SetCamNearDof(CURRENT_ACTIVE_CAM, cam_config.near_dof)
    SetCamFarDof(CURRENT_ACTIVE_CAM, cam_config.far_dof)
    SetCamDofStrength(CURRENT_ACTIVE_CAM, 1.2)
    debug_log('info', ('Camera setup completed for position_key "%s". Coordinates: [%.2f, %.2f, %.2f]'):format(position_key, x, y, z))
    CreateThread(function()
        while DoesCamExist(CURRENT_ACTIVE_CAM) do
            SetUseHiDof()
            Wait(0)
        end
    end)
end

--- Destroys the current active camera .
function destroy_active_camera()
    if DoesCamExist(CURRENT_ACTIVE_CAM) then
        DestroyCam(CURRENT_ACTIVE_CAM, false)
        RenderScriptCams(false, false, 0, true, true)
        CURRENT_ACTIVE_CAM = nil
        debug_log('info', 'Active camera destroyed and camera rendering disabled.')
    end
end