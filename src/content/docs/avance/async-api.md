---
title: Async API (coroutine-style)
description: input_async and alert_async — block the current coroutine like ox_lib's lib.inputDialog. Essential for multi-step flows.
order: 2
lastUpdated: 2026-04-14
---

## Principle

`input_async` and `alert_async` call `coroutine.yield()` internally. They **block the current coroutine** until the player confirms or cancels.

> **Absolute constraint**: these functions must be called from a `Citizen.CreateThread`. From a `RegisterCommand` or `AddEventHandler` without a thread, they immediately return `nil`/`false` and no UI is displayed.

```lua
-- BAD: AddEventHandler without coroutine
AddEventHandler('myEvent', function()
    local ok = exports.LastMenu:alert_async(...)  -- returns false, nothing displays
end)

-- CORRECT: wrapped in a thread
AddEventHandler('myEvent', function()
    Citizen.CreateThread(function()
        local ok = exports.LastMenu:alert_async(...)
        if ok then ... end
    end)
end)
```

---

## input_async

Opens a multi-field form and blocks until confirmation or cancellation.

**Returns**: `table` (1-indexed values) if confirmed, `nil` if cancelled.

```lua
Citizen.CreateThread(function()
    local values = exports.LastMenu:input_async(function(b)
        b:title("Bank transfer")
        b:confirm_label("Send")
        b:cancel_label("Cancel")
        b:field("Recipient", { type = "text",   placeholder = "Player name" })
        b:field("Amount",    { type = "number", min = 1, max = 100000 })
        b:field("Reason",    { type = "text",   maxlen = 50 })
    end)

    if not values then
        print("Transfer cancelled.")
        return
    end

    -- values[2] is already cast to number
    TriggerServerEvent('bank:transfer', values[1], values[2], values[3])
end)
```

---

## alert_async

Opens a confirmation dialog and blocks until player response.

**Returns**: `true` if confirmed, `false` if cancelled / Escape.

```lua
Citizen.CreateThread(function()
    local confirmed = exports.LastMenu:alert_async(function(b)
        b:title("Reset account?")
        b:message("All progress will be lost. This action is irreversible.")
        b:confirm_label("Reset")
        b:cancel_label("Cancel")
    end)

    if confirmed then
        TriggerServerEvent('account:reset')
    end
end)
```

---

## Multi-step chaining

The main benefit of the async API is **chaining** — a sequence of forms and confirmations readable as a linear flow, without nested callbacks:

```lua
Citizen.CreateThread(function()
    -- Step 1: character input
    local values = exports.LastMenu:input_async(function(b)
        b:title("Create character")
        b:field("First name", { type = "text", maxlen = 20 })
        b:field("Last name",  { type = "text", maxlen = 20 })
        b:field("Age",        { type = "number", min = 18, max = 80 })
    end)
    if not values then return end

    -- Step 2: confirmation
    local ok = exports.LastMenu:alert_async(function(b)
        b:title("Confirm creation")
        b:message(string.format(
            "Create character %s %s (%s years old)?",
            values[1], values[2], values[3]
        ))
        b:confirm_label("Create")
        b:cancel_label("Back")
    end)
    if not ok then return end

    -- Step 3: server action
    TriggerServerEvent('character:create', values[1], values[2], values[3])

    exports.LastMenu:notify(function(n)
        n:message("Character created successfully!")
        n:type("success")
    end)
end)
```

---

## Quick reference

| Function | Return if confirmed | Return if cancelled |
|---|---|---|
| `input_async(fn)` | `table` (1-indexed values) | `nil` |
| `alert_async(fn)` | `true` | `false` |

---

## Différence avec le style callback

| Critère | Style callback `input(fn)` | Style async `input_async(fn)` |
|---|---|---|
| Nécessite un thread | Non | Oui (`Citizen.CreateThread`) |
| Lisibilité du flux | Callbacks imbriqués | Linéaire (comme un script synchrone) |
| Chaînage multi-étapes | Possible mais complexe | Naturel |
| Retour de valeur | Via le callback | Via `local values = ...` |
