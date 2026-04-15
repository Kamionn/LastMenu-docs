---
title: Sous-menus & Stack de navigation
description: Imbriquer des menus contextuels, utiliser les helpers submenu/back, et comprendre comment la navigation stack fonctionne automatiquement.
order: 3
lastUpdated: 2026-04-14
---

## Comment fonctionne la stack

Chaque appel `UI:context(fn)` dans un callback **pousse** un menu sur la stack NUI. Appuyer sur `Escape` (ou cliquer le bouton retour) **dépile** le menu du dessus et restaure le précédent.

Tu n'as jamais à gérer cette stack manuellement — LastMenu s'en charge.

```
[Menu principal]  ← stack niveau 1
    └─ [Sous-menu Paramètres]  ← stack niveau 2 (ouvert depuis un callback)
           └─ [Sous-sous-menu Audio]  ← stack niveau 3
```

Appuyer sur Escape depuis le niveau 3 → retour au niveau 2 → retour au niveau 1.

---

## Sous-menu manuellement (méthode longue)

```lua
UI:context(function(menu)
    menu:title("Menu principal")

    menu:button("Options avancées", {
        icon      = "settings",
        arrow     = true,
        keep_open = true,   -- REQUIS : garde le parent ouvert
        cb        = function()
            UI:context(function(sub)
                sub:title("Options avancées")
                sub:animation("slideRight")
                sub:button("Option A", { cb = function() end })
                sub:button("Retour",   { icon = "arrow-left", cb = function() end })
            end)
        end,
    })
end)
```

> `keep_open = true` est **indispensable** sur le bouton parent. Sans ça, le menu parent se fermerait avant l'ouverture du sous-menu, cassant la stack.

---

## Helpers `submenu` et `back` (v1.0.0)

Ces raccourcis réduisent le boilerplate :

```lua
UI:context(function(menu)
    menu:title("Menu principal")

    -- menu:submenu(label, builderFn, opts)
    -- équivalent à un bouton keep_open qui ouvre un sous-contexte
    menu:submenu("Paramètres", function(sub)
        sub:title("Paramètres")
        sub:button("Audio",  { icon = "volume-2", cb = function() end })
        sub:button("Vidéo",  { icon = "monitor",  cb = function() end })

        -- sub:back(label, opts) — ferme ce menu et revient au parent
        sub:back("Retour", { icon = "arrow-left" })
    end, { icon = "settings" })

    menu:submenu("Véhicule", function(sub)
        sub:title("Véhicule")
        sub:button("Réparer",   { icon = "wrench",   cb = function() end })
        sub:button("Nettoyer",  { icon = "droplets", cb = function() end })
        sub:back("Retour")
    end, { icon = "car" })
end)
```

### `menu:back(label, opts)`

Équivalent à un bouton dont le callback appelle `Stack.pop()`. Passe `opts.cb` pour exécuter une logique de nettoyage **avant** le dépilage :

```lua
sub:back("Retour", {
    icon = "arrow-left",
    cb   = function()
        -- Nettoyage optionnel avant de revenir
        cleanup()
    end
})
```

---

## Imbrication profonde

La stack supporte une profondeur arbitraire. Exemple : menu → sous-menu → confirmation :

```lua
UI:context(function(menu)
    menu:title("Garage")

    menu:submenu("Voitures disponibles", function(sub)
        sub:title("Voitures disponibles")

        sub:button("Infernus Classic", {
            icon      = "car",
            badge     = "250 000 €",
            keep_open = true,
            cb        = function()
                exports.LastMenu:alert_async and
                Citizen.CreateThread(function()
                    local ok = exports.LastMenu:alert_async(function(b)
                        b:title("Acheter l'Infernus Classic ?")
                        b:message("Coût : 250 000 €")
                        b:confirm_label("Acheter")
                        b:cancel_label("Annuler")
                    end)
                    if ok then TriggerServerEvent('garage:buy', 'infernus2') end
                end)
            end,
        })

        sub:back("Retour")
    end, { icon = "layout-grid" })
end)
```

---

## Navigation programmatique

```lua
-- Fermer le menu du dessus (équivalent à Escape)
exports.LastMenu:lastmenu_back()
```

Depuis v1.1, l'export s'appelle `lastmenu_back` (et non `back`) pour éviter les collisions avec d'autres ressources. La méthode builder `menu:back()` reste inchangée.

---

## Menus réutilisables et stack

`context_build` construit l'instance une fois. Chaque `open()` pousse sur la stack :

```lua
local shopMenu = UI:context_build(function(menu)
    menu:title("Boutique")
    menu:button("Acheter item — 50 €", {
        icon = "shopping-cart",
        cb   = function() print("acheté") end,
    })
    menu:button("Fermer", { icon = "x", cb = function() end })
end)

RegisterCommand('boutique', function()
    shopMenu:open()
end, false)
```

> **Note :** les callbacks sont enregistrés une seule fois. Les watchers réactifs redémarrent à chaque `open()`.
