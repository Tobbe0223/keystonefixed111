Injuries = {}

Injuries.__index = Injuries

--- Creates a new Injuries instance for the given player.
--- @param player table: The player instance.
--- @return table: The new Injuries object.
function Injuries.new(player)
    if player.injuries then return player.injuries end
    return setmetatable({ player = player }, Injuries)
end

--- Retrieves all injuries of the player.
--- @return table: A deep copy of the players injuries.
function Injuries:get_injuries()
    return TABLES.deep_copy(self.player._data.injuries)
end

exports('get_injuries', function(source)
    local player = player_registry[source]
    if player then return player.injuries:get_injuries() end
end)

--- Retrieves the severity of a specific injury.
--- @param injury string: The key of the injury to retrieve.
--- @return number: The severity level of the injury (default 0 if not found).
function Injuries:get_injury(injury)
    return self.player._data.injuries[injury] or 0
end

exports('get_injury', function(source, injury)
    local player = player_registry[source]
    if player then return player.injuries:get_injury(injury) end
end)

--- Sets multiple injuries for the player.
--- @param updates table: A table containing injury keys and their severity levels to update.
--- @return boolean: True if injuries were successfully updated.
function Injuries:set_injuries(updates)
    if type(updates) ~= 'table' then return false end
    for injury, mod in pairs(updates) do
        local current_severity = self.player._data.injuries[injury] or 0
        local new_severity = current_severity + (mod.add or 0) - (mod.remove or 0)
        self.player._data.injuries[injury] = math.max(0, new_severity)
    end
    self.player:sync_data('injuries')
    return true
end

exports('set_injuries', function(source, updates)
    local player = player_registry[source]
    if player then return player.injuries:set_injuries(updates) end
    return false
end)

--- Sets a specific injury's severity for the player.
--- @param injury string: The key of the injury to set.
--- @param severity number: The severity level (must be a number, minimum 0).
--- @return boolean: True if the injury was successfully updated.
function Injuries:set_injury(injury, severity)
    if not injury or type(severity) ~= 'number' then return false end
    self.player._data.injuries[injury] = math.max(0, severity)
    self.player:sync_data('injuries')
    return true
end

exports('set_injury', function(source, injury, severity)
    local player = player_registry[source]
    if player then return player.injuries:set_injury(injury, severity) end
    return false
end)

--- Clears a specific injury for the player.
--- @param injury string: The key of the injury to clear.
--- @return boolean: True if the injury was successfully cleared.
function Injuries:clear_injury(injury)
    if not self.player._data.injuries[injury] then return false end
    self.player._data.injuries[injury] = 0
    self.player:sync_data('injuries')
    return true
end

exports('clear_injury', function(source, injury)
    local player = player_registry[source]
    if player then return player.injuries:clear_injury(injury) end
    return false
end)

--- Clears all injuries for the player.
--- @return boolean: True if all injuries were successfully cleared.
function Injuries:clear_injuries()
    for injury in pairs(self.player._data.injuries) do
        self.player._data.injuries[injury] = 0
    end
    self.player:sync_data('injuries')
    return true
end

exports('clear_injuries', function(source)
    local player = player_registry[source]
    if player then return player.injuries:clear_injuries() end
    return false
end)