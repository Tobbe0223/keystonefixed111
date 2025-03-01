--- Waits until a given condition is met or timeout occurs.
--- @param condition function The condition function that should return true when ready.
--- @param timeout number Maximum time to wait in seconds (default: 5 seconds).
--- @param interval number Interval between checks in milliseconds (default: 100ms).
function wait_for(condition, timeout, interval)
    timeout = timeout or 5
    interval = interval or 100
    local elapsed = 0
    while not condition() do
        if elapsed >= timeout * 1000 then return false end
        Wait(interval)
        elapsed = elapsed + interval
    end
    return true
end

--- Parse duration string into seconds.
--- @param str string: The duration string.
function parse_duration(str)
    if not str or str == 'perm' then return nil end
    local number, unit = str:match('^(%d+)([smhdMy])$')
    if not number or not unit then  debug_log('error', 'Invalid duration format:', str) return nil end
    local conversion = {s = 1, m = 60, h = 3600, d = 86400, M = 2592000, y = 31536000}
    local seconds = tonumber(number) * (conversion[unit] or 1)
    return seconds
end

--- Calculates the total weight of default items.
--- @param default_items table: List of default items for new characters.
--- @return number: Total weight of all items.
function calculate_total_item_weight(items)
    local total_weight = 0
    for _, item in pairs(items) do
        local item_data = keystone.data.items[item.id]
        if item_data then
            total_weight = total_weight + (item_data.weight * item.amount)
        end
    end
    return total_weight
end

--- Finds the next available grid position for an item.
--- @param inventory_grid table: The players inventory grid.
--- @param grid_columns number: The number of columns in the grid.
--- @param grid_rows number: The number of rows in the grid.
--- @param item_width number: The width of the item.
--- @param item_height number: The height of the item.
--- @return number, number: The x and y position if found, otherwise nil.
function find_available_grid_position(inventory_grid, grid_columns, grid_rows, item_width, item_height)
    for y = 1, grid_rows do
        for x = 1, grid_columns do
            local fits = true
            for h = 0, item_height - 1 do
                for w = 0, item_width - 1 do
                    local check_x = x + w
                    local check_y = y + h
                    if check_x > grid_columns or check_y > grid_rows or inventory_grid[('%d_%d'):format(check_x, check_y)] then
                        fits = false
                        break
                    end
                end
                if not fits then break end
            end
            if fits then return x, y end
        end
    end
    return nil, nil
end
