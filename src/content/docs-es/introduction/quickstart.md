---
title: Inicio Rápido
description: Tu primer menú LastMenu en 5 minutos — context menu, radial menu, input form.
order: 2
lastUpdated: 2026-04-14
---

## Menú Contextual

```lua
local UI = exports['LastMenu']

UI:context(function(menu)
    menu:title("Mi Menú")
    menu:description("Un menú simple")

    menu:button("Haz clic", {
        cb = function() print("¡Clic!") end
    })
end)
```

## Menú Radial

```lua
UI:radial(function(menu)
    menu:title("Acciones")

    menu:button("Reparar", {
        icon = "wrench",
        cb = function() TriggerServerEvent('repair') end
    })

    menu:button("Limpiar", {
        icon = "spray-can",
        cb = function() TriggerServerEvent('clean') end
    })
end)
```

## Formulario de Entrada

```lua
UI:input(function(form)
    form:title("Crear Personaje")
    form:description("Ingresa tu información")

    form:text("Nombre", {
        required = true,
        placeholder = "Juan Pérez"
    })

    form:number("Edad", {
        min = 18,
        max = 100,
        default = 25
    })

    form:submit("Crear", function(data)
        TriggerServerEvent('createCharacter', data)
    end)
end)
```

## Próximos Pasos

- Lee sobre [Componentes](/docs/es/composants) para más tipos de menú
- Explora [Reactivity](/docs/es/avance/reactivite) para actualizaciones en tiempo real
- Configura [Theming](/docs/es/personnalisation/theming) para personalizar la apariencia