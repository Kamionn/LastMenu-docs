---
title: Installation
description: Install LastMenu on a FiveM server — fxmanifest, server.cfg and file structure.
order: 1
lastUpdated: 2026-04-14
---

## Prerequisites

- A working **FiveM** server (build ≥ 6683 recommended)
- No framework required — LastMenu is **standalone**

## Step 1 — Copy the resource

Copy the `LastMenu` folder into your server's `resources/` directory:

```
resources/
└── LastMenu/
    ├── client/
    ├── ui/
    ├── fxmanifest.lua
    └── ...
```

## Step 2 — Declare in server.cfg

In your `server.cfg`, make sure LastMenu is loaded **before** any resource that uses it:

```
ensure LastMenu
```

> **Critical load order.** If a dependent resource starts before LastMenu, its exports won't be available and you'll get `attempt to call a nil value` errors.

## Step 3 — Declare the export in your resources

In the `fxmanifest.lua` of **every client resource** that uses LastMenu, add:

```lua
client_scripts {
    '@LastMenu/client/exports.lua',
    -- your own scripts...
    'client/*.lua',
}
```

That's it. No `npm install`, no server-side build — the UI is pre-compiled.

## Step 4 — Short reference

By convention, create a local alias at the top of each Lua file:

```lua
local UI = exports['LastMenu']
```

You can also use `exports.LastMenu:context(...)` directly if you prefer.

## Verify the installation

Start your server and open the console. You should see:

```
[LastMenu] v1.0.0 — ready
```

To quickly test that a menu displays, run this code in a command:

```lua
RegisterCommand('testmenu', function()
    local UI = exports['LastMenu']
    UI:notify(function(n)
        n:message("LastMenu is working!")
        n:type("success")
    end)
end, false)
```

Run `/testmenu` in-game — a green notification should appear.

## LastMenu file structure

| Directory / File | Role |
|---|---|
| `client/exports.lua` | **Entry point** — the only file to import |
| `client/builders/` | Payload builders per menu type |
| `client/bridge.lua` | NUI layer (batching, callbacks) |
| `client/stack.lua` | Navigation stack, cursor management |
| `client/reactive.lua` | Reactive polling diff/patch engine |
| `client/config.lua` | Debug flags and global tunables |
| `ui/` | Pre-compiled Svelte 5 interface |
| `ui/theme/default.css` | All CSS theming variables |

## Common issues

**`attempt to call a nil value` on startup**
→ LastMenu hasn't started yet. Check the `ensure` order in `server.cfg`.

**The UI doesn't display**
→ The `ui/assets/` folder is missing or corrupted. Re-copy the resource.

**NUI focus stuck after resource restart**
→ Call `SetNuiFocus(false, false)` from the F8 console, or restart LastMenu.
