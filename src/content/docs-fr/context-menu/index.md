---
title: Context Menu
description: Menu contextuel vertical — le composant principal de LastMenu. Supporte tous les types d'items, la réactivité temps réel, les onglets, accordéons et sous-menus.
order: 1
lastUpdated: 2026-04-14
---

## Ouverture

```lua
local UI = exports['LastMenu']

UI:context(function(menu)
    menu:title("Mon Menu")
    menu:button("Cliquer", { cb = function() print("cliqué") end })
end)
```

Le menu s'ouvre immédiatement. Il se ferme sur `Escape` ou en appelant le callback approprié.

---

## Options générales

Ces méthodes se placent en **tête de builder**, avant les items.

| Méthode | Type | Défaut | Description |
|---|---|---|---|
| `menu:title(str)` | string | `''` | Titre affiché dans l'en-tête |
| `menu:banner(url)` | string | nil | Image au-dessus du titre (`https://` ou `nui://`) |
| `menu:description(txt)` | string | nil | Sous-titre affiché sous le titre |
| `menu:animation(anim)` | string | `'slideLeft'` | Animation d'ouverture : `'slideLeft'` `'slideRight'` `'fade'` `'scale'` |
| `menu:nav(mode)` | string | `'both'` | Mode de navigation : `'mouse'` `'keyboard'` `'both'` |
| `menu:search()` | — | — | Force l'affichage de la barre de recherche |
| `menu:page_size(n)` | number | 20 | Items par page (pagination automatique au-delà) |
| `menu:scroll()` | — | — | Désactive la pagination — scroll natif sur tous les items |

### Mode scroll

Utilise `menu:scroll()` pour les longues listes où la pagination crée des frictions :

```lua
UI:context(function(menu)
    menu:title("Inventaire")
    menu:scroll()  -- tous les items visibles, le conteneur défile

    for i = 1, 50 do
        menu:button("Item #" .. i, { cb = function() end })
    end
end)
```

> `menu:scroll()` et `menu:page_size()` sont mutuellement exclusifs. `scroll()` prend la priorité.

---

## Types d'items

### button

Le type d'item le plus courant. Supporte icônes, badges, hotkeys, gradient, hold-to-confirm, cooldown et panneau de prévisualisation.

```lua
menu:button(label, opts)
```

| Option | Type | Description |
|---|---|---|
| `icon` | string | Nom d'icône Lucide (`"wrench"`, `"car"`, `"zap"`) |
| `color` | string | Couleur accent de l'icône et du gradient (hex) |
| `gradient` | bool | Fond dégradé coloré |
| `badge` | string | Badge à droite (`"NOUVEAU"`, `"500 €"`) |
| `hint` | string | Texte discret à droite |
| `hotkey` | string | Label de raccourci clavier affiché en `<kbd>` |
| `arrow` | bool | Affiche `›` (indique un sous-menu) |
| `confirm_hold` | bool/number | `true` = tenir 1,5s ; un nombre = durée custom en ms |
| `cooldown` | number | Millisecondes avant de pouvoir recliquer |
| `persist_key` | string | Clé stable pour la persistance du cooldown quand le label est dynamique |
| `keep_open` | bool | Ne ferme pas le menu au clic |
| `timeout` | number | Désactive automatiquement l'item après N ms |
| `preview` | table | Panneau de prévisualisation au survol (voir ci-dessous) |
| `visible` | bool/fn | Cache l'item (supporte une fonction réactive) |
| `disabled` | bool/fn | Désactive l'item (supporte une fonction réactive) |
| `refresh` | number | Intervalle de polling en ms pour `visible`/`disabled` |
| `cb` | function | Appelé au clic |

**Panneau de prévisualisation** — affiché à droite du menu au survol :

```lua
preview = {
    image = "https://i.imgur.com/exemple.jpeg",  -- optionnel
    title = "Réparation moteur",
    desc  = "Restaure le moteur à 100 %.",
    stats = {
        { label = "Avant", value = 20,  max = 100 },
        { label = "Après", value = 100, max = 100, color = "#4ade80" },
    },
}
```

