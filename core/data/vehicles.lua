return {

    --- @todo Finalise an idea for vehicles in the core? Currently this is place holder. 

    --- @section Compacts

    asbo = { -- Car model name.
        type = 'automobile', -- Vehicle type.
        class = 'compacts', -- Vehicle class.
        label = 'Asbo', -- Readable label.
        brand = 'Maxwell', -- Readable brand label.
        brand_image = 'maxwell.png', -- Brand image.
        vehicle_image = 'asbo.jpg', -- Vehicle image.
        licences_required = { 'car' }, -- Licences required to purchase **placeholder**
        racing_class = 'D', -- Vehicle racing class./
        price = 11500, -- Vehicle price
        storage = { -- Storage data for vehicle.
            trunk = { -- Trunk size.
                grid = { 
                    columns = 6, -- Grid columns.
                    rows = 4 -- Grid rows.
                },
                max_weight = 32000 -- Max trunk weight
            },
            glovebox = { grid = { columns = 3, rows = 2 },  max_weight = 15000 } -- Glove box sizing.
        },
        restrictions = { -- Vehicle restrictions.
            limited = false,  -- Limited edition: false = unlimited, value = limited to value.
            vip = false -- Using utils user vip levels?
        },
        flags = { -- Vehicle flags.
            rear_engine = false, -- )f vehicle is rear engined. 
            arena = false, -- If is arena vehicle; could be good for filtering for survival?
            weaponised = false -- If is weaponised; same as above.
        }
    },

    --- @section Coupes

    --- @section Cycles

    --- @section Muscle

    --- @section Motorcycles

    --- @section Offroad

    --- @section Sedans

    --- @section Sports

    --- @section Sports Classics

    --- @section Super

    --- @section SUVs

    --- @section Utility

    --- @section Vans

    --- @section Boats

    --- @section Helicoptors

    --- @section Planes

    --- @section Commercial

    --- @section Industrial

}
