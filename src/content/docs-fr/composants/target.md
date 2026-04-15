---
title: Target System
description: Remplacement d'ox_target / qtarget — détecte l'entité ou la zone visée et affiche un menu d'interaction. Supporte entités, modèles, sphères, boîtes et polygones.
order: 7
lastUpdated: 2026-04-14
---

## Fonctionnement

Un thread de fond tourne à **10 Hz** (100ms). Quand le joueur vise une entité ou entre dans une zone enregistrée :

1. Un **réticule passif** apparaît au centre de l'écran.
2. Le joueur appuie sur **E** (`INPUT_CONTEXT`) → le **menu d'actions** s'ouvre.
3. Sélectionner une action déclenche le callback ; `Escape` ou le bouton ✕ ferme le menu.

Quand aucun enregistrement n'existe, le thread dort à **1 Hz** (aucun coût CPU).

---

## Types d'enregistrement

### Entité — handle spécifique

```lua
local id = exports.LastMenu:target_add_entity(entity, opts)
```

| Champ | Type | Défaut | Description |
|---|---|---|---|
| `entity` | `number` | — | Handle d'entité |
| `opts.label` | `string` | `"Interagir"` | Label d'en-tête du menu d'actions |
| `opts.icon` | `string` | `"eye"` | Icône Lucide dans le réticule |
| `opts.distance` | `number` | `3.0` | Distance max en mètres |
| `opts.actions` | `table` | `{}` | Tableau d'objets action (voir ci-dessous) |
| `opts.on_enter` | `function` | `nil` | Appelé une fois quand le joueur entre dans la zone |
| `opts.on_leave` | `function` | `nil` | Appelé une fois quand le joueur quitte la zone |

---

### Modèle — toutes les entités correspondantes

```lua
local id = exports.LastMenu:target_add_model(model, opts)
```

| Champ | Type | Description |
|---|---|---|
| `model` | `string\|number\|nil` | Nom du modèle, hash, ou `nil` pour **tous les peds** |

Les autres champs sont identiques à `target_add_entity`.

---

### Zone sphérique

```lua
local id = exports.LastMenu:target_add_sphere(coords, radius, opts)
```

| Champ | Type | Défaut |
|---|---|---|
| `coords` | `vector3` | — |
| `radius` | `number` | `2.0` |

---

### Zone rectangulaire (box)

Zone rectangulaire alignée sur un axe, rotatable par heading.

```lua
local id = exports.LastMenu:target_add_box(coords, opts)
```

| Champ | Type | Défaut | Description |
|---|---|---|---|
| `opts.width` | `number` | `2.0` | Largeur totale sur l'axe X local |
| `opts.length` | `number` | `2.0` | Longueur totale sur l'axe Y local |
| `opts.heading` | `number` | `0.0` | Rotation en degrés (GTA : sens horaire depuis le Nord) |

---

### Zone polygonale

Polygone 2D avec bornes Z optionnelles.

```lua
local id = exports.LastMenu:target_add_poly(points, opts)
```

| Champ | Type | Défaut | Description |
|---|---|---|---|
| `points` | `vector2[]\|vector3[]` | — | Sommets définissant le polygone |
| `opts.minZ` | `number` | `-math.huge` | Borne Z inférieure |
| `opts.maxZ` | `number` | `math.huge` | Borne Z supérieure |

**Exemple — plan d'étage en L :**

```lua
local UI = exports['LastMenu']

local storeFloor = {
    vector2(312.0, -780.0),
    vector2(320.0, -780.0),
    vector2(320.0, -795.0),
    vector2(328.0, -795.0),
    vector2(328.0, -808.0),
    vector2(312.0, -808.0),
}

local storeId = UI:target_add_poly(storeFloor, {
    minZ    = 28.5,
    maxZ    = 32.0,
    label   = "Magasin",
    icon    = "store",
    on_enter = function()
        UI:notify(function(n) n:message("Vous entrez dans le magasin.") n:type("info") end)
    end,
    on_leave = function()
        UI:notify(function(n) n:message("Vous quittez le magasin.") n:type("info") end)
    end,
    actions = {
        {
            label = "Parler au caissier",
            icon  = "message-square",
            cb    = function()
                UI:context(function(menu)
                    menu:title("Caissier")
                    menu:button("Acheter quelque chose", { icon = "shopping-cart", cb = function() end })
                end)
            end,
        },
        {
            label    = "Braquer la caisse",
            icon     = "alert-triangle",
            visible  = function() return IsPedArmed(PlayerPedId(), 6) end,
            cb       = function() TriggerServerEvent('robbery:start') end,
        },
    },
})
```

---

## Structure d'une action

| Champ | Type | Description |
|---|---|---|
| `label` | `string` | Texte du bouton |
| `icon` | `string` | Icône Lucide |
| `cb` | `function(entity)` | Appelé au clic. `entity` = handle raycast (ou `nil` pour les zones) |
| `visible` | `bool\|function(entity) → bool` | Masque l'action si `false` |
| `condition` | `bool\|function(entity) → bool` | Alias de `visible` — préféré pour la clarté sémantique |
| `disabled` | `bool\|function(entity) → bool` | Affiché grisé, sans callback |

`visible`, `condition` et `disabled` acceptent des **booleans statiques** ou des **callables** — évalués à chaque ouverture du menu. `condition` a la priorité sur `visible` si les deux sont définis.

```lua
actions = {
    {
        label   = "Fouiller",
        icon    = "search",
        visible = function(ent) return IsPedDeadOrDying(ent, true) end,
        cb      = function(ent) print("Fouillé ped " .. ent) end,
    },
    {
        label    = "Soigner",
        icon     = "plus-circle",
        disabled = function(ent) return GetEntityHealth(ent) >= 200 end,
        cb       = function(ent) print("Soigné ped " .. ent) end,
    },
}
```

---

## Suppression

```lua
-- Supprimer un enregistrement
exports.LastMenu:target_remove(id)

-- Supprimer tous les enregistrements
exports.LastMenu:target_clear()
```

> **Toujours nettoyer à l'arrêt de la ressource** pour éviter les fuites de zones fantômes :
>
> ```lua
> AddEventHandler('onResourceStop', function(res)
>     if res == GetCurrentResourceName() then
>         exports.LastMenu:target_remove(monId)
>     end
> end)
> ```

---

## Fusions d'enregistrements

Quand plusieurs enregistrements correspondent simultanément, leurs actions sont **fusionnées** dans un seul menu. La priorité du label d'en-tête : `entity > model > zone`.

---

## Debug visuel

Active `Config.debugTarget = true` dans `client/config.lua` pour visualiser toutes les zones en jeu :

| Type de zone | Visualisation |
|---|---|
| `sphere` | Sphère bleue translucide |
| `box` | Marker + lignes de coin |
| `poly` | Contour connectant tous les sommets |

```lua
Config.debugTarget = true  -- dans client/config.lua
```

Le thread de debug dort à 500ms quand désactivé — aucun coût en production.
