---
title: Context Menu
description: Vertical context menu — LastMenu's main component. Supports all item types, real-time reactivity, tabs, accordions, sub-menus, keyboard navigation and drag positioning.
order: 1
lastUpdated: 2026-04-20
---

## Opening

```lua
local UI = exports['LastMenu']

UI:context(function(menu)
    menu:title("My Menu")
    menu:button("Click", { cb = function() print("clicked") end })
end)
```

The menu opens immediately. It closes on `Escape` or when a callback closes it.

---

## General Options

These methods are placed at the **top of the builder**, before items.

| Method | Type | Default | Description |
|---|---|---|---|
| `menu:title(str)` | string | `''` | Title displayed in the header |
| `menu:banner(url)` | string | nil | Image above the title (`https://` or `nui://`) |
| `menu:description(txt)` | string | nil | Subtitle displayed under the title |
| `menu:animation(anim)` | string | `'slideLeft'` | Opening animation: `'slideLeft'` `'slideRight'` `'fade'` `'scale'` |
| `menu:nav(mode)` | string | `'both'` | Navigation mode: `'mouse'` `'keyboard'` `'both'` |
| `menu:search()` | — | — | Force display of the search bar |
| `menu:page_size(n)` | number | 20 | Items per page (automatic pagination beyond). Ignored when `scroll()` is set. |
| `menu:scroll()` | — | — | Disable pagination — native scroll on all items. Mutually exclusive with `page_size()`. |
| `menu:cancelable(v)` | bool | `true` | Set to `false` to prevent Escape from closing this menu. |

### Scroll Mode

Use `menu:scroll()` for long lists where pagination creates friction:

```lua
UI:context(function(menu)
    menu:title("Inventory")
    menu:scroll()  -- all items visible, container scrolls

    for i = 1, 50 do
        menu:button("Item #" .. i, { cb = function() end })
    end
end)
```

> Keyboard navigation (`↑` / `↓`) scrolls the container automatically to keep the focused item visible.

---

## Item Types

### button

The most common item type. Supports icons, badges, hotkeys, gradient, hold-to-confirm, cooldown and preview panel.

```lua
menu:button(label, opts)
```

| Option | Type | Description |
|---|---|---|
| `icon` | string | Lucide icon name (`"wrench"`, `"car"`, `"zap"`) |
| `color` | string/fn | Accent color for icon and gradient (hex) — supports reactive function |
| `gradient` | bool | Colored gradient background |
| `badge` | string/fn | Badge on the right (`"NEW"`, `"500 €"`) — supports reactive function |
| `hint` | string/fn | Subtle text on the right — supports reactive function |
| `hotkey` | string | Keyboard shortcut label displayed in `<kbd>` |
| `arrow` | bool | Shows `›` (indicates a sub-menu) |
| `confirm_hold` | bool/number | `true` = hold 1.5s ; a number = custom duration in ms |
| `cooldown` | number | Milliseconds before being able to click again |
| `persist_key` | string | Stable localStorage key for cooldown persistence when label is dynamic |
| `keep_open` | bool | Don't close menu on click (default: `false`) |
| `timeout` | number | Automatically disable item after N ms from menu open |
| `preview` | table | Preview panel on hover (see below) |
| `visible` | bool/fn | Hide the item (supports reactive function) |
| `disabled` | bool/fn | Disable the item (supports reactive function) |
| `refresh` | number | Polling interval in ms for reactive fields (default: `500`) |
| `cb` | function | Called on click |

**Preview Panel** — displayed on the right of the menu on hover:

```lua
preview = {
    image = "https://i.imgur.com/example.jpeg",  -- optional
    title = "Engine Repair",
    desc  = "Restores engine to 100%.",
    stats = {
        { label = "Before", value = 20,  max = 100 },
        { label = "After",  value = 100, max = 100, color = "#4ade80" },
    },
}
```

**Examples:**

