local alignment = {}

--- Retrieves the title for lawfulness level.
--- @param value number: Players lawfulness value.
--- @return string: The lawfulness title.
local function get_lawfulness_title(value)
    for i, entry in ipairs(config.character_alignment.lawfulness_map) do
        if value < entry.threshold then
            return config.character_alignment.lawfulness_map[i - 1].title
        end
    end
    return config.character_alignment.lawfulness_map[#config.character_alignment.lawfulness_map].title
end

alignment.get_lawfulness_title = get_lawfulness_title
exports('get_lawfulness_title', get_lawfulness_title)

--- Retrieves the title for morality level.
--- @param value number: Players morality value.
--- @return string: The morality title.
local function get_morality_title(value)
    for i, entry in ipairs(config.character_alignment.morality_map) do
        if value < entry.threshold then
            return config.character_alignment.morality_map[i - 1].title
        end
    end
    return config.character_alignment.morality_map[#config.character_alignment.morality_map].title
end

alignment.get_morality_title = get_morality_title
exports('get_morality_title', get_morality_title)

return alignment
