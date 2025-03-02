Inventory = {}

Inventory.__index = Inventory

--- Creates a new Inventory instance for the given player.
--- @param player table: The player instance.
--- @return table: The new Inventory object.
function Inventory.new(player)
    if player.inventory then return player.inventory end
    return setmetatable({ player = player }, Inventory)
end

--- @section Internal Functions

--- Moves an item in the players inventory.
--- @param source_x number: Source X grid position.
--- @param source_y number: Source Y grid position.
--- @param target_x number: Target X grid position.
--- @param target_y number: Target Y grid position.
function Inventory:move_item(source_x, source_y, target_x, target_y)
    local items = self.player._data.inventory.items
    local item_to_move, target_slot
    for key, item in pairs(items) do
        if item.grid.x == source_x and item.grid.y == source_y then
            item_to_move = key
        end
        if item.grid.x == target_x and item.grid.y == target_y then
            target_slot = key
        end
        if item_to_move and target_slot then break end
    end
    if not item_to_move then return false end
    if target_slot then
        local item = items[item_to_move]
        local target_item = items[target_slot]
        if item.id == target_item.id and target_item.stackable then
            local max_stack = target_item.stackable == true and math.huge or target_item.stackable
            local total_qty = target_item.amount + item.amount
            target_item.amount = math.min(total_qty, max_stack)
            if total_qty > max_stack then
                item.amount = total_qty - max_stack
            else
                items[item_to_move] = nil
            end
        else
            items[item_to_move].grid.x, items[item_to_move].grid.y = target_x, target_y
            items[target_slot].grid.x, items[target_slot].grid.y = source_x, source_y
        end
    else
        items[item_to_move].grid.x = target_x
        items[item_to_move].grid.y = target_y
    end
    self.player:sync_data()
    return true
end


--- Finds the next available grid position.
--- @param self table: The Inventory instance.
--- @param item_width number: The width of the item.
--- @param item_height number: The height of the item.
--- @return number, number: The x and y coordinates if found, otherwise nil, nil.
function Inventory:find_available_grid_position(item_width, item_height)
    local inv = self.player._data.inventory
    local cols, rows = inv.grid_columns, inv.grid_rows
    for y = 0, rows - item_height do
        for x = 0, cols - item_width do
            local candidate = { x1 = x, y1 = y, x2 = x + item_width - 1, y2 = y + item_height - 1 }
            local fits = true
            for _, item in pairs(inv.items) do
                local info = keystone.data.items[item.id]
                local iw = (info and info.grid and info.grid.width) or 1
                local ih = (info and info.grid and info.grid.height) or 1
                local existing = { x1 = item.grid.x, y1 = item.grid.y, x2 = item.grid.x + iw - 1, y2 = item.grid.y + ih - 1 }
                if rectangles_intersect(candidate, existing) then
                    fits = false
                    break
                end
            end
            if fits then
                return x, y
            end
        end
    end
    return nil, nil
end

--- @section Export Functions

--- Gets the players inventory.
function Inventory:get_inventory()
    return self.player._data.inventory
end

exports('get_inventory', function(source)
    local player = player_registry[source]
    if player then return player.inventory:get_inventory() end
end)

--- Gets all items in the players inventory.
function Inventory:get_items()
    local items = {}
    for key, item in pairs(self.player._data.inventory.items) do
        local item_data = keystone.data.items[item.id]
        if item_data then
            items[#items + 1] = {
                key = key,
                id = item.id,
                label = item_data.label,
                weight = item_data.weight,
                stackable = item_data.stackable,
                amount = item.amount,
                data = item.data
            }
        end
    end
    return items
end

exports('get_items', function(source)
    local player = player_registry[source]
    if player then return player.inventory:get_items() end
end)

--- Gets a specific item in the players inventory by criteria.
--- @param criteria string|number|table: Can be the items id, key position, data search, or grid position.
function Inventory:get_item(criteria)
    local items = self.player._data.inventory.items
    local key = type(criteria) == 'number' and tostring(criteria) or criteria
    local handlers = {
        ['string'] = function()
            for _, item in pairs(items) do
                if item.id == key then
                    return item
                end
            end
        end,
        ['number'] = function()
            return items[key]
        end,
        ['table'] = function()
            for _, item in pairs(items) do
                if criteria.grid_x and criteria.grid_y and item.grid and item.grid.x == criteria.grid_x and item.grid.y == criteria.grid_y then
                    return item
                elseif criteria.id and item.id == criteria.id then
                    local matching = true
                    for k, v in pairs(criteria) do
                        if k ~= 'id' and (item[k] ~= v and (item.grid[k] ~= v)) then
                            matching = false
                            break
                        end
                    end
                    if matching then
                        return item
                    end
                end
            end
        end        
    }
    return handlers[type(criteria)] and handlers[type(criteria)]()