```lua
-- Simple button
menu:button("Repair engine", {
    icon = "wrench",
    cb   = function() print("repaired") end,
})

-- Badge + gradient + color
menu:button("Buy item", {
    icon     = "shopping-cart",
    color    = "#4ade80",
    gradient = true,
    badge    = "500 €",
    cb       = function() end,
})

-- Hold-to-confirm (1.5s)
menu:button("Delete save", {
    icon         = "trash",
    confirm_hold = true,
    cb           = function() print("deleted") end,
})

-- 5 second cooldown
menu:button("Use power", {
    icon     = "zap",
    cooldown = 5000,
    cb       = function() print("power activated") end,
})

-- Auto-expire after 8 seconds
menu:button("Limited offer", {
    icon    = "clock",
    badge   = "EXPIRES",
    timeout = 8000,
    cb      = function() print("offer accepted!") end,
})

-- Sub-menu arrow (keep_open so parent stays open)
menu:button("More options", {
    icon      = "settings",
    arrow     = true,
    keep_open = true,
    cb        = function()
        UI:context(function(sub)
            sub:title("More options")
            sub:button("Option A", { cb = function() end })
        end)
    end,
})
```

> **Dynamic Label** — pass a **function** as label for real-time updated text. See [Reactivity](/docs/avance/reactivite).

---

### slider

Horizontal slider with min/max/step.

```lua
menu:slider("Volume", {
    icon    = "volume-2",
    min     = 0,
    max     = 100,
    step    = 5,
    default = 80,
    suffix  = "%",
    cb      = function(value) print("Volume:", value) end,
})
```

Keyboard navigation: `←` `→` to move. Mouse: drag on the track.

---

### stepper

`−` / value / `+` control for integers.

```lua
menu:stepper("Repair kits", {
    icon    = "package",
    min     = 0,
    max     = 10,
    step    = 1,
    default = 2,
    suffix  = " kits",
    cb      = function(value) print("Kits:", value) end,
})
```

| Option | Type | Description |
|---|---|---|
| `min` | number | Minimum value (default: `0`) |
| `max` | number | Maximum value (default: `99`) |
| `step` | number | Increment per step (default: `1`) |
| `default` | number | Initial value |
| `suffix` | string | Unit label appended to value (e.g. `" kits"`, `" m"`) |
| `id` | string | Stable callback ID |

---

### checkbox

Square checkbox for a boolean.

```lua
menu:checkbox("Enable turbo", {
    icon    = "zap",
    default = false,
    cb      = function(checked) print("Turbo:", checked) end,
})
```

Keyboard navigation: `Enter` or `Space` to toggle.

---

### toggle

Animated ON/OFF switch (pill switch style).

```lua
menu:toggle("Stealth mode", {
    icon    = "eye-off",
    default = true,
    cb      = function(enabled) print("Stealth:", enabled) end,
})
```

---

### list

`‹ value ›` carousel for a list of options.

```lua
menu:list("Fuel type", {
    icon    = "fuel",
    items   = { "Gasoline", "Diesel", "Electric", "Hybrid" },
    default = 1,   -- 1-based index
    cb      = function(index, value) print("Fuel:", value) end,
})
```

Keyboard navigation: `←` `→` to cycle.

---

### stat

Read-only progress bar. Default color is the player's chosen accent (F12). Pass `color = "auto"` for green/orange/red mode based on ratio.

```lua
-- v1.0.0 signature (recommended)
menu:stat("Engine", {
    value  = 78,
    max    = 100,
    icon   = "activity",
    suffix = "%",
})

-- With auto color
menu:stat("Health", {
    value  = 45,
    max    = 100,
    color  = "auto",  -- red because < 50%
    icon   = "heart",
    suffix = "hp",
})

-- Reactive value
menu:stat("Health", {
    value   = function() return GetEntityHealth(PlayerPedId()) - 100 end,
    max     = 100,
    icon    = "heart",
    suffix  = "hp",
    refresh = 500,
})

-- Legacy signature (still supported)
menu:stat("Engine", 78, 100, { icon = "activity", suffix = "%" })
```

Both `value` and `max` support reactive functions.

---

### input_inline

Text or number input field integrated in the menu line.

