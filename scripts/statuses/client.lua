--- @section Constants

local STATUS_DECAY <const> = { hunger = 0.1, thirst = 0.08, hygiene = 0.025 }
local INTERVAL = 20000 -- Status decay/sync interval in ms
local HEALTH_DECAY_RATE <const> = 5 -- Health loss per interval when hunger/thirst is empty
local BONE_INJURY_MAP <const> = { -- Bone mapping to human body svg.
    [31086] = 'head',
    [39317] = 'upper_torso',
    [51826] = 'lower_torso',
    [18905] = 'forearm_right',
    [57005] = 'hand_right',
    [58271] = 'thigh_right',
    [63931] = 'calf_right',
    [2108]  = 'foot_right',
    [61163] = 'forearm_left',
    [18905] = 'hand_left',
    [65478] = 'thigh_left',
    [36864] = 'calf_left',
    [14201] = 'foot_left'
}

--- @section Tables

local last_synced_statuses = {}

--- @section Variables

local is_downed = false
local is_dead = false
local key_pressed = false 
local hygiene_effect_active = false

--- @section Functions

--- Prevents key spamming.
--- @param time number: The cooldown time in ms.
local function prevent_key_spam(time)
    key_pressed = true
    Wait(time)
    key_pressed = false
end

--- Ensures that the players health is always set to 200.
local function enforce_custom_health()
    local player = PlayerPedId()
    if GetEntityHealth(player) ~= 200 then
        SetEntityHealth(player, 200)
    end
end

--- Checks for flag changes and triggers the correct event.
local function check_flag_changes()
    local data = get_player_data()
    local flags = data.flags
    local was_downed, was_dead = is_downed, is_dead
    is_downed = flags.is_downed
    is_dead = flags.is_dead
    if is_dead and not was_dead then return TriggerEvent('keystone:cl:player_died') end
    if is_downed and not was_downed then return TriggerEvent('keystone:cl:down_player') end
    if not is_dead and not is_downed and (was_downed or was_dead) then return TriggerEvent('keystone:cl:revive_player') end
end

--- Plays a smooth transition between two animations.
--- @param ped number: The player ped entity.
--- @param dict_from string: The animation dictionary to transition from.
--- @param anim_from string: The animation to transition from.
--- @param dict_to string: The animation dictionary to transition to.
--- @param anim_to string: The animation to transition to.
local function transition_animation(ped, dict_from, anim_from, dict_to, anim_to)
    StopAnimTask(ped, dict_from, anim_from, 1.0)
    REQUESTS.anim(dict_to)
    TaskPlayAnim(ped, dict_to, anim_to, 2.0, -2.0, -1, 1, 0, false, false, false)
end

--- @section NUI Callbacks

--- NUI Callback to respawn player.
RegisterNUICallback('respawn_player', function(_, cb)
    SendNUIMessage({ action = 'hide_death_screen' })
    CALLBACKS.trigger('keystone:sv:respawn_player', nil, function(success)
        cb({ success = success })
    end)
end)

--- NUI Callback to request assistance. 
--- Not fully implemented yet.
RegisterNUICallback('request_assistance', function(_, cb)
    CALLBACKS.trigger('keystone:sv:request_assistance', nil, function(success)
        cb({ success = success })
    end)
end)

--- NUI Callback to give up.
RegisterNUICallback('give_up', function(_, cb)
    CALLBACKS.trigger('keystone:sv:player_give_up', nil, function(success)
        cb({ success = success })
    end)
end)


--- @section Events

--- Puts the player in a downed state.
RegisterNetEvent('keystone:cl:down_player')
AddEventHandler('keystone:cl:down_player', function()
    if is_downed then return end
    is_downed = true
    local ped = PlayerPedId()
    local downed_anim_dict = 'combat@damage@writhe'
    local downed_anim = 'writhe_loop'
    local screen_data = {
        title = 'YOU ARE DOWNED',
        give_up_enabled = true,
        give_up_key = 'G',
        assistance_enabled = true,
        assistance_key = 'H',
        assistance_timer = 60,
        cancel_key = 'C'
    }
    SendNUIMessage({ action = 'show_death_screen', data = screen_data })
    REQUESTS.anim(downed_anim_dict)
    TaskPlayAnim(ped, downed_anim_dict, downed_anim, 8.0, -8.0, -1, 1, 0, false, false, false)
    CreateThread(function()
        while is_downed do
            Wait(0)
            if not key_pressed then
                if IsControlJustPressed(0, KEY_LIST['g']) then
                    prevent_key_spam(1500)
                    SendNUIMessage({ action = 'give_up' })
                    DoScreenFadeOut(2000)
                    SendNUIMessage({ action = 'hide_death_screen' })
                    Wait(2000)
                    DoScreenFadeIn(2000)
                end
                if IsControlJustPressed(0, KEY_LIST['h']) then
                    prevent_key_spam(60000)
                    SendNUIMessage({ action = 'request_assistance' })
                end
            end
        end
    end)
end)

