Spawns = {}

Spawns.__index = Spawns

--- Creates a new Spawns instance for the given player.
--- @param player table: The player instance.
--- @return table: The new Spawns object.
function Spawns.new(player)
    if player.spawns then return player.spawns end
    return setmetatable({ player = player }, Spawns)
end

--- Retrieves all spawns for the player.
--- @return table: A deep copy of the players spawns.
function Spawns:get_spawns()
    return TABLES.deep_copy(self.player._data.spawns)
end

exports('get_spawns', function(source)
    local player = player_registry[source]
    if player then return player.spawns:get_spawns() end
end)

--- Retrieves a specific spawn by its ID.
--- @param spawn_id string: The ID of the spawn to retrieve.
--- @return table|nil: The spawn data if found, or nil if not found.
function Spawns:get_spawn(spawn_id)
    return self.player._data.spawns[spawn_id] or nil
end

exports('get_spawn', function(source, spawn_id)
    local player = player_registry[source]
    if player then return player.spawns:get_spawn(spawn_id) end
end)

--- Sets or updates a spawn location.
--- @param spawn_id string: The ID of the spawn to set.
--- @param coords table: The coordinates {x, y, z, w}.
--- @return boolean: True if the spawn was successfully set.
function Spawns:set_spawn(spawn_id, coords)
    if not spawn_id or type(coords) ~= 'table' then return false end
    self.player._data.spawns[spawn_id] = coords
    self.player:sync_data('spawns')
    return true
end

exports('set_spawn', function(source, spawn_id, coords)
    local player = player_registry[source]
    if player then return player.spawns:set_spawn(spawn_id, coords) end
    return false
end)

--- Removes a specific spawn by its ID.
--- @param spawn_id string: The ID of the spawn to remove.
--- @return boolean: True if the spawn was removed, false otherwise.
function Spawns:remove_spawn(spawn_id)
    if not self.player._data.spawns[spawn_id] then return false end
    self.player._data.spawns[spawn_id] = nil
    self.player:sync_data('spawns')
    return true
end

exports('remove_spawn', function(source, spawn_id)
    local player = player_registry[source]
    if player then return player.spawns:remove_spawn(spawn_id) end
    return false
end)

--- Clears all spawns except for `last_location`.
--- @return boolean: True if all other spawns were cleared.
function Spawns:clear_spawns()
    local last_location = self.player._data.spawns.last_location or nil
    self.player._data.spawns = last_location and { last_location = last_location } or {}
    self.player:sync_data('spawns')
    return true
end

exports('clear_spawns', function(source)
    local player = player_registry[source]
    if player then return player.spawns:clear_spawns() end
    return false
end)