```lua
menu:input_inline("Vehicle name", {
    icon        = "edit",
    type        = "text",
    placeholder = "My ride...",
    default     = "",
    maxlen      = 24,
    cb          = function(value) print("Name:", value) end,
})

menu:input_inline("Speed limit", {
    icon    = "gauge",
    type    = "number",
    default = 80,
    min     = 0,
    max     = 300,
    cb      = function(value) print("Speed:", value) end,
})
```

| Option | Type | Description |
|---|---|---|
| `type` | string | `"text"` (default) or `"number"` |
| `placeholder` | string | Placeholder text |
| `default` | string/number | Initial value |
| `maxlen` | integer | Max character length (text only) |
| `min` / `max` | number | Value range (number only) |
| `cb` | function | Called on confirm (`Enter` or blur) |

Navigation: `Enter` on the line → focus the field. `Enter` in the field → confirm. `Escape` → unfocus.

---

### color_picker

Color palette with preset grid and manual input.

```lua
menu:color_picker("Body color", {
    icon    = "palette",
    default = "#e94560",
    presets = { "#e94560", "#60a5fa", "#4ade80" },
    cb      = function(hex) print("Color:", hex) end,
})
```

Keyboard: `Enter` opens the popover. `←` `→` `↑` `↓` navigate presets. `Enter`/`Space` selects. `Escape` closes.

---

### date_picker

Three numeric fields day/month/year. Returns ISO string `"YYYY-MM-DD"`.

```lua
menu:date_picker("Service date", {
    icon    = "calendar",
    default = "2025-06-15",
    min     = "2024-01-01",   -- optional lower bound
    max     = "2030-12-31",   -- optional upper bound
    format  = "dmy",          -- 'dmy' (default) | 'mdy' | 'ymd'
    cb      = function(date) print("Date:", date) end,
})
```

| Option | Type | Description |
|---|---|---|
| `default` | string | Pre-filled date in `"YYYY-MM-DD"` (defaults to today) |
| `min` / `max` | string | Selectable date bounds (`"YYYY-MM-DD"`) |
| `format` | string | Display order: `'dmy'` DD/MM/YYYY, `'mdy'` MM/DD/YYYY, `'ymd'` YYYY/MM/DD |

---

### separator

Thin horizontal separator line.

```lua
menu:separator()
```

---

### header

Section label (uppercase, dimmed).

```lua
menu:header("Vehicle stats", { color = "#60a5fa", align = "left" })
```

| Option | Type | Description |
|---|---|---|
| `color` | string | Text color override (hex) |
| `align` | string | `'left'` (default), `'center'`, `'right'` |

---

### accordion

Collapsible/expandable section. All item types can be nested.

```lua
menu:accordion("Player info", function(acc)
    acc:stat("Health",  85, 100, { icon = "heart",  suffix = "%" })
    acc:stat("Armor",   60, 100, { icon = "shield", suffix = "%" })
    acc:button("Heal", {
        icon = "plus-circle",
        cb   = function() print("healed") end,
    })
end, {
    icon = "user",
    open = true,    -- expanded by default
})
```

> Buttons in an accordion have `keep_open = true` by default. To close the menu on click, add `keep_open = false` on the button.

Keyboard navigation: `Enter` on accordion header to toggle.

---

### tab

Organizes items in named tabs. Tab bar appears automatically.

```lua
menu:tab("Weapons", function(t)
    t:button("Pistol", { icon = "crosshair", badge = "500 €", cb = function() end })
    t:button("Rifle",  { icon = "crosshair", badge = "1 200 €", cb = function() end })
end, { icon = "crosshair" })

menu:tab("Ammo", function(t)
    t:button("9mm x50",   { icon = "package", badge = "80 €",  cb = function() end })
    t:button("Rifle x30", { icon = "package", badge = "120 €", cb = function() end })
end, { icon = "package" })
```

> Items placed **outside** a tab block remain always visible (above the tabs).

---

## Reusable Menus

Build once, open multiple times without re-running the builder:

```lua
local shopMenu = exports.LastMenu:context_build(function(menu)
    menu:title("Shop")
    menu:button("Buy Item — 50 €", {
        icon = "shopping-cart",
        cb   = function() print("purchased") end,
    })
end)

RegisterCommand('openshop', function()
    shopMenu.open()
end, false)
```

