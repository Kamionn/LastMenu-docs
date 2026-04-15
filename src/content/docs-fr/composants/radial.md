---
title: Radial Menu
description: Roue d'actions circulaire — idéale pour les raccourcis rapides accessibles à la souris, au clavier ou à la manette.
order: 2
lastUpdated: 2026-04-14
---

## Ouverture

```lua
exports.LastMenu:radial(function(r)
    r:center_label("Hub rapide")
    r:button("Garage",   { icon = "car",          cb = openGarage   })
    r:button("Hôpital",  { icon = "plus-circle",  cb = openHospital })
    r:button("Missions", { icon = "zap",           cb = openMissions })
end)
```

Le secteur du centre affiche `center_label` quand aucun secteur n'est survolé.

---

## Menu réutilisable

Utilise `radial_build` pour construire une instance une seule fois et la rouvrir à volonté :

```lua
local radial = exports.LastMenu:radial_build(function(r)
    r:button("Action A", { icon = "check", cb = function() end })
    r:button("Action B", { icon = "x",     cb = function() end })
end)

RegisterCommand('roue', function() radial.open()  end, false)
RegisterCommand('fermeroue', function() radial.close() end, false)
```

---

## Options du menu

| Méthode | Description |
|---|---|
| `r:center_label(str)` | Texte affiché dans l'anneau central au repos |

## Options des boutons

| Champ | Type | Défaut | Description |
|---|---|---|---|
| `icon` | `string` | — | Nom d'icône Lucide |
| `cb` | `function()` | — | Appelé à la sélection |
| `keep_open` | `bool` | `false` | Ne ferme pas le radial après le callback |
| `submenu` | `function(r)` | `nil` | Ouvre un radial imbriqué au clic |
| `visible` | `bool\|function() → bool` | `true` | Masque et retire le secteur |
| `disabled` | `bool\|function() → bool` | `false` | Grisé, sans callback |
| `refresh` | `number` | `250` | Intervalle de polling (ms) pour `visible`/`disabled` |

---

## Bouton conditionnel (réactivité)

Affiche le bouton "Quitter le véhicule" uniquement quand le joueur est dans un véhicule :

```lua
exports.LastMenu:radial(function(r)
    r:center_label("Actions")

    r:button("Quitter le véhicule", {
        icon    = "log-out",
        visible = function()
            return GetVehiclePedIsIn(PlayerPedId(), false) ~= 0
        end,
        refresh = 500,
        cb = function()
            TaskLeaveAnyVehicle(PlayerPedId(), 0, 16)
        end,
    })

    r:button("Soigner", {
        icon = "heart",
        cb   = function() TriggerServerEvent('player:heal') end,
    })
end)
```

---

## Sous-radials

Imbrique des menus radiaux avec `button.submenu`. Le radial parent est empilé et restauré à l'`Escape` :

```lua
exports.LastMenu:radial(function(r)
    r:center_label("Actions")

    r:button("Véhicule", {
        icon    = "car",
        submenu = function(sub)
            sub:center_label("Véhicule")
            sub:button("Réparer",  { icon = "wrench",   cb = repairVehicle })
            sub:button("Nettoyer", { icon = "droplets", cb = cleanVehicle  })
        end,
    })

    r:button("Joueur", {
        icon    = "user",
        submenu = function(sub)
            sub:center_label("Joueur")
            sub:button("Soigner", { icon = "heart", cb = healPlayer })
        end,
    })
end)
```

> Avec `submenu`, `keep_open = true` est positionné automatiquement — inutile de le spécifier manuellement.

---

## Contrôles

| Entrée | Action |
|---|---|
| Survol souris | Met en surbrillance le secteur |
| Clic gauche | Confirme la sélection |
| Stick gauche manette | Met en surbrillance par direction |
| Bouton A / Croix manette | Confirme la sélection |
| `Escape` | Ferme sans action |

---

## Bonnes pratiques

**`visible = false`** retire le secteur et redistribue la géométrie des arcs. Utilise `disabled = true` si tu veux garder le secteur visible mais inactif (layout stable).

**Limite de boutons** — jusqu'à environ 12 boutons s'affichent correctement. Au-delà, les secteurs deviennent trop étroits — envisage des sous-radials ou un menu contextuel.

Les watchers `visible`/`disabled` utilisent le même moteur de polling adaptatif que les menus contextuels (backoff sur stabilité, reset sur changement).
