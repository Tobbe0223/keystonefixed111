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

--- Check if two rectangles intersect.
--- @param rect1 table: X and Y for rectangle 1.
--- @param rect2 table: X and Y for rectangle 1.
function rectangles_intersect(rect1, rect2)
    return not ( rect1.x2 < rect2.x1 or rect1.x1 > rect2.x2 or rect1.y2 < rect2.y1 or rect1.y1 > rect2.y2 )
end
