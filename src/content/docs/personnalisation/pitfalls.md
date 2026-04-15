---
title: Common Pitfalls
description: Frequent anti-patterns when using LastMenu — causes, symptoms and fixes.
order: 4
lastUpdated: 2026-04-14
---

## 1. Watcher returning a table

**Problem** — Comparing tables with `~=` uses reference equality. A function that returns a **new table on every tick** is always seen as "changed", which sends a NUI patch on every polling cycle.

```lua
-- BAD: new table on every tick → constant patches
menu:button('Status', {
    disabled = function()
        return { locked = isLocked() }  -- table, not a boolean!
    end,
})
```

```lua
-- GOOD: returns a primitive
menu:button('Status', {
    disabled = function() return isLocked() end,
})
```

LastMenu logs a one-time warning when this pattern is detected. Check your resource console if you see an abnormally high rate of NUI messages.

---

## 2. Duplicate labels in the same menu

Since v1.0.0, `cb_id`s are derived from the label (slugified) and not from the insertion position. `menu:button('Buy', ...)` always gets the slug `cb_<menu_id>_buy` regardless of order.

If **two items have exactly the same label**, LastMenu automatically appends `_2`, `_3`, etc. — callbacks remain correct, but if one of those items is reactive, the patch will only reach the right item if the order stays stable between rebuilds.

```lua
-- Good: unique labels → stable slugs
menu:button('Buy',  { cb = fn1 })
menu:button('Sell', { cb = fn2 })

-- Works, but "Action_2" gets slug action_2 — keep the order stable
menu:button('Action', { cb = fn1 })
menu:button('Action', { cb = fn2, disabled = function() return onCooldown() end })

-- Best practice: use opts.id to pin an explicit key
menu:button('Action', { id = 'action_buy',  cb = fn1 })
menu:button('Action', { id = 'action_sell', cb = fn2, disabled = function() return onCooldown() end })
```

---

## 3. Calling `*_async` outside a coroutine

`UI:alert_async` and `UI:input_async` call `coroutine.yield()` internally. They **must** be called from a `Citizen.CreateThread`. From an event handler or non-coroutine callback, they log an error and return `nil`/`false` immediately.

```lua
-- BAD: regular event handler (not a coroutine)
AddEventHandler('myEvent', function()
    local ok = exports.LastMenu:alert_async(function(b) ... end)  -- returns false
end)

-- GOOD: wrapped in a thread
AddEventHandler('myEvent', function()
    Citizen.CreateThread(function()
        local ok = exports.LastMenu:alert_async(function(b) ... end)
        if ok then ... end
    end)
end)
```

---

## 4. `visible`/`disabled` watcher returning something other than a boolean

These fields expect a **boolean**. Returning a table, a string, or `nil` prevents the watcher from being registered and logs a warning.

```lua
-- BAD: visible expects a boolean, not a table
menu:button('Buy', { visible = function() return getPlayerData() end })

-- GOOD
menu:button('Buy', { visible = function() return getPlayerData() ~= nil end })
```

---

## 5. `default` vs `value` in input fields

Input fields use `opts.default` (not `opts.value`) for the prefilled value. This matches HTML `<input defaultValue>` semantics — the player can still change it.

```lua
-- GOOD
form:field('Amount', { type = 'number', default = 100 })

-- BAD (silently ignored)
form:field('Amount', { type = 'number', value = 100 })
```

---

## 6. Resource restart with menu open

If a resource stops while a menu is open, LastMenu releases NUI focus and clears the stack in `onResourceStop`. However, if your code calls `Stack.pop()` or `Stack.clear()` from an external resource's `onResourceStop`, the NUI focus may remain stuck — the deferred close message is no longer processed.

**Solution**: close menus before stopping dependent resources, or call `exports.LastMenu:lastmenu_back()` for a clean close.

---

## 7. Calling `UI_Context_Update` without an active context menu

`UI_Context_Update` reads `Stack.peek()`. If the top of the stack is not a context menu (or if the stack is empty), the call does **nothing** — intentional behavior. If your update does not apply, check that `Stack.peek().type == 'context'`.

---

## 8. Watcher Safe Mode — permanent disable

After 3 consecutive errors in a watcher function, LastMenu enters **Safe Mode** for that watcher: disabled for 15 seconds, then a retry attempt. If the error persists, it is disabled again.

**Symptômes** : l'état `visible`/`disabled` d'un bouton cesse de se mettre à jour, fait une brève mise à jour, puis s'arrête à nouveau.

**Diagnostic** : recherche les messages `[LastMenu] Watcher DISABLED` dans la console. Active `Config.debug = true` ou exécute `/lm_debug` pour des statistiques détaillées.

**Causes fréquentes** :
- Accès à `playerData` avant l'initialisation du joueur
- Appels natifs invalides (entité supprimée, ped nil)
- Récursion non intentionnelle dans la fonction watcher

---

## 9. `keep_open` manquant sur le bouton parent d'un sous-menu

Sans `keep_open = true`, le menu parent se ferme **avant** l'ouverture du sous-menu, cassant la stack de navigation.

```lua
-- MAUVAIS : parent se ferme, sous-menu se retrouve seul
menu:button("Options", {
    cb = function()
        UI:context(function(sub) ... end)
    end,
})

-- CORRECT
menu:button("Options", {
    arrow     = true,
    keep_open = true,
    cb        = function()
        UI:context(function(sub) ... end)
    end,
})
```

Avec le helper `menu:submenu(...)`, `keep_open` est positionné automatiquement.

---

## 10. `persist_key` manquant avec label dynamique et cooldown

La clé de persistance du cooldown est dérivée du `label + cooldown` par défaut. Si le label est dynamique (contient un nom de joueur, une variable...), la clé change et le cooldown ne persiste plus correctement entre les sessions.

```lua
-- Problème : label dynamique → persist_key change à chaque rechargement
menu:button("Payer " .. playerName, {
    cooldown = 30000,
    cb       = function() end,
})

-- Solution : spécifier une persist_key stable
menu:button("Payer " .. playerName, {
    cooldown    = 30000,
    persist_key = "pay_player_" .. playerId,
    cb          = function() end,
})
```
