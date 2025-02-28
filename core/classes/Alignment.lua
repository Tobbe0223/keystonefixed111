local alignment_functions = get_module('alignment')

Alignment = {}

Alignment.__index = Alignment

--- Creates a new Alignment instance for the given player.
--- @param player table: The player instance.
--- @return table: The new Alignment object.
function Alignment.new(player)
    if player.alignment then return player.alignment end
    return setmetatable({ player = player }, Alignment)
end

--- Gets the current lawfulness.
--- @return number: The current lawfulness value.
function Alignment:get_lawfulness()
    return self.player._data.lawfulness or 500
end

exports('get_lawfulness', function(source)
    local player = player_registry[source]
    if player and player.alignment then
        return player.alignment:get_lawfulness()
    end
    return nil
end)

--- Gets the current morality.
--- @return number: The current morality value.
function Alignment:get_morality()
    return self.player._data.morality or 500
end

exports('get_morality', function(source)
    local player = player_registry[source]
    if player and player.alignment then
        return player.alignment:get_morality()
    end
    return nil
end)

--- Retrieves a placeholder title based on lawfulness and morality.
--- @return string: The composite title.
function Alignment:get_title()
    local lawfulness = self:get_lawfulness()
    local morality = self:get_morality()
    local lawfulness_title = alignment_functions.get_lawfulness_title(lawfulness)
    local morality_title = alignment_functions.get_morality_title(morality)
    return lawfulness_title .. ' (' .. morality_title .. ')'
end

exports('get_title', function(source)
    local player = player_registry[source]
    if player and player.alignment then
        return player.alignment:get_title()
    end
    return 'True Neutral'
end)

--- Modifies the lawfulness based on the specified action.
--- @param action string: 'add' to increase, 'remove' to decrease, or 'set'.
--- @param amount number: The amount to modify by, or the new value to set.
function Alignment:modify_lawfulness(action, amount)
    if type(amount) == 'number' and amount >= 0 then
        local handlers = {
            add = function()
                local current = self:get_lawfulness()
                self.player._data.lawfulness = math.min(1000, current + amount)
            end,
            remove = function()
                local current = self:get_lawfulness()
                self.player._data.lawfulness = math.max(0, current - amount)
            end,
            set = function()
                self.player._data.lawfulness = math.min(1000, math.max(0, amount))
            end
        }
        if handlers[action] then
            handlers[action]()
            return true
        end
    end
    return false
end

exports('modify_lawfulness', function(source, action, amount)
    local player = player_registry[source]
    if player and player.alignment then
        return player.alignment:modify_lawfulness(action, amount)
    end
    return false
end)

--- Modifies the morality based on the specified action.
--- @param action string: 'add' to increase, 'remove' to decrease, or 'set'.
--- @param amount number: The amount to modify by, or the new value to set.
function Alignment:modify_morality(action, amount)
    if type(amount) == 'number' and amount >= 0 then
        local handlers = {
            add = function()
                local current = self:get_morality()
                self.player._data.morality = math.min(1000, current + amount)
            end,
            remove = function()
                local current = self:get_morality()
                self.player._data.morality = math.max(0, current - amount)
            end,
            set = function()
                self.player._data.morality = math.min(1000, math.max(0, amount))
            end
        }
        if handlers[action] then
            handlers[action]()
            return true
        end
    end
    return false
end

exports('modify_morality', function(source, action, amount)
    local player = player_registry[source]
    if player and player.alignment then
        return player.alignment:modify_morality(action, amount)
    end
    return false
end)