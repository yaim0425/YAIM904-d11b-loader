---------------------------------------------------------------------------
---[ control.lua ]---
---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Cargar las funciones comunes ]---
---------------------------------------------------------------------------

require("__" .. "YAIM0425-d00b-core" .. "__/control")

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Información del MOD ]---
---------------------------------------------------------------------------

local This_MOD = GMOD.get_id_and_name()
if not This_MOD then return end
GMOD[This_MOD.id] = This_MOD

---------------------------------------------------------------------------

function This_MOD.start()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validación
    if This_MOD.entities then return end

    --- Ejecución de las funciones
    This_MOD.reference_values()
    This_MOD.load_events()

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.reference_values()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    ---- Entities validas
    This_MOD.entities = {
        ["splitter"] = true,
        ["loader-1x1"] = true,
        ["transport-belt"] = true,
        ["underground-belt"] = true
    }

    --- Tipo de inventarios validos
    This_MOD.inventory = {
        [defines.inventory.chest] = true,
        [defines.inventory.lab_input] = true,
        [defines.inventory.furnace_source] = true,
        [defines.inventory.rocket_silo_rocket] = true,
        [defines.inventory.assembling_machine_input] = true
    }

    --- Converción de la direcciones
    This_MOD.dir2vector = {
        [defines.direction.north] = { x = 0, y = -1 },
        [defines.direction.south] = { x = 0, y = 1 },
        [defines.direction.west]  = { x = -1, y = 0 },
        [defines.direction.east]  = { x = 1, y = 0 }
    }

    --- Direcciones con las que funciona
    This_MOD.opposite = {
        [defines.direction.north] = defines.direction.south,
        [defines.direction.south] = defines.direction.north,
        [defines.direction.east]  = defines.direction.west,
        [defines.direction.west]  = defines.direction.east,
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Eventos programados ]---
---------------------------------------------------------------------------

function This_MOD.load_events()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Al crear la entidad
    script.on_event({
        defines.events.on_built_entity,
        defines.events.on_robot_built_entity,
        defines.events.script_raised_built,
        defines.events.script_raised_revive,
        defines.events.on_space_platform_built_entity,
    }, function(event)
        This_MOD.create_entity(GMOD.create_data(event, This_MOD))
    end)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------

function This_MOD.create_entity(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Renombrar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Entity = Data.Event.entity

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not Entity then return end
    if not Entity.valid then return end
    if not GMOD.has_id(Entity.name, This_MOD.id) then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Banderas para a alinear el cargador
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- El cargadro esta metiendo en el inventaio
    local Input = Entity.loader_type == "input"

    --- Entidades delante y atras
    local Front = This_MOD.get_neighbour_entities(Entity,
        Input and This_MOD.opposite[Entity.direction] or Entity.direction --- Belt
    )
    local Back = This_MOD.get_neighbour_entities(Entity,
        Input and Entity.direction or This_MOD.opposite[Entity.direction] --- O/I
    )

    --- Hay algún inventario
    local Front_inventory = This_MOD.has_inventory(Front)
    local Back_inventory = This_MOD.has_inventory(Back)

    --- La entidad tiene la misma dirección
    local Front_direction = This_MOD.is_direction(Front, Entity.direction)
    local Back_direction = This_MOD.is_direction(Back, Entity.direction)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Alinear el cargador
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nada con lo cual alinear
    if not (Front or Back) then return end

    --- Alinear con el inventario
    if Back and Back_inventory then
        if Front and not Front_direction then
            Entity.rotate()
        end
        return
    end

    if Front and Front_inventory then
        Entity.direction = This_MOD.opposite[Entity.direction]
        if Back and Back_direction then
            Entity.rotate()
        end
        return
    end

    --- Alinear con lo que esté atras
    if Back and Back_direction then
        Entity.direction = This_MOD.opposite[Entity.direction]
        Entity.rotate()
        return
    end

    if Back and not Back_direction then
        Entity.direction = This_MOD.opposite[Entity.direction]
        if not This_MOD.is_direction(Back, Entity.direction) then
            if Input then Entity.rotate() end
        end
        return
    end

    --- Alinear con lo que esté delante
    if Front and Front_direction then
        return
    end

    if Front and not Front_direction then
        Entity.rotate()
        if not This_MOD.is_direction(Front, Entity.direction) then
            if not Input then Entity.rotate() end
        end
        return
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Funciones auxiliares ]---
---------------------------------------------------------------------------

function This_MOD.get_neighbour_entities(entity, direction)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Obtener la entidades en la posición
    local Entities = entity.surface.find_entities_filtered({
        position = {
            x = entity.position.x + This_MOD.dir2vector[direction].x,
            y = entity.position.y + This_MOD.dir2vector[direction].y
        }
    })

    --- Filtar las entidades validas
    local Output = {}
    for _, Entity in pairs(Entities) do
        local Flag = This_MOD.entities[Entity.type]
        Flag = Flag or This_MOD.has_inventory({ Entity })
        if Flag then table.insert(Output, Entity) end
    end

    --- Devuelve el resultado, de haberlo
    if #Output > 0 then return Output end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.has_inventory(entities)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    for _, entity in pairs(entities or {}) do
        for id, _ in pairs(This_MOD.inventory) do
            if entity.get_inventory(id) then
                return true
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.is_direction(entities, direction)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    for _, entity in pairs(entities or {}) do
        local Flag = This_MOD.entities[entity.type]
        Flag = Flag and entity.direction == direction
        if Flag then return true end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Iniciar el MOD ]---
---------------------------------------------------------------------------

This_MOD.start()

---------------------------------------------------------------------------