**Exemples :**

```lua
-- Bouton simple
menu:button("Réparer le moteur", {
    icon = "wrench",
    cb   = function() print("réparé") end,
})

-- Badge + gradient + couleur
menu:button("Acheter l'item", {
    icon     = "shopping-cart",
    color    = "#4ade80",
    gradient = true,
    badge    = "500 €",
    cb       = function() end,
})

-- Hold-to-confirm
menu:button("Supprimer la sauvegarde", {
    icon         = "trash",
    confirm_hold = true,
    cb           = function() print("supprimé") end,
})

-- Cooldown 5 secondes
menu:button("Utiliser le pouvoir", {
    icon     = "zap",
    cooldown = 5000,
    cb       = function() print("pouvoir activé") end,
})

-- Auto-expire après 8 secondes
menu:button("Offre limitée", {
    icon    = "clock",
    badge   = "EXPIRE",
    timeout = 8000,
    cb      = function() print("offre acceptée !") end,
})
```

> **Label dynamique** — passe une **fonction** comme label pour un texte mis à jour en temps réel. Voir [Réactivité](/docs/avance/reactivite).

---

### slider

Curseur horizontal avec min/max/step.

```lua
menu:slider("Volume", {
    icon    = "volume-2",
    min     = 0,
    max     = 100,
    step    = 5,
    default = 80,
    suffix  = "%",
    cb      = function(value) print("Volume :", value) end,
})
```

Navigation clavier : `←` `→` pour déplacer. Souris : glisser sur la piste.

---

### stepper

Contrôle `−` / valeur / `+` pour des entiers.

```lua
menu:stepper("Kits de réparation", {
    icon    = "package",
    min     = 0,
    max     = 10,
    step    = 1,
    default = 2,
    cb      = function(value) print("Kits :", value) end,
})
```

---

### checkbox

Case à cocher carrée pour un booléen.

```lua
menu:checkbox("Activer le turbo", {
    icon    = "zap",
    default = false,
    cb      = function(checked) print("Turbo :", checked) end,
})
```

Navigation clavier : `Entrée` ou `Espace` pour basculer.

---

### toggle

Interrupteur animé ON/OFF (style pill switch).

```lua
menu:toggle("Mode furtif", {
    icon    = "eye-off",
    default = true,
    cb      = function(enabled) print("Furtif :", enabled) end,
})
```

---

### list

Carrousel `‹ valeur ›` pour une liste d'options.

```lua
menu:list("Type de carburant", {
    icon    = "fuel",
    items   = { "Essence", "Diesel", "Électrique", "Hybride" },
    default = 1,   -- index 1-based
    cb      = function(index, value) print("Carburant :", value) end,
})
```

Navigation clavier : `←` `→` pour cycler.

---

### stat

Barre de progression en lecture seule. La couleur par défaut est l'accent choisi par le joueur (F12). Passe `color = "auto"` pour le mode vert/orange/rouge basé sur le ratio.

```lua
-- Signature v1.0.0 (recommandée)
menu:stat("Moteur", {
    value  = 78,
    max    = 100,
    icon   = "activity",
    suffix = "%",
})

-- Avec couleur auto
menu:stat("Santé", {
    value  = 45,
    max    = 100,
    color  = "auto",  -- rouge car < 50%
    icon   = "heart",
    suffix = "hp",
})

-- Valeur réactive
menu:stat("Santé", {
    value   = function() return GetEntityHealth(PlayerPedId()) - 100 end,
    max     = 100,
    icon    = "heart",
    suffix  = "hp",
    refresh = 500,
})
```

---

### input_inline

Champ de saisie texte ou nombre intégré dans la ligne du menu.

```lua
menu:input_inline("Nom du véhicule", {
    icon        = "edit",
    type        = "text",
    placeholder = "Mon bolide...",
    default     = "",
    maxlen      = 24,
    cb          = function(value) print("Nom :", value) end,
})

menu:input_inline("Limite de vitesse", {
    icon    = "gauge",
    type    = "number",
    default = 80,
    min     = 0,
    max     = 300,
    cb      = function(value) print("Vitesse :", value) end,
})
```

