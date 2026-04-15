---
title: Theming
description: Customize LastMenu's appearance via CSS custom properties — colors, typography, layout, radial and notifications.
order: 1
lastUpdated: 2026-04-14
---

## Principle

LastMenu uses exclusively **CSS custom properties** for theming. No values are hardcoded in components — everything is overridable.

---

## Setup

**1. Create a theme CSS file** (e.g. `ui/theme/mytheme.css`)

**2. Declare it in `fxmanifest.lua` after `ui/theme/**` :**

```lua
files {
    'ui/index.html',
    'ui/assets/**',
    'ui/theme/**',
    'ui/theme/mytheme.css',  -- your theme
}
```

**3. Load it in `ui/index.html` after the default link:**

```html
<link rel="stylesheet" href="./theme/default.css">
<link rel="stylesheet" href="./theme/mytheme.css">
```

**4. In `mytheme.css`, override only the necessary variables:**

```css
:root {
    --ui-accent:     #00ffcc;
    --ui-ctx-bg:     rgba(5, 5, 10, 0.97);
    --ui-ctx-radius: 2px;
}
```

---

## Reference variables

### Global colors

| Variable | Default | Usage |
|---|---|---|
| `--ui-accent` | `#e94560` | Primary color (active buttons, badges, toggles ON) |
| `--ui-accent-dim` | `#c73652` | Dark variant (hover states) |
| `--ui-accent-text` | `#ffffff` | Text on accent background |
| `--ui-success` | `#4ade80` | Success notifications, high stat bar |
| `--ui-warning` | `#fb923c` | Warning notifications |
| `--ui-error` | `#f87171` | Error notifications, low stat bar |
| `--ui-info` | `#60a5fa` | Info notifications |

### Typography

| Variable | Default | Usage |
|---|---|---|
| `--ui-font-body` | Inter | Primary font |
| `--ui-font-heading` | Rajdhani | Menu titles |
| `--ui-font-scale` | `1` | Global scale (modified by user panel) |
| `--ui-font-size-base` | `13px × scale` | Base size of items |

### Context menu — Layout

| Variable | Default | Usage |
|---|---|---|
| `--ui-ctx-top` | `72px` | Distance from top |
| `--ui-ctx-left` | `16px` | Distance from left |
| `--ui-ctx-width` | `320px` | Panel width |
| `--ui-ctx-item-height` | `40px` | Minimum item height |
| `--ui-ctx-radius` | `8px` | Panel corner radius |

### Context menu — Colors

| Variable | Default |
|---|---|
| `--ui-ctx-bg` | `rgba(12, 12, 22, 0.97)` |
| `--ui-ctx-bg-hover` | `rgba(255,255,255,0.08)` |
| `--ui-ctx-text` | `rgba(255,255,255,0.82)` |
| `--ui-ctx-text-dim` | `rgba(255,255,255,0.45)` |
| `--ui-ctx-border` | `rgba(255,255,255,0.07)` |

---

## Ready-to-use themes

Three example themes are commented in `ui/theme/default.css` — uncomment and copy into your file:

### Military / Survival

```css
:root {
    --ui-accent:      #4a7c59;
    --ui-accent-dim:  #3a6048;
    --ui-ctx-bg:      rgba(8, 12, 8, 0.98);
    --ui-ctx-text:    rgba(180, 200, 170, 0.9);
    --ui-font-body:   'Courier New', monospace;
}
```

### Luxury / Light RP

```css
:root {
    --ui-accent:      #1a1a2e;
    --ui-ctx-bg:      rgba(248, 248, 248, 0.97);
    --ui-ctx-text:    rgba(20, 20, 30, 0.88);
    --ui-ctx-border:  rgba(0, 0, 0, 0.1);
}
```

### Neon / Cyberpunk

```css
:root {
    --ui-accent:      #00ffcc;
    --ui-accent-dim:  #00ccaa;
    --ui-ctx-bg:      rgba(2, 2, 8, 0.98);
    --ui-ctx-text:    rgba(200, 255, 240, 0.9);
    --ui-ctx-radius:  0px;
}
```

---

## Dynamic accent (user panel)

The player can set a custom accent color from Settings (F12). `--ui-accent` and `--ui-accent-dim` are then dynamically recalculated by `App.svelte`.

To disable this feature, remove the `accentColor` field from `loadSettings()` in `ui/src/App.svelte`.

---

## Custom fonts

**1. Place font files in `ui/theme/fonts/`**

**2. Declare them in your CSS:**

```css
@font-face {
    font-family: 'MyFont';
    src: url('./fonts/myfont.woff2') format('woff2');
}
:root {
    --ui-font-body: 'MyFont', sans-serif;
}
```

**3. Add to `fxmanifest.lua`:**

```lua
files {
    'ui/theme/fonts/**',
}
```

---

## All variables

See `ui/theme/default.css` for the exhaustive list of all available variables, with inline comments.