end

exports('get_item', function(source, criteria)
    local player = player_registry[source]
    if player then return player.inventory:get_item(criteria) end
end)

--- Check if player has an item and a specified amount.
--- @param id string: Item ID to find.
--- @param amount number: Amount required.
function Inventory:has_item(id, amount)
    amount = amount or 1
    local total = 0
    for _, item in pairs(self.player._data.inventory.items) do
        if item.id == id then
            total = total + item.amount
            if total >= amount then return true end
        end
    end
    return false
end

exports('has_item', function(source, id, amount)
    local player = player_registry[source]
    if player then return player.inventory:has_item(id, amount) end
end)

--- Adds an item to the player's inventory.
--- @param id string: The item ID.
--- @param amount number: The total amount to add.
--- @param data table: Optional item metadata.
--- @param grid_x number|nil: Optional X coordinate in the grid.
--- @param grid_y number|nil: Optional Y coordinate in the grid.
--- @return boolean: True if the item was successfully added, false otherwise.
function Inventory:add_item(id, amount, data, grid_x, grid_y)
    local item_data = keystone.data.items[id]
    if not item_data then return false end
    amount, data = amount or 1, data or {}
    local width = (item_data.grid and item_data.grid.width) or 1
    local height = (item_data.grid and item_data.grid.height) or 1
    local inv = self.player._data.inventory
    local total_weight = amount * item_data.weight
    if inv.weight + total_weight > inv.max_weight then return false end
    local remaining = amount
    local items = inv.items
    if item_data.stackable then
        for _, item in pairs(items) do
            if item.id == id then
                local max_stack = (item_data.stackable == true) and math.huge or item_data.stackable
                local merge = math.min(remaining, max_stack - item.amount)
                if merge > 0 then
                    item.amount = item.amount + merge
                    remaining = remaining - merge
                    inv.weight = inv.weight + merge * item_data.weight
                    if remaining <= 0 then
                        self.player:sync_data()
                        return true
                    end
                end
            end
        end
    end
    while remaining > 0 do
        local x, y = grid_x, grid_y
        if not x or not y then x, y = self:find_available_grid_position(width, height) end
        if not x or not y then
            self.player:sync_data()
            return false
        end
        local add_amount = 1
        if item_data.stackable then
            local max_stack = (item_data.stackable == true) and math.huge or item_data.stackable
            add_amount = math.min(remaining, max_stack)
        end
        local next_key = 0
        for key, _ in pairs(items) do
            local num = tonumber(key)
            if num and num > next_key then next_key = num end
        end
        local new_key = tostring(next_key + 1)
        items[new_key] = { id = id, amount = add_amount, grid = { x = x, y = y }, is_hotbar = false, hotbar_slot = '' }
        inv.weight = inv.weight + add_amount * item_data.weight
        remaining = remaining - add_amount
    end
    self.player:sync_data()
    return true
end

exports('add_item', function(source, id, amount, data)
    local player = player_registry[source]
    if player then return player.inventory:add_item(id, amount, data) end
end)

--- Removes an item in the players inventory by criteria.
--- @param critera  string|number|table: You can use the items id, key position, data search, or grid position.
--- @param amount number: Amount to remove.
function Inventory:remove_item(criteria, amount)
    if not amount or amount <= 0 then return false end
    local item = self:get_item(criteria)
    if not item then return false end
    local item_data = keystone.data.items[item.id]
    if not item_data then return false end
    local to_remove = math.min(item.amount, amount)
    item.amount = item.amount - to_remove
    self.player._data.inventory.weight = self.player._data.inventory.weight - (to_remove * item_data.weight)
    if item.amount <= 0 then
        for key, inv_item in pairs(self.player._data.inventory.items) do
            if inv_item == item then
                self.player._data.inventory.items[tostring(key)] = nil
                break
            end
        end
    end
    self.player:sync_data()
    return true
end

exports('remove_item', function(source, criteria, amount)
    local player = player_registry[source]
    if player then return player.inventory:remove_item(criteria, amount) end
end)

--- Updates and items data.
--- @param critera  string|number|table: You can use the items id, key position, data search, or grid position.
--- @param updates table: The new updated data to apply to item.
function Inventory:update_item_data(criteria, updates)
    local item = self:get_item(criteria)
    if not item then return false end
    for key, value in pairs(updates) do
        item.data[key] = value
    end
    self.player:sync_data()
    return true
end

exports('update_item_data', function(source, criteria, updates)
    local player = player_registry[source]
    if player then return player.inventory:update_item_data(criteria, updates) end
end)
