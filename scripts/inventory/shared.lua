--- @section Default Vehicle Storages

local DEFAULT_VEHICLE_STORAGES <const> = {
    compact    = { glovebox = { grid = { rows = 5, columns = 5 }, max_weight = 10000 }, trunk = { grid = { rows = 6, columns = 6 }, max_weight = 80000 } },
    sedan      = { glovebox = { grid = { rows = 5, columns = 5 }, max_weight = 15000 }, trunk = { grid = { rows = 7, columns = 7 }, max_weight = 120000 } },
    suv        = { glovebox = { grid = { rows = 5, columns = 5 }, max_weight = 20000 }, trunk = { grid = { rows = 8, columns = 8 }, max_weight = 150000 } },
    coupe      = { glovebox = { grid = { rows = 5, columns = 5 }, max_weight = 15000 }, trunk = { grid = { rows = 6, columns = 6 }, max_weight = 100000 } },
    muscle     = { glovebox = { grid = { rows = 5, columns = 5 }, max_weight = 15000 }, trunk = { grid = { rows = 7, columns = 7 }, max_weight = 120000 } },
    sports     = { glovebox = { grid = { rows = 5, columns = 5 }, max_weight = 20000 }, trunk = { grid = { rows = 6, columns = 6 }, max_weight = 100000 } },
    super      = { glovebox = { grid = { rows = 5, columns = 5 }, max_weight = 25000 }, trunk = { grid = { rows = 5, columns = 5 }, max_weight = 80000 } },
    motorcycle = { glovebox = { grid = { rows = 3, columns = 3 }, max_weight = 10000 }, trunk = { grid = { rows = 4, columns = 4 }, max_weight = 50000 } },
    offroad    = { glovebox = { grid = { rows = 5, columns = 5 }, max_weight = 20000 }, trunk = { grid = { rows = 8, columns = 8 }, max_weight = 150000 } },
    industrial = { glovebox = { grid = { rows = 5, columns = 5 }, max_weight = 30000 }, trunk = { grid = { rows = 9, columns = 9 }, max_weight = 250000 } },
    utility    = { glovebox = { grid = { rows = 5, columns = 5 }, max_weight = 20000 }, trunk = { grid = { rows = 7, columns = 7 }, max_weight = 175000 } },
    van        = { glovebox = { grid = { rows = 5, columns = 5 }, max_weight = 25000 }, trunk = { grid = { rows = 8, columns = 8 }, max_weight = 200000 } },
    service    = { glovebox = { grid = { rows = 5, columns = 5 }, max_weight = 15000 }, trunk = { grid = { rows = 7, columns = 7 }, max_weight = 120000 } },
    emergency  = { glovebox = { grid = { rows = 5, columns = 5 }, max_weight = 20000 }, trunk = { grid = { rows = 7, columns = 7 }, max_weight = 150000 } },
    military   = { glovebox = { grid = { rows = 5, columns = 5 }, max_weight = 30000 }, trunk = { grid = { rows = 10, columns = 10 }, max_weight = 250000 } },
    commercial = { glovebox = { grid = { rows = 5, columns = 5 }, max_weight = 25000 }, trunk = { grid = { rows = 9, columns = 9 }, max_weight = 200000 } }
}

--- Gets vehicle storage data.
--- @param model string: Vehicle model name.
--- @param class string: Vehicle class name.
function get_vehicle_storage(model, class)
    local vehicle_data = keystone.data.vehicles[model]
    if vehicle_data and vehicle_data.storage then
        return vehicle_data.storage
    else
        return DEFAULT_VEHICLE_STORAGES[class] or {
            glovebox = { grid = { rows = 5, columns = 5 }, max_weight = 15000 },
            trunk = { grid = { rows = 6, columns = 6 }, max_weight = 80000 }
        }
    end
end
