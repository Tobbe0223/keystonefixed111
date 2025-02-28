return {
    civilian = { -- Unique key.
        id = 'civilian', -- Unique id.
        type = 'civ', -- Type of role; these can be whatever you want e.g., 'job', 'gang', 'faction'.
        label = 'Civilian', -- Readable label.
        image = 'https://placehold.co/64x64', -- Image displayed in UI.
        flags = { -- Flags for the role; currently not implemented; idea is ones with the flags can be assigned / removed from things like job centers? 
            can_assign = true, -- @todo
            can_remove = true -- @todo
        },
        ranks = { -- Ranks for the role
            ['0'] = {
                label = 'None' -- Readable lable
            }
        }
    },

    police = {
        id = 'police',
        type = 'job',
        label = 'Police Officer',
        image = 'https://placehold.co/64x64',
        flags = {
            can_assign = false,
            can_remove = false
        },
        ranks = {
            ['0'] = {
                label = 'Recruit'
            }
        }
    },

    ballas = {
        id = 'ballas',
        type = 'gang',
        label = 'Ballas',
        image = 'https://placehold.co/64x64',
        flags = {
            can_assign = true,
            can_remove = true
        },
        ranks = {
            ['0'] = {
                label = 'Shotcaller'
            }
        }
    }
}
