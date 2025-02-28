Inventory = {}

Inventory.__index = Inventory

--- Creates a new Inventory instance for the given player.
--- @param player table: The player instance.
--- @return table: The new Inventory object.
function Inventory.new(player)
    if player.inventory then return player.inventory end
    return setmetatable({ player = player }, Inventory)
end

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
--- @param critera  string|number|table: You can use the items id, key position, or data search.
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
                if item.data then
                    local matching = true
                    for k, v in pairs(criteria) do
                        if item.data[k] ~= v then
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

--- Adds an item to the players inventory, placing it in the first available grid space.
--- @param id string: The item ID.
--- @param amount number: The amount of the item.
--- @param data table: Additional item metadata.
--- @return boolean: Returns true if the item was successfully added, false otherwise.
function Inventory:add_item(id, amount, data)
    local item_data = keystone.data.items[id]
    if not item_data then return false end
    amount, data = amount or 1, data or {}
    local item_width = item_data.grid and item_data.grid.width or 1
    local item_height = item_data.grid and item_data.grid.height or 1
    local total_weight = amount * item_data.weight
    if self.player._data.inventory.weight + total_weight > self.player._data.inventory.max_weight then  return false  end
    local remaining_amount = amount
    local inventory_grid = self.player._data.inventory.items
    local grid_columns = self.player._data.inventory.grid_columns
    local grid_rows = self.player._data.inventory.grid_rows
    if item_data.stackable then
        for _, item in pairs(inventory_grid) do
            if item.id == id then
                local max_stack = item_data.stackable == true and math.huge or item_data.stackable
                local addable = math.min(remaining_amount, max_stack - item.amount)
                if addable > 0 then
                    item.amount = item.amount + addable
                    self.player._data.inventory.weight = self.player._data.inventory.weight + (addable * item_data.weight)
                    remaining_amount = remaining_amount - addable
                    if remaining_amount <= 0 then break end
                end
            end
        end
    end
    while remaining_amount > 0 do
        local x, y = find_available_grid_position(inventory_grid, grid_columns, grid_rows, item_width, item_height)
        if not x or not y then return false end
        local add_amount = item_data.stackable and math.min(remaining_amount, item_data.stackable == true and remaining_amount or item_data.stackable) or 1
        local next_index = tostring(#inventory_grid + 1)
        inventory_grid[next_index] = { id = id, amount = add_amount, grid = { x = x, y = y }, is_hotbar = false, hotbar_slot = '' }
        self.player._data.inventory.weight = self.player._data.inventory.weight + (add_amount * item_data.weight)
        remaining_amount = remaining_amount - add_amount
    end
    self.player:sync_data()
    return true
end

exports('add_item', function(source, id, amount, data)
    local player = player_registry[source]
    if player then return player.inventory:add_item(id, amount, data) end
end)

--- Removes an item in the players inventory by criteria.
--- @param critera  string|number|table: You can use the items id, key position, or data search.
--- @param amount number: Amount to remove.
function Inventory:remove_item(criteria, amount)
    if not amount or amount <= 0 then return false end
    local items = self.player._data.inventory.items
    if not items or next(items) == nil then return false end
    local handlers = {
        ['string'] = function(item, crit) return item.id == crit end,
        ['number'] = function(item, crit, key) return tostring(key) == tostring(crit) end,
        ['table'] = function(item, crit)
            for k, v in pairs(crit) do
                if not item.data or item.data[k] ~= v then
                    return false
                end
            end
            return true
        end
    }
    local item_found = false
    for key, item in pairs(items) do
        local match = handlers[type(criteria)] and handlers[type(criteria)](item, criteria, key)
        if match then
            item_found = true
            local item_data = keystone.data.items[item.id]
            if not item_data then
                break
            end
            local to_remove = math.min(item.amount, amount)
            item.amount -= to_remove
            self.player._data.inventory.weight -= to_remove * item_data.weight
            if item.amount <= 0 then
                items[tostring(key)] = nil
            end
            amount -= to_remove
            if amount <= 0 then
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

--- Updates and items data.
--- @param critera  string|number|table: You can use the items id, key position, or data search.
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