--- Triggers the full death state.
RegisterNetEvent('keystone:cl:player_died')
AddEventHandler('keystone:cl:player_died', function()
    if is_dead then return end
    is_dead = true
    local ped = PlayerPedId()
    local screen_data = {
        title = 'YOU DIED',
        respawn_enabled = true,
        respawn_key = 'E',
        cancel_respawn_key = 'ESCAPE',
        respawn_timer = 10,
        assistance_enabled = false
    }
    SendNUIMessage({ action = 'show_death_screen', data = screen_data })
    transition_animation(ped, 'combat@damage@writhe', 'writhe_loop', 'misslamar1dead_body', 'dead_idle')
    CreateThread(function()
        local is_respawning = false
        while is_dead do
            Wait(0)
            if not key_pressed then
                if IsControlJustPressed(0, KEY_LIST['e']) and not is_respawning then
                    SendNUIMessage({ action = 'start_respawn' })
                    is_respawning = true
                    prevent_key_spam(3000)
                end
                if IsControlJustPressed(0, KEY_LIST['escape']) and is_respawning then
                    SendNUIMessage({ action = 'cancel_respawn' })
                    is_respawning = false
                    prevent_key_spam(1500)
                end
            end
        end
    end)
end)

--- Revives the player.
RegisterNetEvent('keystone:cl:revive_player')
AddEventHandler('keystone:cl:revive_player', function()
    if not is_downed and not is_dead then return end
    is_downed = false
    is_dead = false
    local player = PlayerPedId()
    ClearPedTasksImmediately(player)
    SendNUIMessage({ action = 'hide_death_screen' })
end)

--- @section Threads

--- Tracks bone injuries.
local function track_injuries()
    local injuries = {}
    while true do
        local player = PlayerPedId()
        local hit, bone_index = GetPedLastDamageBone(player)
        if hit and BONE_INJURY_MAP[bone_index] then
            local injury_area = BONE_INJURY_MAP[bone_index]
            local severity = math.random(15, 40)
            if last_injuries[injury_area] ~= severity then
                last_injuries[injury_area] = severity
                injuries[injury_area] = { add = severity }
                TriggerServerEvent('keystone:sv:sync_injuries', injuries)
                SendNUIMessage({ action = 'set_injury', area = injury_area, value = severity })
            end
        end
        Wait(500)
    end
end

--- Handles hygiene effect.
--- @param value number: Players current hygiene level.
local function handle_hygiene_effect(value)
    local player = PlayerPedId()
    if value < 15 and not hygiene_effect_active then
        hygiene_effect_active = true
        RequestNamedPtfxAsset('core')
        while not HasNamedPtfxAssetLoaded('core') do Wait(100) end
        local effects = {}
        UseParticleFxAssetNextCall('core')
        for i = 1, 20 do
            local effect = StartNetworkedParticleFxLoopedOnEntity('ent_amb_insect_swarm', player,  0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, false, false, false)
            effects[#effects + 1] = effect
            Wait(0)
        end
        CreateThread(function()
            while hygiene_effect_active do
                if get_player_data('statuses').hygiene >= 16 then
                    for _, effect in ipairs(effects) do
                        StopParticleFxLooped(effect, true)
                        RemoveParticleFx(effect, 0)
                    end
                    hygiene_effect_active = false
                end
                Wait(5000)
            end
        end)
    elseif value >= 16 and hygiene_effect_active then
        hygiene_effect_active = false
    end
end

--- Continuously degrades player statuses over time.
local function degrade_statuses()
    while true do
        enforce_custom_health()
        local data = get_player_data()
        local statuses = data.statuses
        local updates = {}
        for status, decay_rate in pairs(STATUS_DECAY) do
            if statuses[status] then
                local new_value = math.max(0, statuses[status] - decay_rate)
                if statuses[status] ~= new_value then
                    updates[status] = { remove = statuses[status] - new_value }
                    statuses[status] = new_value
                end
            end
        end
        if statuses.hunger == 0 or statuses.thirst == 0 then
            if statuses.health > 10 then
                statuses.health = math.max(10, statuses.health - HEALTH_DECAY_RATE)
                updates.health = { remove = HEALTH_DECAY_RATE }
            end
        end
        if next(updates) then
            TriggerServerEvent('keystone:sv:sync_statuses', updates)
        end
        Wait(INTERVAL)
    end
end

--- Syncs player statuses.
local function sync_statuses()
    while true do
        local data = get_player_data()
        local statuses = data.statuses
        local status_keys = {}
        enforce_custom_health()
        for k, v in pairs(statuses) do
            local last_value = last_synced_statuses[k] or v
            if v ~= last_value then
                status_keys[#status_keys + 1] = k
            end
        end
        if #status_keys > 0 then
            CreateThread(function()
                for i, key in ipairs(status_keys) do
                    Wait(250 * i)
                    local value = statuses[key]
                    local last_value = last_synced_statuses[key] or value
                    local update = {
                        [key] = {
                            add = value > last_value and value - last_value or 0,
                            remove = value < last_value and last_value - value or 0
                        }
                    }
                    TriggerServerEvent('keystone:sv:sync_statuses', update)
                    last_synced_statuses[key] = value
                    if key == 'hygiene' then
                        handle_hygiene_effect(value)
                    end
                end
            end)
        end
        SendNUIMessage({ action = 'update_statuses', statuses = statuses })
        check_flag_changes()
        Wait(INTERVAL)
    end
end

--- @section Initialization

--- Inits statuses; triggered by player_joined event
function init_statuses()
    CreateThread(degrade_statuses)
    CreateThread(sync_statuses)
    CreateThread(track_injuries)
end
