Roles = {}

Roles.__index = Roles

--- Creates a new Roles instance for the given player.
--- @param player table: The player instance.
--- @return table: The new Roles object.
function Roles.new(player)
    if player.roles then return player.roles end 
    return setmetatable({ player = player }, Roles)
end

--- Retrieves all roles assigned to the player.
--- @return table: A table containing all the players roles.
function Roles:get_roles()
    return self.player._data.roles or {}
end

exports('get_roles', function(source)
    local player = player_registry[source]
    return player and player.roles:get_roles() or nil
end)

--- Retrieves a specific roles data.
--- @param role_id string: The ID of the role to retrieve.
--- @return table|nil: The role data if found, or nil if not found.
function Roles:get_role(role_id)
    return self.player._data.roles[role_id] or nil
end

exports('get_role', function(source, role_id)
    local player = player_registry[source]
    return player and player.roles:get_role(role_id) or nil
end)

--- Checks if the player has a specific role.
--- @param role_id string: The ID of the role to check.
--- @return boolean: True if the player has the role, false otherwise.
function Roles:has_role(role_id)
    return self.player._data.roles[role_id] ~= nil
end

exports('has_role', function(source, role_id)
    local player = player_registry[source]
    return player and player.roles:has_role(role_id) or false
end)

--- Adds a role to the player.
--- @param role_id string: The ID of the role to add.
--- @param role_rank number: The role rank (rank).
--- @param role_data table|nil: Additional role metadata.
--- @return boolean: True if the role was successfully added.
function Roles:add_role(role_id, role_rank, role_data)
    local shared_roles = keystone.data.roles
    if not shared_roles or not shared_roles[role_id] then debug_log('error', ("Role '%s' not found in shared roles."):format(role_id)) return false end
    local role_info = shared_roles[role_id]
    self.player._data.roles[role_id] = { role_type = role_info.type or 'unknown', rank = role_rank or role_info.default_rank or 0, metadata = role_data or {} }
    self.player:sync_data('roles')
    return true
end

exports('add_role', function(source, role_id, role_rank, role_data)
    local player = player_registry[source]
    return player and player.roles:add_role(role_id, role_rank, role_data) or false
end)

--- Removes a role from the player.
--- @param role_id string: The ID of the role to remove.
--- @return boolean: True if the role was removed, false otherwise.
function Roles:remove_role(role_id)
    if not self.player._data.roles[role_id] then return false end
    self.player._data.roles[role_id] = nil
    self.player:sync_data('roles')
    return true
end

exports('remove_role', function(source, role_id)
    local player = player_registry[source]
    return player and player.roles:remove_role(role_id) or false
end)