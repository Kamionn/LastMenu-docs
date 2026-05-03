---
title: Framework Compatibility
description: Compatibility matrix for ox_lib, ESX, QBCore and QBox. Migration snippets and known incompatibilities.
order: 5
lastUpdated: 2026-04-20
---

LastMenu is **framework-agnostic**: it has zero dependencies on ESX, QBCore, or ox_lib. All interactions go through the public exports API.

## Compatibility matrix

| Feature | ox_lib | ESX (legacy + v2) | QBCore / QBox |
|---|---|---|---|
| Context menu replacement | ✅ Drop-in | ✅ Drop-in | ✅ Drop-in |
| Input dialog replacement | ✅ Drop-in | ✅ Drop-in | ✅ Drop-in |
| Notification replacement | ✅ Drop-in | ✅ Drop-in | ✅ Drop-in |
| Alert / confirm dialog | ✅ Drop-in | ✅ Drop-in | ✅ Drop-in |
| Radial menu | ✅ Drop-in | ✅ Drop-in | ✅ Drop-in |
| Progress bar | ✅ Drop-in | ✅ Drop-in | ✅ Drop-in |
| Target system | ⚠️ Parallel | ⚠️ Parallel | ✅ Native |

> ⚠️ **Parallel** — ox_target and ESX's native targeting can coexist with LastMenu's target system without conflict, but register zones in only one system per resource to avoid duplicate action menus.

---

## Migration snippets

### From ox_lib → LastMenu

```lua
-- ox_lib context menu
lib.showContext('my_menu')

-- LastMenu
exports.LastMenu:context(function(menu)
    menu:title("My Menu")
    menu:button("Action", { cb = function() end })
end)
```

```lua
-- ox_lib input dialog (blocking)
local result = lib.inputDialog("Title", { { type = "input", label = "Name" } })

-- LastMenu (blocking — must be inside Citizen.CreateThread)
Citizen.CreateThread(function()
    local values = exports.LastMenu:input_async(function(b)
        b:title("Title")
        b:field("Name", {})
        b:confirm_label("OK")
        b:cancel_label("Cancel")
    end)
    if values then print(values[1]) end
end)
```

```lua
-- ox_lib notify
lib.notify({ title = "Info", description = "Hello", type = "inform" })

-- LastMenu
exports.LastMenu:notify(function(n)
    n:title("Info")
    n:message("Hello")
    n:type("info")
end)
```

---

### From ESX → LastMenu

```lua
-- ESX menu (legacy)
ESX.UI.Menu.Open("default", GetCurrentResourceName(), "my_menu", { ... })

-- LastMenu
exports.LastMenu:context(function(menu)
    menu:title("My Menu")
    -- add items here
end)
```

```lua
-- ESX input dialog
ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "input", {
    title = "Name", inputs = { { type = "text", label = "Name" } }
}, function(data, menu) menu.close() end, function(_, menu) menu.close() end)

-- LastMenu
exports.LastMenu:input(function(form)
    form:title("Name")
    form:field("Name", {})
    form:confirm("OK", function(values) print(values[1]) end)
    form:cancel("Cancel")
end)
```

---

### From QBCore → LastMenu

```lua
-- QBCore menu
QBCore.Functions.QBCallback("qb-menu:client:openMenu", false, items)

-- LastMenu
exports.LastMenu:context(function(menu)
    menu:title("Menu")
    for _, item in ipairs(items) do
        menu:button(item.header, {
            cb = item.params.event and function()
                TriggerEvent(item.params.event, item.params.args)
            end,
        })
    end
end)
```

---

## Known incompatibilities

| Issue | Affected frameworks | Workaround |
|---|---|---|
| ox_target zones and LastMenu target registered on the same entity | ox_lib + LastMenu | Register in one system only per resource |
| ESX legacy `hideUI` conflicts with `SetNuiFocus(false)` on menu close | ESX legacy | Let LastMenu manage NUI focus — do not call `hideUI` while a LastMenu menu is open |
| QB-Core's `QBCore.Functions.Progressbar` running simultaneously with LastMenu progress | QBCore | Use LastMenu progress exclusively; QB-Core's bar renders on a different DOM layer and may overlay |

---

## Tested versions

| Framework | Version tested | Status |
|---|---|---|
| ox_lib | 3.x | ✅ Compatible |
| ESX Legacy | 1.9.x | ✅ Compatible |
| ESX v2 (es_extended) | 2.x | ✅ Compatible |
| QBCore | 1.x | ✅ Compatible |
| QBox (qbx_core) | latest | ⚠️ Untested — expected compatible |
