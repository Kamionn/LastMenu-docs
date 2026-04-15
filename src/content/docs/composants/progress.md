---
title: Progress Bar
description: Timer progress bar — the timer runs NUI-side without Lua polling. Supports ped animation, attached prop and per-tick callback.
order: 6
lastUpdated: 2026-04-14
---

## Simple opening

```lua
exports.LastMenu:progress(function(p)
    p:label("Loading data...")
    p:duration(5000)
    p:cancel(true)   -- Escape / cancel button is available
    p:onComplete(function()
        -- triggered when bar reaches 100%
    end)
    p:onCancel(function()
        -- triggered if player cancels
    end)
end)
```

## Reusable bar

```lua
local bar = exports.LastMenu:progress_build(function(p)
    p:label("Manufacturing in progress...")
    p:duration(8000)
    p:cancel(false)
    p:onComplete(function() giveCraftedItem() end)
end)

bar.open()    -- start
bar.close()   -- interrupt programmatically (doesn't trigger onComplete/onCancel)
```

---

## Builder methods

| Method | Args | Description |
|---|---|---|
| `p:label(str)` | `string` | Text displayed above the bar |
| `p:duration(ms)` | `number` | Total duration in milliseconds |
| `p:cancel(bool)` | `bool` | Can player cancel? (default: `false`) |
| `p:onComplete(cb)` | `function` | Called when bar fills naturally |
| `p:onCancel(cb)` | `function` | Called if player cancels |
| `p:icon(str)` | `string` | Lucide icon displayed next to label |
| `p:cb_tick(cb)` | `function(pct)` | Called every ~100ms with current % (0–100) |
| `p:anim(opts)` | `table` | Plays ped animation during duration |
| `p:prop(opts)` | `table` | Attaches prop to ped during duration |

---

## Position

Configurable in User Settings (F12):

| Preset | Location |
|---|---|
| `bottom-center` | Default — HUD bar style |
| `top-center` | Top of screen |
| `bottom-left` | Bottom-left corner |
| `bottom-right` | Bottom-right corner |

---

## Side effects (v1.0.0)

### Icon

```lua
p:label("Manufacturing...")
p:icon("hammer")
```

### `cb_tick` — per-interval progress

Called every ~100ms. Useful for partial rewards, sounds, or server sync:

```lua
p:cb_tick(function(pct)
    if pct >= 50 and not halfway then
        halfway = true
        TriggerServerEvent('myCraft:halfwayDone')
    end
end)
```

### `anim` — ped animation

Animation is automatically stopped on completion, cancellation or closure:

```lua
p:anim({
    dict  = "amb@world_human_welding@male@base",
    clip  = "base",
    flag  = 1,       -- AnimationFlag (1 = loop)
    speed = 1.0,     -- optional (default: 1.0)
    blend = 0.0,     -- optional blendInSpeed
})
```

### `prop` — attached object

Object is detached and deleted automatically at the end:

```lua
p:prop({
    model  = "prop_tool_torch",
    bone   = 57005,                     -- ped bone index (57005 = right hand)
    offset = vector3(0.12, 0.03, 0.0),
    rot    = vector3(0.0, 0.0, 0.0),
})
```

---

## Complete example — Welding

```lua
exports.LastMenu:progress(function(p)
    p:label("Welding in progress...")
    p:icon("zap")
    p:duration(8000)
    p:cancel(true)
    p:anim({ dict = "amb@world_human_welding@male@base", clip = "base", flag = 1 })
    p:prop({ model = "prop_tool_torch", bone = 57005, offset = vector3(0.12, 0.03, 0) })
    p:cb_tick(function(pct)
        -- checkpoint sound every 25%
        if pct % 25 < 1 then
            PlaySoundFrontend(-1, "CHECKPOINT_NORMAL", "HUD_MINI_GAME_SOUNDSET", true)
        end
    end)
    p:onComplete(function()
        giveCraftedItem()
        exports.LastMenu:notify(function(n) n:message("Welding completed!") n:type("success") end)
    end)
    p:onCancel(function()
        exports.LastMenu:notify(function(n) n:message("Welding cancelled.") n:type("warning") end)
    end)
end)
```

---

## Behavior

- While a bar is open, it **owns the stack** — no other menu can open.
- Utilise `cancel(false)` pour les actions obligatoires (craft, interactions). Utilise `cancel(true)` pour les tâches interruptibles.
- La fermeture programmatique via `bar.close()` ne déclenche **ni** `onComplete` **ni** `onCancel`.
- Les side effects `anim` et `prop` sont nettoyés automatiquement, quelle que soit la façon dont la barre se ferme.