Navigation : `Entrée` sur la ligne → focus le champ. `Entrée` dans le champ → confirme. `Escape` → désfocalise.

---

### color_picker

Palette de couleurs avec grille de presets et saisie manuelle.

```lua
menu:color_picker("Couleur de carrosserie", {
    icon    = "palette",
    default = "#e94560",
    presets = { "#e94560", "#60a5fa", "#4ade80" },
    cb      = function(hex) print("Couleur :", hex) end,
})
```

---

### date_picker

Trois champs numériques jour/mois/année. Retourne une chaîne ISO `"YYYY-MM-DD"`.

```lua
menu:date_picker("Date de révision", {
    icon    = "calendar",
    default = "2025-06-15",
    cb      = function(date) print("Date :", date) end,
})
```

---

### separator

Ligne de séparation horizontale fine.

```lua
menu:separator()
```

---

### header

Label de section (majuscules, atténué).

```lua
menu:header("Statistiques du véhicule", { color = "#60a5fa" })
```

---

### accordion

Section repliable/dépliable. Tous les types d'items peuvent être imbriqués.

```lua
menu:accordion("Infos joueur", function(acc)
    acc:stat("Santé",  85, 100, { icon = "heart",  suffix = "%" })
    acc:stat("Armure", 60, 100, { icon = "shield", suffix = "%" })
    acc:button("Soigner", {
        icon = "plus-circle",
        cb   = function() print("soigné") end,
    })
end, {
    icon = "user",
    open = true,    -- déplié par défaut
})
```

> Les boutons dans un accordion ont `keep_open = true` par défaut. Pour fermer le menu au clic, ajoute `keep_open = false` sur le bouton.

Navigation clavier : `Entrée` sur l'en-tête de l'accordion pour basculer.

---

### tab

Organise les items en onglets nommés. La barre d'onglets apparaît automatiquement.

```lua
menu:tab("Armes", function(t)
    t:button("Pistolet", { icon = "crosshair", badge = "500 €", cb = function() end })
    t:button("Fusil",    { icon = "crosshair", badge = "1 200 €", cb = function() end })
end, { icon = "crosshair" })

menu:tab("Munitions", function(t)
    t:button("9mm x50",     { icon = "package", badge = "80 €",  cb = function() end })
    t:button("Rifle x30",   { icon = "package", badge = "120 €", cb = function() end })
end, { icon = "package" })
```

> Les items placés **hors** d'un bloc tab restent toujours visibles (au-dessus des onglets).

---

## Contrôles clavier

| Touche | Action |
|---|---|
| `↑` / `↓` | Naviguer entre les items |
| `←` / `→` | Slider / Stepper / List |
| `Entrée` | Activer l'item sélectionné |
| `Espace` | Toggle / Checkbox |
| `Escape` | Fermer / Revenir au menu parent |
| `F12` | Ouvrir les paramètres utilisateur |

---

## Paramètres utilisateur

Les joueurs peuvent ouvrir le **panneau de paramètres** à tout moment via **F12** :

- **Mode de navigation** — Souris / Clavier / Les deux
- **Couleur d'accent** — 10 presets + sélecteur libre
- **Taille de police** — 80% à 130%
- **Réinitialiser la position** — remet le menu à sa position par défaut

Les paramètres sont sauvegardés en `localStorage`. Les options `menu:nav('mouse')` / `menu:nav('keyboard')` du développeur ont toujours la priorité sur le réglage global du joueur.

---

## Sécurité

- **Les callbacks sont côté client uniquement.** LastMenu n'émet aucun événement réseau. La validation serveur est la responsabilité du développeur.
- **Les URLs de banner** sont filtrées : seuls les schémas `https://` et `nui://` sont acceptés.
- **L'injection CSS** est bloquée — les valeurs de couleur et de style sont nettoyées avant d'être appliquées aux styles inline.