> Reactive watchers start fresh on each `open()`.

---

## Sub-menus

Open a second context menu from a callback. The parent stays in the stack.

```lua
menu:button("Advanced options", {
    icon      = "settings",
    arrow     = true,
    keep_open = true,
    cb        = function()
        UI:context(function(sub)
            sub:title("Advanced options")
            sub:animation("slideRight")
            sub:button("Option A", { cb = function() end })
            sub:back("Back", { icon = "arrow-left" })
        end)
    end,
})
```

### Helpers: `submenu()` and `back()`

```lua
UI:context(function(menu)
    menu:title("Main Menu")

    menu:submenu("Settings", function(sub)
        sub:title("Settings")
        sub:button("Audio", { icon = "volume-2", cb = function() end })
        sub:button("Video", { icon = "monitor",  cb = function() end })
        sub:back("Back",    { icon = "arrow-left" })
    end, { icon = "settings" })
end)
```

`menu:back(label, opts)` closes the current menu and returns to the parent. Pass `opts.cb` for cleanup logic before popping:

```lua
sub:back("Back", {
    icon = "arrow-left",
    cb   = function() cleanup() end
})
```

---

## Live Rebuild (`context_update`)

Rebuilds the currently visible context menu **without closing and reopening it**. Use it when the item list itself changes (items added/removed), not just field values.

```lua
exports.LastMenu:context_update(function(menu)
    menu:title("Shop")
    for _, item in ipairs(getUpdatedInventory()) do
        menu:button(item.name, { badge = item.price .. " €", cb = function() buy(item) end })
    end
end)
```

> Only works when the top of the stack is a context menu. Silently ignored otherwise.

**When to use `context_update` vs reactive watchers:**

| Situation | Recommended |
|---|---|
| A button label / badge / color / visible changes | Watcher (`badge = function()`, `visible = function()`) |
| The item list itself changes (add/remove items) | `context_update` |
| Switching tabs by reloading the entire menu | `context_update` |

**Handle variant** — `context_build` handles expose the same method:

```lua
local shopHandle = exports.LastMenu:context_build(function(menu)
    -- …
end)

-- Rebuild without closing/reopening:
shopHandle.update(function(menu)
    menu:title("Shop (refreshed)")
    -- …
end)

-- Or re-run the original builder:
shopHandle.update()
```

---

## Keyboard Controls

| Key | Action |
|---|---|
| `↑` / `↓` | Navigate between items |
| `←` / `→` | Slider / Stepper / List |
| `Enter` | Activate selected item |
| `Space` | Toggle / Checkbox |
| `Escape` | Close / Return to parent menu |
| `F12` | Open user settings |

---

## User Settings

Players can open the **settings panel** at any time via **F12**:

| Setting | Options | Description |
|---|---|---|
| **Navigation mode** | Mouse / Keyboard / Both | Controls menu input response |
| **Target key** | Left Ctrl / E / G / Alt | Key used to open target action menus |
| **Accent color** | 10 presets + free selector | Changes `--ui-accent` globally |
| **Menu opacity** | Slider | Changes `--ui-ctx-bg` alpha |
| **Menu width** | Slider | Changes `--ui-ctx-width` |
| **Compact mode** | Toggle | Reduces item height |
| **Blur effect** | Toggle | Enables/disables backdrop-filter |
| **Font size** | 80% to 130% | Changes `--ui-font-scale` |
| **UI sounds** | Toggle | Enables/disables click/hover sounds |
| **Notification position** | 4 quadrants | Toast placement |
| **Reset position** | Button | Resets menu to default screen position |

Settings are saved in `localStorage`. Developer options `menu:nav('mouse')` / `menu:nav('keyboard')` always take priority over the player's global setting.

> Open or close the settings panel programmatically:
> ```lua
> exports.LastMenu:settings_open()
> exports.LastMenu:settings_close()
> ```

---

## Security

- **Callbacks are client-side only.** LastMenu emits no network events. Server validation is the developer's responsibility.
- **Banner URLs are filtered**: only `https://` and `nui://` schemes are accepted.
- **CSS injection is blocked** — color and style values are sanitized before being applied to inline styles.
