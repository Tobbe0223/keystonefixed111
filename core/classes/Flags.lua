Flags = {}

Flags.__index = Flags

--- Creates a new Flags instance for the given player.
--- @param player table: The player instance.
--- @return table: The new Flags object.
function Flags.new(player)
    if player.flags then return player.flags end
    return setmetatable({ player = player }, Flags)
end

--- Retrieves all flags of the player.
--- @return table: A deep copy of the players flags.
function Flags:get_flags()
    return TABLES.deep_copy(self.player._data.flags)
end

exports('get_flags', function(source)
    local player = player_registry[source]
    if player then return player.flags:get_flags() end
end)

--- Retrieves the value of a specific flag.
--- @param key string: The key of the flag to retrieve.
--- @return boolean: True if the flag is set, false otherwise.
function Flags:get_flag(key)
    return self.player._data.flags[key] == true
end

exports('get_flag', function(source, key)
    local player = player_registry[source]
    if player then return player.flags:get_flag(key) end
end)

--- Sets multiple flags for the player.
--- @param updates table: A table containing key-value pairs of flags to update.
--- @return boolean: True if flags were successfully updated.
function Flags:set_flags(updates)
    if type(updates) ~= 'table' then return false end
    for key, value in pairs(updates) do
        self.player._data.flags[key] = value == true
    end
    self.player:sync_data('flags')
    return true
end

exports('set_flags', function(source, updates)
    local player = player_registry[source]
    if player then return player.flags:set_flags(updates) end
    return false
end)

--- Sets the value of a specific flag.
--- @param key string: The key of the flag to set.
--- @param value boolean: The value to set for the flag.
--- @return boolean: True if the flag was successfully set.
function Flags:set_flag(key, value)
    if not key then return false end
    self.player._data.flags[key] = value == true
    self.player:sync_data('flags')
    return true
end

exports('set_flag', function(source, key, value)
    local player = player_registry[source]
    if player then return player.flags:set_flag(key, value) end
    return false
end)

--- Resets all flags of the player to their default values (false).
--- @return boolean: True if flags were successfully reset.
function Flags:reset_flags()
    local flags = self.player._data.flags
    for key in pairs(flags) do
        flags[key] = false
    end
    self.player:sync_data('flags')
    return true
end

exports('reset_flags', function(source)
    local player = player_registry[source]
    if player then return player.flags:reset_flags() end
    return false
end)