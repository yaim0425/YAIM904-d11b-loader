---------------------------------------------------------------------------
---[ data-final-fixes.lua ]---
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

    --- Valores de la referencia
    This_MOD.reference_values()

    --- Obtener los elementos
    This_MOD.get_elements()

    --- Modificar los elementos
    for _, spaces in pairs(This_MOD.to_be_processed) do
        for _, space in pairs(spaces) do
            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

            --- Crear los elementos
            This_MOD.create_item(space)
            This_MOD.create_entity(space)
            This_MOD.create_recipe(space)
            This_MOD.create_tech(space)

            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.reference_values()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Contenedor de los elementos que el MOD modoficará
    This_MOD.to_be_processed = {}

    --- Validar si se cargó antes
    if This_MOD.setting then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en todos los MODs
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cargar la configuración
    This_MOD.setting = GMOD.setting[This_MOD.id] or {}

    --- Imagenes del mod
    This_MOD.path_graphics = "__" .. This_MOD.prefix .. This_MOD.name .. "__/graphics/"

    This_MOD.icon_graphics = {
        base = This_MOD.path_graphics .. "icon-base.png",
        mask = This_MOD.path_graphics .. "icon-mask.png"
    }

    This_MOD.tech_graphics = {
        base = This_MOD.path_graphics .. "tech-base.png",
        mask = This_MOD.path_graphics .. "tech-mask.png"
    }

    This_MOD.entity_graphics = {
        base = This_MOD.path_graphics .. "entity-base.png",
        mask = This_MOD.path_graphics .. "entity-mask.png",
        back = This_MOD.path_graphics .. "entity-back.png",
        shadow = This_MOD.path_graphics .. "entity-shadow.png"
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en este MOD
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Entidad de referencia
    This_MOD.loader = data.raw["loader-1x1"]["loader-1x1"]

    --- Texto de referencia
    This_MOD.under = "underground-belt"
    This_MOD.subgroup = This_MOD.prefix .. This_MOD.name
    This_MOD.to_find = string.gsub(This_MOD.under, "%-", "%%-")

    --- Colores a usar
    This_MOD.colors = {
        --- Base
        [""]                       = { r = 210, g = 180, b = 080 },
        ["fast-"]                  = { r = 210, g = 060, b = 060 },
        ["express-"]               = { r = 080, g = 180, b = 210 },
        ["turbo-"]                 = { r = 160, g = 190, b = 080 },

        --- Factorio+
        ["basic-"]                 = { r = 185, g = 185, b = 185 },
        ["supersonic-"]            = { r = 213, g = 041, b = 209 },

        --- Krastorio 2
        ["kr-advanced-"]           = { r = 160, g = 190, b = 080 },
        ["kr-superior-"]           = { r = 213, g = 041, b = 209 },

        --- Space Exploration
        ["se-space-"]              = { r = 200, g = 200, b = 200 },
        ["se-deep-space--black"]   = { r = 000, g = 000, b = 000 },
        ["se-deep-space--white"]   = { r = 255, g = 255, b = 255 },
        ["se-deep-space--red"]     = { r = 255, g = 000, b = 000 },
        ["se-deep-space--magenta"] = { r = 255, g = 000, b = 255 },
        ["se-deep-space--blue"]    = { r = 000, g = 000, b = 255 },
        ["se-deep-space--cyan"]    = { r = 000, g = 255, b = 255 },
        ["se-deep-space--green"]   = { r = 000, g = 255, b = 000 },
        ["se-deep-space--yellow"]  = { r = 255, g = 255, b = 000 },
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Cambios del MOD ]---
---------------------------------------------------------------------------

function This_MOD.get_elements()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Función para analizar cada entidad
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function valide_entity(item, entity)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Validar el item
        if not item then return end
        if GMOD.is_hidde(item) then return end

        --- Validar el tipo
        if GMOD.is_hidde(entity) then return end

        --- Procesar el nombre
        local That_MOD =
            GMOD.get_id_and_name(entity.name) or
            { ids = "-", name = entity.name }

        --- Identificar el tier
        local Tier = string.gsub(That_MOD.name, This_MOD.to_find, "")
        if not This_MOD.colors[Tier] then return end

        --- Validar si ya fue procesado
        local Name = string.gsub(That_MOD.name, This_MOD.to_find, "loader")
        Name =
            GMOD.name .. That_MOD.ids ..
            This_MOD.id .. "-" ..
            Name

        if GMOD.entities[Name] ~= nil then return end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Valores para el proceso
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Space = {}
        Space.item = item
        Space.entity = entity
        Space.name = Name

        Space.belt = string.gsub(That_MOD.name, This_MOD.to_find, "transport-belt")
        Space.tech = GMOD.get_technology(GMOD.recipes[Space.belt])

        Space.recipe = GMOD.recipes[Space.item.name]
        Space.recipe = Space.recipe and Space.recipe[1] or nil

        Space.color = This_MOD.colors[Tier]

        Space.localised_name = {
            "",
            { "entity-name.loader" },
            " - ",
            { "entity-name." .. Space.belt }
        }

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Guardar la información
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        This_MOD.to_be_processed[entity.type] = This_MOD.to_be_processed[entity.type] or {}
        This_MOD.to_be_processed[entity.type][entity.name] = Space

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Preparar los datos a usar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    for _, entity in pairs(data.raw[This_MOD.under]) do
        valide_entity(GMOD.get_item_create(entity, "place_result"), entity)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------

function This_MOD.create_item(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.item then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Item = GMOD.copy(space.item)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Item.name = space.name

    --- Apodo y descripción
    Item.localised_name = space.localised_name
    Item.localised_description = { "" }

    --- Entidad a crear
    Item.place_result = space.name

    --- Actualizar el icono
    Item.icons = {
        { icon = This_MOD.icon_graphics.base },
        { icon = This_MOD.icon_graphics.mask, tint = space.color },
    }

    --- Actualizar Order
    local Order = tonumber(Item.order) + 2 * (10 ^ (#Item.order - 1))
    Item.order = GMOD.pad_left_zeros(#Item.order, Order)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Item)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_entity(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.entity then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Entity = GMOD.copy(space.entity)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Entity.name = space.name

    --- Apodo y descripción
    Entity.localised_name = space.localised_name
    Entity.localised_description = { "" }

    --- Cambiar el tipo
    Entity.type = This_MOD.loader.type

    --- Espacios para el filtrado
    Entity.filter_count = 5

    --- Elimnar propiedades inecesarias
    Entity.factoriopedia_simulation = nil

    --- Actualizar el icono
    Entity.icons = {
        { icon = This_MOD.icon_graphics.base },
        { icon = This_MOD.icon_graphics.mask, tint = space.color },
    }

    --- Cambiar la image
    Entity.structure = {
        back_patch = {
            sheet = {
                filename = This_MOD.entity_graphics.back,
                priority = "extra-high",
                shift = { 0, 0 },
                height = 96,
                width = 96,
                scale = 0.5
            }
        },
        direction_in = {
            sheets = {
                {
                    draw_as_shadow = true,
                    filename = This_MOD.entity_graphics.shadow,
                    priority = "medium",
                    shift = { 0.5, 0 },
                    height = 96,
                    width = 144,
                    scale = 0.5
                },
                {
                    filename = This_MOD.entity_graphics.base,
                    priority = "extra-high",
                    shift = { 0, 0 },
                    height = 96,
                    width = 96,
                    scale = 0.5
                },
                {
                    filename = This_MOD.entity_graphics.mask,
                    priority = "extra-high",
                    shift = { 0, 0 },
                    height = 96,
                    width = 96,
                    scale = 0.5,
                    tint = space.color
                }
            }
        },
        direction_out = {
            sheets = {
                {
                    draw_as_shadow = true,
                    filename = This_MOD.entity_graphics.shadow,
                    priority = "medium",
                    shift = { 0.5, 0 },
                    height = 96,
                    width = 144,
                    scale = 0.5,
                },
                {
                    filename = This_MOD.entity_graphics.base,
                    priority = "extra-high",
                    shift = { 0, 0 },
                    height = 96,
                    width = 96,
                    scale = 0.5,
                    y = 96,
                },
                {
                    filename = This_MOD.entity_graphics.mask,
                    priority = "extra-high",
                    shift = { 0, 0 },
                    height = 96,
                    width = 96,
                    scale = 0.5,
                    tint = space.color,
                    y = 96
                }
            }
        }
    }

    --- Objeto a minar
    Entity.minable.results = { {
        type = "item",
        name = space.name,
        amount = 1
    } }

    --- Siguiente tier
    Entity.next_upgrade = (function()
        --- Validación
        if not Entity.next_upgrade then return end

        --- Procesar el nombre
        local That_MOD =
            GMOD.get_id_and_name(Entity.next_upgrade) or
            { ids = "-", name = Entity.next_upgrade }

        --- Identificar el tier
        local Tier = string.gsub(That_MOD.name, This_MOD.to_find, "")
        if not This_MOD.colors[Tier] then return end

        --- Nombre despues del aplicar el MOD
        local New_name = string.gsub(That_MOD.name, This_MOD.to_find, "loader")
        New_name =
            GMOD.name .. That_MOD.ids ..
            This_MOD.id .. "-" ..
            New_name

        --- La entidad ya existe
        if GMOD.entities[New_name] ~= nil then
            return New_name
        end

        --- La entidad existirá
        for _, Spaces in pairs(This_MOD.to_be_processed) do
            for _, Space in pairs(Spaces) do
                if Space.entity.name == Entity.next_upgrade then
                    return New_name
                end
            end
        end
    end)()

    --- Distancia del contenedor
    Entity.container_distance = 1

    --- Tamaño del apilable a aplicar
    Entity.max_belt_stack_size = Entity.max_belt_stack_size or 10

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Entity)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_recipe(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.recipe then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Recipe = GMOD.copy(space.recipe)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Recipe.name = space.name

    --- Apodo y descripción
    Recipe.localised_name = space.localised_name
    Recipe.localised_description = { "" }

    --- Elimnar propiedades inecesarias
    Recipe.main_product = nil

    --- Cambiar icono
    Recipe.icons = {
        { icon = This_MOD.icon_graphics.base },
        { icon = This_MOD.icon_graphics.mask, tint = space.color },
    }

    --- Habilitar la receta
    Recipe.enabled = space.tech == nil

    --- Ingredientes
    for _, ingredient in pairs(Recipe.ingredients) do
        ingredient.name = (function(name)
            --- Validación
            if not name then return end

            --- Procesar el nombre
            local That_MOD =
                GMOD.get_id_and_name(name) or
                { ids = "-", name = name }

            --- Identificar el tier
            local Tier = string.gsub(That_MOD.name, This_MOD.to_find, "")
            if not This_MOD.colors[Tier] then return end

            --- Nombre despues del aplicar el MOD
            local New_name = string.gsub(That_MOD.name, This_MOD.to_find, "loader")
            New_name =
                GMOD.name .. That_MOD.ids ..
                This_MOD.id .. "-" ..
                New_name

            --- La entidad ya existe
            if GMOD.entities[New_name] ~= nil then
                return New_name
            end

            --- La entidad existirá
            for _, Spaces in pairs(This_MOD.to_be_processed) do
                for _, Space in pairs(Spaces) do
                    if Space.entity.name == name then
                        return New_name
                    end
                end
            end
        end)(ingredient.name) or ingredient.name
    end

    --- Resultados
    Recipe.results = { {
        type = "item",
        name = space.name,
        amount = 1
    } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Recipe)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_tech(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.tech then return end
    if data.raw.technology[space.name .. "-tech"] then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Tech = GMOD.copy(space.tech)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Tech.name = space.name .. "-tech"

    --- Apodo y descripción
    Tech.localised_name = space.localised_name
    Tech.localised_description = { "" }

    --- Cambiar icono
    Tech.icons = {
        { icon = This_MOD.tech_graphics.base, icon_size = 128 },
        { icon = This_MOD.tech_graphics.mask, tint = space.color, icon_size = 128 },
    }

    --- Tech previas
    Tech.prerequisites = {}
    for _, ingredient in pairs(data.raw.recipe[space.name].ingredients) do
        local tech = GMOD.get_technology(GMOD.recipes[ingredient.name])
        if tech and not GMOD.get_key(Tech.prerequisites, tech.name) then
            table.insert(Tech.prerequisites, tech.name)
        end
    end

    --- Efecto de la tech
    Tech.effects = { {
        type = "unlock-recipe",
        recipe = space.name
    } }

    --- Tech se activa con una fabricación
    if Tech.research_trigger then
        Tech.research_trigger = {
            type = "craft-item",
            item = space.belt,
            count = 1
        }
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Tech)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Iniciar el MOD ]---
---------------------------------------------------------------------------

This_MOD.start()

---------------------------------------------------------------------------
