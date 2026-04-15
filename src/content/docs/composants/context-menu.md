---
title: Context Menu
description: Vertical context menu — LastMenu's main component. Supports all item types, real-time reactivity, tabs, accordions and sub-menus.
order: 1
lastUpdated: 2026-04-14
---

## Opening

```lua
local UI = exports['LastMenu']

UI:context(function(menu)
    menu:title("My Menu")
    menu:button("Click", { cb = function() print("clicked") end })
end)
```

The menu opens immediately. It closes on `Escape` or by calling the appropriate callback.

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
| `menu:page_size(n)` | number | 20 | Items per page (automatic pagination beyond) |
| `menu:scroll()` | — | — | Disable pagination — native scroll on all items |

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

> `menu:scroll()` and `menu:page_size()` are mutually exclusive. `scroll()` takes priority.

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
| `color` | string | Accent color for icon and gradient (hex) |
| `gradient` | bool | Colored gradient background |
| `badge` | string | Badge on the right (`"NEW"`, `"500 €"`) |
| `hint` | string | Subtle text on the right |
| `hotkey` | string | Keyboard shortcut label displayed in `<kbd>` |
| `arrow` | bool | Shows `›` (indicates a sub-menu) |
| `confirm_hold` | bool/number | `true` = hold 1.5s ; a number = custom duration in ms |
| `cooldown` | number | Milliseconds before being able to click again |
| `persist_key` | string | Stable key for cooldown persistence when label is dynamic |
| `keep_open` | bool | Don't close menu on click |
| `timeout` | number | Automatically disable item after N ms |
| `preview` | table | Preview panel on hover (see below) |
| `visible` | bool/fn | Hide the item (supports reactive function) |
| `disabled` | bool/fn | Disable the item (supports reactive function) |
| `refresh` | number | Polling interval in ms for `visible`/`disabled` |
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

-- Hold-to-confirm
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
    cb      = function(value) print("Kits:", value) end,
})
```

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
```

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

---

### date_picker

Three numeric fields day/month/year. Returns ISO string `"YYYY-MM-DD"`.

```lua
menu:date_picker("Service date", {
    icon    = "calendar",
    default = "2025-06-15",
    cb      = function(date) print("Date:", date) end,
})
```

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
menu:header("Vehicle stats", { color = "#60a5fa" })
```

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

- **Navigation mode** — Mouse / Keyboard / Both
- **Accent color** — 10 presets + free selector
- **Font size** — 80% to 130%
- **Reset position** — resets menu to default position

Settings are saved in `localStorage`. Developer options `menu:nav('mouse')` / `menu:nav('keyboard')` always take priority over the player's global setting.

---

## Security

- **Callbacks are client-side only.** LastMenu emits no network events. Server validation is the developer's responsibility.
- **Banner URLs are filtered**: only `https://` and `nui://` schemes are accepted.
- **CSS injection is blocked** — color and style values are sanitized before being applied to inline styles.
