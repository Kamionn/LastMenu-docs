---
title: Progress Bar
description: Barre de progression chronomètre — le timer tourne côté NUI sans polling Lua. Supporte animation ped, prop attaché et callback par tick.
order: 6
lastUpdated: 2026-04-14
---

## Ouverture simple

```lua
exports.LastMenu:progress(function(p)
    p:label("Chargement des données...")
    p:duration(5000)
    p:cancel(true)   -- l'Escape / bouton d'annulation est disponible
    p:onComplete(function()
        -- déclenché quand la barre atteint 100%
    end)
    p:onCancel(function()
        -- déclenché si le joueur annule
    end)
end)
```

## Barre réutilisable

```lua
local bar = exports.LastMenu:progress_build(function(p)
    p:label("Fabrication en cours...")
    p:duration(8000)
    p:cancel(false)
    p:onComplete(function() giveCraftedItem() end)
end)

bar.open()    -- démarrer
bar.close()   -- interrompre programmatiquement (ne déclenche pas onComplete/onCancel)
```

---

## Méthodes du builder

| Méthode | Args | Description |
|---|---|---|
| `p:label(str)` | `string` | Texte affiché au-dessus de la barre |
| `p:duration(ms)` | `number` | Durée totale en millisecondes |
| `p:cancel(bool)` | `bool` | Le joueur peut-il annuler ? (défaut : `false`) |
| `p:onComplete(cb)` | `function` | Appelé quand la barre se remplit naturellement |
| `p:onCancel(cb)` | `function` | Appelé si le joueur annule |
| `p:icon(str)` | `string` | Icône Lucide affichée à côté du label |
| `p:cb_tick(cb)` | `function(pct)` | Appelé toutes les ~100ms avec le % actuel (0–100) |
| `p:anim(opts)` | `table` | Joue une animation ped pendant la durée |
| `p:prop(opts)` | `table` | Attache un prop au ped pendant la durée |

---

## Position

Configurable dans les Paramètres utilisateur (F12) :

| Preset | Emplacement |
|---|---|
| `bottom-center` | Défaut — style barre HUD |
| `top-center` | Haut de l'écran |
| `bottom-left` | Coin bas-gauche |
| `bottom-right` | Coin bas-droite |

---

## Side effects (v1.0.0)

### Icône

```lua
p:label("Fabrication...")
p:icon("hammer")
```

### `cb_tick` — progression par interval

Appelé toutes les ~100ms. Utile pour les récompenses partielles, sons, ou synchronisation serveur :

```lua
p:cb_tick(function(pct)
    if pct >= 50 and not halfway then
        halfway = true
        TriggerServerEvent('myCraft:halfwayDone')
    end
end)
```

### `anim` — animation ped

L'animation est automatiquement stoppée à la complétion, annulation ou fermeture :

```lua
p:anim({
    dict  = "amb@world_human_welding@male@base",
    clip  = "base",
    flag  = 1,       -- AnimationFlag (1 = loop)
    speed = 1.0,     -- optionnel (défaut : 1.0)
    blend = 0.0,     -- blendInSpeed optionnel
})
```

### `prop` — objet attaché

L'objet est détaché et supprimé automatiquement à la fin :

```lua
p:prop({
    model  = "prop_tool_torch",
    bone   = 57005,                     -- index d'os ped (57005 = main droite)
    offset = vector3(0.12, 0.03, 0.0),
    rot    = vector3(0.0, 0.0, 0.0),
})
```

---

## Exemple complet — Soudure

```lua
exports.LastMenu:progress(function(p)
    p:label("Soudure en cours...")
    p:icon("zap")
    p:duration(8000)
    p:cancel(true)
    p:anim({ dict = "amb@world_human_welding@male@base", clip = "base", flag = 1 })
    p:prop({ model = "prop_tool_torch", bone = 57005, offset = vector3(0.12, 0.03, 0) })
    p:cb_tick(function(pct)
        -- son de checkpoint tous les 25%
        if pct % 25 < 1 then
            PlaySoundFrontend(-1, "CHECKPOINT_NORMAL", "HUD_MINI_GAME_SOUNDSET", true)
        end
    end)
    p:onComplete(function()
        giveCraftedItem()
        exports.LastMenu:notify(function(n) n:message("Soudure terminée !") n:type("success") end)
    end)
    p:onCancel(function()
        exports.LastMenu:notify(function(n) n:message("Soudure annulée.") n:type("warning") end)
    end)
end)
```

---

## Comportement

- Pendant qu'une barre est ouverte, elle **possède la stack** — aucun autre menu ne peut s'ouvrir.
- Utilise `cancel(false)` pour les actions obligatoires (craft, interactions). Utilise `cancel(true)` pour les tâches interruptibles.
- La fermeture programmatique via `bar.close()` ne déclenche **ni** `onComplete` **ni** `onCancel`.
- Les side effects `anim` et `prop` sont nettoyés automatiquement, quelle que soit la façon dont la barre se ferme.
