---
title: Real-time reactivity
description: Diff/patch polling engine — dynamic labels, reactive visible and disabled without manual render loops.
order: 1
lastUpdated: 2026-04-14
---

## Principle

LastMenu integrates a **polling engine** that monitors functions declared in your builders. When the returned value changes, a **minimal patch** is sent to the NUI — no global re-render, no menu close/reopen.

No `Citizen.Wait(0)` loop is needed in your code.

---

## Dynamic label

Pass a **function** as button label for real-time updates:

```lua
local startTime = GetGameTimer()

UI:context(function(menu)
    menu:title("Live information")

    -- Updated every second
    menu:button(function()
        local elapsed = math.floor((GetGameTimer() - startTime) / 1000)
        return string.format("Open for: %ds", elapsed)
    end, { refresh = 1000 })

    -- Shows player's money
    menu:button(function()
        return "Balance: " .. GetPlayerMoney(PlayerId()) .. " €"
    end, { refresh = 500 })
end)
```

---

## Reactive visibility

```lua
-- Visible only if player is in a vehicle
menu:button("Set cruise control", {
    icon    = "gauge",
    visible = function()
        return GetVehiclePedIsIn(PlayerPedId(), false) ~= 0
    end,
    refresh = 250,
    cb      = function() end,
})
```

---

## Reactive disabling

```lua
-- Disabled during cooldown
local lastUse = 0

menu:button("Use item", {
    icon     = "package",
    disabled = function()
        return (GetGameTimer() - lastUse) < 10000
    end,
    refresh = 250,
    cb      = function()
        lastUse = GetGameTimer()
        -- ...
    end,
})
```

---

## The `refresh` property

`refresh` (ms) controls the evaluation frequency of watcher functions.

| Field | Default | Minimum recommended |
|---|---|---|
| `label` (function) | `500ms` | `100ms` |
| `visible` | `250ms` | `100ms` |
| `disabled` | `250ms` | `100ms` |
| `stat.value` | `500ms` | `100ms` |

Going below `100ms` is possible but not useful — NUI only displays at ~60 FPS.

---

## Reactive `stat` values

The `value` and `max` properties of a `stat` item accept functions:

```lua
menu:stat("Health", {
    value   = function() return GetEntityHealth(PlayerPedId()) - 100 end,
    max     = 100,
    icon    = "heart",
    suffix  = "hp",
    refresh = 500,
})

menu:stat("Engine", {
    value   = function()
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        return veh ~= 0 and GetVehicleEngineHealth(veh) / 10 or 0
    end,
    max     = 100,
    icon    = "activity",
    suffix  = "%",
    refresh = 1000,
})
```

---

## Watcher Safe Mode

If a watcher function throws an error **3 times in a row**, LastMenu enters **Safe Mode** for that watcher:

1. The watcher is **disabled** for 15 seconds.
2. An alert message is printed to console: `[LastMenu] Watcher DISABLED ...`.
3. After 15s, a **recovery attempt** is made.
4. If the error persists, the watcher is disabled again.

**Symptom**: a button's `visible`/`disabled` state stops updating, briefly updates, then stops again.

**Diagnostic** : active `Config.debug = true` ou exécute `/lm_debug` pour voir les stats des watchers.

---

## Anti-pattern : retourner une table

> **Attention** : une fonction watcher qui retourne une **table** au lieu d'un primitif envoie un patch NUI à chaque tick, car la comparaison de tables utilise l'égalité de référence.

```lua
-- MAUVAIS : nouvelle table à chaque tick → patches constants
menu:button('Statut', {
    disabled = function()
        return { locked = isLocked() }  -- table, pas un booléen
    end,
})

-- CORRECT : retourne un primitif
menu:button('Statut', {
    disabled = function() return isLocked() end,
})
```

LastMenu affiche un avertissement console unique quand ce pattern est détecté.

---

## Mécanisme interne

1. Le watcher évalue la fonction de label / valeur.
2. Si le résultat **diffère** de la dernière valeur connue, un patch est construit.
3. Le patch est envoyé via `Bridge.send({ type='patch', id, changes={...} })`.
4. `App.svelte` l'applique en O(1) via une `Map` indexée par item id — pas de re-render global.

Les watchers démarrent à chaque `open()` d'un menu réutilisable et s'arrêtent à la fermeture.
