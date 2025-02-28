Effects = {}

Effects.__index = Effects

--- @todo effects functions currently wont work, no effects have been setup. this will be done asap.

--- Creates a new Effects instance for the given player.
--- @param player table: The player instance.
--- @return table: The new Effects object.
function Effects.new(player)
    if player.effects then return player.effects end
    return setmetatable({ player = player }, Effects)
end

--- Retrieves all effects of the player.
--- @return table: A deep copy of the players effects.
function Effects:get_effects()
    return TABLES.deep_copy(self.player._data.effects)
end

exports('get_effects', function(source)
    local player = player_registry[source]
    if player then return player.effects:get_effects() end
end)

--- Retrieves a specific effect by its key.
--- @param key string: The key of the effect to retrieve.
--- @return table|nil: The effect data if found, or nil if not found.
function Effects:get_effect(key)
    return self.player._data.effects[key] or nil
end

exports('get_effect', function(source, key)
    local player = player_registry[source]
    if player then return player.effects:get_effect(key) end
end)

--- Sets multiple effects for the player.
--- @param effect_keys table: A list of effect keys to set.
--- @return boolean: True if effects were successfully set.
function Effects:set_effects(effect_keys)
    if type(effect_keys) ~= 'table' then return false end
    for _, key in ipairs(effect_keys) do
        self.player._data.effects[key] = self.player._data.effects[key] or { effect_id = key, applied = os.time() }
    end
    self.player:sync_data('effects')
    return true
end

exports('set_effects', function(source, effect_keys)
    local player = player_registry[source]
    if player then return player.effects:set_effects(effect_keys) end
    return false
end)

--- Sets a specific effect for the player.
--- @param key string: The key of the effect to set.
--- @return boolean: True if the effect was successfully set.
function Effects:set_effect(key)
    if not key then return false end
    self.player._data.effects[key] = self.player._data.effects[key] or { effect_id = key, applied = os.time() }
    self.player:sync_data('effects')
    return true
end

exports('set_effect', function(source, key)
    local player = player_registry[source]
    if player then return player.effects:set_effect(key) end
    return false
end)

--- Clears all effects from the player.
--- @return boolean: True if effects were successfully cleared.
function Effects:clear_effects()
    self.player._data.effects = {}
    self.player:sync_data('effects')
    return true
end

exports('clear_effects', function(source)
    local player = player_registry[source]
    if player then return player.effects:clear_effects() end
    return false
end)