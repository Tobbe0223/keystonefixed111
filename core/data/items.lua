return {

    test_item = { -- Unique key.
        id = 'test_item', -- Unique id.
        label = 'Test Item', -- Readable label
        description = { -- Description, you can use single or multiline.
            'Just a test item.',
            'Has no use outside of testing.'
        },
        type = 'test', -- Item type; only really relevant to specify weapons.
        category = 'test', -- Item category, for UI sorting.
        image = 'test_item.png', -- Item image; put images into `ui/assets/images/items`.
        grid = { width = 1, height = 1 }, -- Grid sizing for the item, if you dont want to have to manage sizes set everything to 1x1.
        weight = 300, -- Item weight.
        stackable = 10, -- Stackable limit; Options: true = unlimited, false = not stackable, number = stack limit.
        data = { -- Additional item data
            rarity = 'common', -- Default rarity levels: 'common', 'uncommon', 'rare', 'epic', 'legendary'.
            quality = 100, -- Adding quality or durability will add a progress bar to the item display; no degrade has been implemented yet.
            -- durability = 100 -- Only use quality or durability.. dont use both.
        },
        actions = { -- Item actions performed on hover through inventory.
            use = true, -- Done
            place = true, -- @todo
            drop = true, -- @todo 
            destroy = true, -- @todo 
            repair = true, -- @todo 
            modify = true, -- @todo 
            inspect = true -- @todo 
        }
    },

    cash = {
        id = 'cash',
        label = 'Cash',
        description = {
            'Cash moves everything around me..'
        },
        image = 'cash.png',
        grid = { width = 1, height = 1 },
        weight = 1,
        stackable = true
    },

    dirty_cash = {
        id = 'dirty_cash',
        label = 'Dirty Cash',
        description = {
            'A bunch of dirty cash..',
            'Someone could clean this for you.'
        },
        image = 'dirty_cash.png',
        grid = { width = 1, height = 1 },
        weight = 1,
        stackable = true
    },

    burger = {
        id = 'burger',
        label = 'Burger',
        description = {
            'A delicious and juicy burger.',
            'Can be purchased from general stores.'
        },
        type = 'consumable',
        category = 'food',
        image = 'burger.png',
        grid = { width = 1, height = 1 },
        weight = 300,
        stackable = 10,
        data = {
            rarity = 'common',
            quality = 100
        },
        actions = { use = true, destroy = true }
    },

    water = {
        id = 'water',
        label = 'Water',
        description = {
            'A refreshing bottle of water.',
            'Can be purchased from general stores.'
        },
        type = 'consumable',
        category = 'drinks',
        image = 'water.png',
        grid = { width = 1, height = 1 },
        weight = 300,
        stackable = 10,
        data = {
            rarity = 'common',
            quality = 100
        },
        actions = { use = true, place = true, drop = true, destroy = true, repair = false, modify = false, inspect = false }
    },

    --- @todo weapons are not implemented yet, will do this + ammo a.s.a.p.

    weapon_pistol = {
        id = 'weapon_pistol',
        label = 'Pistol',
        description = {
            'A standard semi-automatic 9mm handgun.',
            'Can be purchased from general stores.'
        },
        type = 'weapon',
        category = 'pistols',
        image = 'weapon_pistol.png',
        grid = { width = 3, height = 2 },
        weight = 1000,
        stackable = false,
        data = {
            ammo = 0,
            ammo_types = { 'ammo_pistol' },
            attachments = {},
            durability = 100
        },
        actions = { use = true, place = true, drop = true, destroy = true, repair = false, modify = false, inspect = false }
    }
}
