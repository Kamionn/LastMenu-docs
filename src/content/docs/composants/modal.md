---
title: Modal / Alert
description: Blocking confirmation dialog — two buttons (confirm / cancel), callback or async style.
order: 4
lastUpdated: 2026-04-14
---

## Opening (callback)

```lua
exports.LastMenu:alert(function(a)
    a:title("Confirm purchase")
    a:message("Buy this item for 500 €?")
    a:confirm("Yes, buy", function()
        -- confirmed
    end)
    a:cancel("Cancel", function()
        -- cancelled (optional)
    end)
end)
```

## Blocking opening (coroutine)

`alert_async` blocks the current coroutine and returns `true` (confirmed) or `false` (cancelled / Escape):

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

## Reusable alert

```lua
local confirmDialog = exports.LastMenu:alert_build(function(a)
    a:title("Delete character")
    a:message("This action is irreversible.")
    a:confirm("Delete", function() deleteCharacter() end)
    a:cancel("Cancel")
end)

-- Later:
confirmDialog.open()
```

---

## Builder methods

| Method | Args | Description |
|---|---|---|
| `a:title(str)` | `string` | Dialog header |
| `a:message(str)` | `string` | Body text |
| `a:confirm(label, cb)` | `string, function` | Main button (accent colored) |
| `a:cancel(label, cb)` | `string, function?` | Secondary button (optional callback) |
| `b:confirm_label(str)` | `string` | *(async mode)* Confirmation button label |
| `b:cancel_label(str)` | `string` | *(async mode)* Cancellation button label |

Both buttons automatically close the modal after triggering the callback.

---

## Behavior

- The modal **blocks the stack** — no other menu can open while it's visible.
- Pressing **Escape** is equivalent to clicking the Cancel button.
- The `cb` of `cancel` is optional. Omitting it simply closes the dialog.
- Alignment (center / top-center / bottom-center) is a user setting (F12).

---

## Exemple de chaînage

Chaîner une confirmation après un formulaire :

```lua
Citizen.CreateThread(function()
    -- Étape 1 : formulaire
    local values = exports.LastMenu:input_async(function(b)
        b:title("Créer un personnage")
        b:field("Prénom", { type = "text", maxlen = 20 })
        b:field("Nom",    { type = "text", maxlen = 20 })
    end)
    if not values then return end

    -- Étape 2 : confirmation
    local ok = exports.LastMenu:alert_async(function(b)
        b:title("Confirmer la création")
        b:message(string.format("Créer le personnage %s %s ?", values[1], values[2]))
        b:confirm_label("Créer")
        b:cancel_label("Retour")
    end)
    if not ok then return end

    TriggerServerEvent('character:create', values[1], values[2])
end)
```
