Identity = {}

Identity.__index = Identity

--- Creates a new Identity instance for the given player.
--- @param player table: The player instance.
--- @return table: The new Identity object.
function Identity.new(player)
    if player.identity then return player.identity end
    return setmetatable({ player = player }, Identity)
end

--- Retrieves the players full name.
--- @return string: The players full name, including the middle name if available.
function Identity:get_full_name()
    local identity = self.player._data.identity
    return identity.middle_name and ('%s %s %s'):format(identity.first_name, identity.middle_name, identity.last_name)or ('%s %s'):format(identity.first_name, identity.last_name)
end

exports('get_full_name', function(source)
    local player = player_registry[source]
    if not player then return nil end
    return player.identity:get_full_name()
end)

--- Retrieves the players unique identifier.
--- @return string: The players identifier.
function Identity:get_identifier()
    return self.player.identifier
end

exports('get_identifier', function(source)
    local player = player_registry[source]
    if not player then return nil end
    return player.identity:get_identifier()
end)

--- Changes the players name (first, last, and optional middle name).
--- @param first_name string: The new first name.
--- @param last_name string: The new last name.
--- @param middle_name string|nil: The new middle name (optional).
--- @return boolean: True if the name was successfully changed.
function Identity:change_name(first_name, last_name, middle_name)
    self.player._data.identity.first_name = first_name
    self.player._data.identity.last_name = last_name
    self.player._data.identity.middle_name = middle_name or nil
    MySQL.update.await('UPDATE players SET first_name = ?, last_name = ?, middle_name = ? WHERE identifier = ?', { first_name, last_name, middle_name, self.player.identifier })
    self.player:sync_data('identity')
    return true
end

exports('change_name', function(source, first_name, last_name, middle_name)
    local player = player_registry[source]
    if not player then return false end
    return player.identity:change_name(first_name, last_name, middle_name)
end)

--- Changes the players profile picture.
--- @param img_src string: The URL or path to the new profile picture.
--- @return boolean: True if the profile picture was successfully updated.
function Identity:change_profile_picture(img_src)
    if not img_src or img_src == '' then return false end
    self.player._data.identity.profile_picture = img_src
    MySQL.update.await('UPDATE players SET profile_picture = ? WHERE identifier = ?', { img_src, self.player.identifier })
    self.player:sync_data('identity')
    return true
end

exports('change_profile_picture', function(source, img_src)
    local player = player_registry[source]
    if not player then return false end
    return player.identity:change_profile_picture(img_src)
end)