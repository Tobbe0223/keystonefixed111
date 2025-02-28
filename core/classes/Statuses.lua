Statuses = {}

Statuses.__index = Statuses

--- Creates a new Statuses instance for the given player.
--- @param player table: The player instance.
--- @return table: The new Statuses object.
function Statuses.new(player)
    if player.statuses then return player.statuses end
    return setmetatable({ player = player }, Statuses)
end

--- Retrieves all statuses of the player.
--- @return table: A deep copy of the players statuses.
function Statuses:get_statuses()
    return TABLES.deep_copy(self.player._data.statuses)
end

exports('get_statuses', function(source)
    local player = player_registry[source]
    if player then return player.statuses:get_statuses() end
end)

--- Sets multiple statuses for the player.
--- @param updates table: A table containing `{ key = { add = number, remove = number } }` values.
--- @return boolean: True if statuses were successfully updated.
function Statuses:set_statuses(updates)
    if type(updates) ~= 'table' then return false end
    for key, mod in pairs(updates) do
        local max_value = key == 'health' and 200 or 100
        local current_value = self.player._data.statuses[key] or 0
        local modified_value = current_value + (mod.add or 0) - (mod.remove or 0)
        self.player._data.statuses[key] = math.min(max_value, math.max(0, modified_value))
    end
    self.player:sync_data('statuses')
    return true
end

exports('set_statuses', function(source, updates)
    local player = player_registry[source]
    if player then return player.statuses:set_statuses(updates) end
    return false
end)

--- Retrieves the value of a specific status.
--- @param key string: The key of the status to retrieve.
--- @return number: The value of the status or `0` if not found.
function Statuses:get_status(key)
    return self.player._data.statuses[key] or 0
end

exports('get_status', function(source, key)
    local player = player_registry[source]
    if player then return player.statuses:get_status(key) end
end)

--- Sets the value of a specific status.
--- @param key string: The key of the status to set.
--- @param modifiers table: A table containing `{ add = number, remove = number }` values.
--- @return boolean: True if the status was successfully set.
function Statuses:set_status(key, modifiers)
    if not key or not modifiers then return false end
    local max_value = key == 'health' and 200 or 100
    local current_value = self.player._data.statuses[key] or 0
    local modified_value = current_value + (modifiers.add or 0) - (modifiers.remove or 0)
    self.player._data.statuses[key] = math.min(max_value, math.max(0, modified_value))
    self.player:sync_data('statuses')
    return true
end

exports('set_status', function(source, key, modifiers)
    local player = player_registry[source]
    if player then return player.statuses:set_status(key, modifiers) end
    return false
end)

--- Resets all statuses of the player to their default values.
--- @return boolean: True if statuses were successfully reset.
function Statuses:reset_statuses()
    self.player._data.statuses = {
        health = 200,
        armour = 0,
        hunger = 100,
        thirst = 100,
        stress = 0,
        stamina = 100,
        oxygen = 100,
        hygiene = 100
    }
    self.player:sync_data('statuses')
    return true
end

exports('reset_statuses', function(source)
    local player = player_registry[source]
    if player then return player.statuses:reset_statuses() end
    return false
end)

--- Revives the player.
function Statuses:revive_player()
    self:reset_statuses()
    self.player.flags:reset_flags()
    self.player.injuries:clear_injuries()
    self.player:sync_data()
    TriggerClientEvent('keystone:cl:revive_player', self.player.source)
    debug_log('success', ('[Revive] Player %s has been revived.'):format(self.player.source))
end

exports('revive_player', function(source)
    local player = player_registry[source]
    if player then return player.statuses:revive_player() end
    return false
end)

--- Kills the player.
function Statuses:kill_player()
    self.player._data.statuses.health = 1
    self.player._data.flags.is_dead = true
    self.player._data.flags.is_injured = true
    self.player:sync_data()
    TriggerClientEvent('keystone:cl:player_died', self.player.source)
    debug_log('info', ('[Death] Player %s has been marked as dead.'):format(self.player.source))
end

exports('kill_player', function(source)
    local player = player_registry[source]
    if player then return player.statuses:kill_player() end
    return false
end)

--- Puts the player into a downed state.
function Statuses:down_player()
    self.player._data.statuses.health = 10
    self.player._data.flags.is_downed = true
    self.player:sync_data()
    TriggerClientEvent('keystone:cl:down_player', self.player.source)
    debug_log('info', ('[Downed] Player %s has been marked as downed.'):format(self.player.source))
end

exports('down_player', function(source)
    local player = player_registry[source]
    if player then return player.statuses:down_player() end
    return false
end)

--- Respawns the player.
function Statuses:respawn_player()
    local bucket_config = config.routing_buckets.main
    if not bucket_config or not bucket_config.respawn then
        debug_log('error', '[Respawn] No valid respawn location found in bucket config.')
        return false
    end
    self:reset_statuses()
    self.player.flags:reset_flags()
    self.player.injuries:clear_injuries()
    self.player._data.spawns.last_location = { x = bucket_config.respawn.x, y = bucket_config.respawn.y, z = bucket_config.respawn.z, w = bucket_config.respawn.w }
    self.player:sync_data()
    TriggerClientEvent('keystone:cl:spawn_player', self.player.source, self.player._data.spawns.last_location)
    debug_log('success', ('[Respawn] Player %s has respawned at %s'):format(self.player.source, json.encode(self.player._data.spawns.last_location)))
    return true
end

exports('respawn_player', function(source)
    local player = player_registry[source]
    if player then return player.statuses:respawn_player() end
    return false
end)