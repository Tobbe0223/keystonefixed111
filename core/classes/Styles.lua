Styles = {}

Styles.__index = Styles

--- Creates a new Styles instance for the given player.
--- @param player table: The player instance.
--- @return table: The new Styles object.
function Styles.new(player)
    if player.styles then return player.styles end
    return setmetatable({ player = player }, Styles)
end

--- Retrieves all style data of the player.
--- @return table: The players style data.
function Styles:get_styles()
    return self.player._data.styles
end

exports('get_styles', function(source)
    local player = player_registry[source]
    if player then return player.styles:get_styles() end
end)

--- Retrieves the current style data of the player.
--- @return table: The players current style.
function Styles:get_style()
    return self.player._data.styles.style
end

exports('get_style', function(source)
    local player = player_registry[source]
    if player then return player.styles:get_style() end
end)

--- Retrieves all outfits of the player.
--- @return table: A deep copy of the players outfits.
function Styles:get_outfits()
    return TABLES.deep_copy(self.player._data.styles.outfits)
end

exports('get_outfits', function(source)
    local player = player_registry[source]
    if player then return player.styles:get_outfits() end
end)

--- Retrieves a specific outfit by its ID.
--- @param outfit_id string: The ID of the outfit to retrieve.
--- @return table: A deep copy of the outfit data or an empty table if not found.
function Styles:get_outfit(outfit_id)
    return TABLES.deep_copy(self.player._data.styles.outfits[outfit_id] or {})
end

exports('get_outfit', function(source, outfit_id)
    local player = player_registry[source]
    if player then return player.styles:get_outfit(outfit_id) end
end)

--- Checks if the player has customised their style.
--- @return boolean: True if the players style has been customised, false otherwise.
function Styles:has_customised()
    return self.player._data.styles.has_customised == true
end

exports('has_customised', function(source)
    local player = player_registry[source]
    if player then return player.styles:has_customised() end
end)

--- Marks the players style as customised.
--- @return boolean: True if the players style was successfully marked as customised.
function Styles:mark_as_customised()
    self.player._data.styles.has_customised = true
    self.player:sync_data("styles")
    return true
end

exports('mark_as_customised', function(source)
    local player = player_registry[source]
    if player then return player.styles:mark_as_customised() end
    return false
end)

--- Sets a new style for the player.
--- @param new_style table: The new style data to apply.
--- @return boolean: True if the style was successfully updated.
function Styles:set_style(new_style)
    if type(new_style) ~= "table" then return false end
    for k, v in pairs(new_style) do self.player._data.styles.style[k] = v end
    self.player:sync_data("styles")
    return true
end

exports('set_style', function(source, new_style)
    local player = player_registry[source]
    if player then return player.styles:set_style(new_style) end
    return false
end)

--- Adds a new outfit to the players collection of outfits.
--- @param outfit_id string: The ID of the outfit to add.
--- @param outfit_data table|boolean: The outfit data.
--- @return boolean: True if the outfit was successfully added.
function Styles:add_outfit(outfit_id, outfit_data)
    if not outfit_id then return false end
    self.player._data.styles.outfits[outfit_id] = outfit_data
    self.player:sync_data("styles")
    return true
end

exports('add_outfit', function(source, outfit_id, outfit_data)
    local player = player_registry[source]
    if player then return player.styles:add_outfit(outfit_id, outfit_data) end
    return false
end)

--- Removes an outfit from the players collection of outfits.
--- @param outfit_id string: The ID of the outfit to remove.
--- @return boolean: True if the outfit was removed, false otherwise.
function Styles:remove_outfit(outfit_id)
    if not self.player._data.styles.outfits[outfit_id] then return false end
    self.player._data.styles.outfits[outfit_id] = nil
    self.player:sync_data("styles")
    return true
end

exports('remove_outfit', function(source, outfit_id)
    local player = player_registry[source]
    if player then return player.styles:remove_outfit(outfit_id) end
    return false
end)