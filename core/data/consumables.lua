return {
    burger = {
        close_inventory = true, -- Toggle if using should close inventory.
        remove = 1, -- Amount to remove on use; enter 0 or remove the section to keep item.
        modifiers = { -- Modifiers performed with use.
            statuses = { -- If section is included statuses will be modified.
                health = { add = 5, remove = 0 },
                hunger = { add = 45 },
                thirst = { add = 5 }
            },
            flags = { -- You can specify flags to be toggled on item use.
                is_starving = false 
            },
            injuries = { -- You can specify injuries to apply to players on use.
                head = { add = 5, remove = 0 },
                upper_torso = { add = 0, remove = 5 }  
            }
        },
        animation = { -- You can use this section to run animations when using an item.
            progress = { -- Define progress settings.
                type = 'circle', -- Options: 'bar', 'circle' -- bar is buggy dont use it yet.
                message = 'Eating A Burger..'
            },
            dict = 'mp_player_inteat@burger',
            anim = 'mp_player_int_eat_burger_fp',
            flags = 49,
            duration = 5000,
            freeze = false,
            continuous = false, -- Do not use continuous with props or they will never be removed.
            props = { -- You can define multiple props to attach here.
                {
                    model = 'prop_cs_burger_01',
                    bone = 18905,
                    coords = { x = 0.13, y = 0.05, z = 0.02 },
                    rotation = { x = -50.0, y = 16.0, z = 60.0 },
                    soft_pin = false,
                    collision = false,
                    is_ped = true,
                    rot_order = 1,
                    sync_rot = true
                }
            },
            callback = { -- If section is included a callback will trigger an event when the animation finishes.
                type = 'server',
                name = 'keystone:sv:consumables_animation_finished'
            }
        },
        notify = { -- Notifications on success and fail; remove section to disable.
            success = { type = 'success', header = 'SUCCESS', message = 'You ate a burger!', duration = 3000 },
            failed = { type = 'error', header = 'FAILED', message = 'You stopped eating a burger.', duration = 3000 }
        }
    },

    water = {
        close_inventory = true,
        remove = 1,
        modifiers = {
            statuses = {
                health = { add = 5, remove = 0 },
                hunger = { add = 5, remove = 0 },
                thirst = { add = 45, remove = 0 },
            }
        },
        animation = {
            progress = {
                type = 'circle',
                message = 'Drinking Some Water..'
            },
            dict = 'mp_player_intdrink',
            anim = 'loop_bottle',
            flags = 49,
            duration = 5000,
            freeze = false,
            continuous = false,
            props = {
                {
                    model = 'ba_prop_club_water_bottle',
                    bone = 60309,
                    coords = { x = 0.0, y = 0.0, z = 0.05 },
                    rotation = { x = 0.0, y = 0.0, z = 0.0 },
                    soft_pin = false,
                    collision = false,
                    is_ped = true,
                    rot_order = 1,
                    sync_rot = true
                }
            },
            callback = {
                type = 'server',
                name = 'keystone:sv:consumables_animation_finished'
            }
        },
        notify = {
            success = { type = 'success', header = 'SUCCESS', message = 'You ate a burger!', duration = 3000 },
            failed = { type = 'error', header = 'FAILED', message = 'You stopped eating a burger.', duration = 3000 }
        }
    }
}
