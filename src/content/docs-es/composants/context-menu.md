---
title: Menú Contextual
description: Menú vertical rico — todos los tipos de items soportados. Reactividad en tiempo real, pestañas, acordeones y submenús.
order: 1
lastUpdated: 2026-04-14
---

## Apertura

```lua
local UI = exports['LastMenu']

UI:context(function(menu)
    menu:title("Mi Menú")
    menu:description("Un menú contextual completo")

    menu:button("Reparar Motor", {
        icon    = "wrench",
        badge   = "500 €",
        confirm_hold = true,
        cb      = function() TriggerServerEvent('garage:repair') end,
    })

    menu:stat("Estado del Motor", {
        value   = function() return GetVehicleEngineHealth(GetVehiclePedIsIn(PlayerPedId(), false)) / 10 end,
        max     = 100,
        icon    = "activity",
        suffix  = "%",
        refresh = 1000,
    })
end)
```

El menú se abre inmediatamente. Se cierra con `Escape` o llamando al callback apropiado.