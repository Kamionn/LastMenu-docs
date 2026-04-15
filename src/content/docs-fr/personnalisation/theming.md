---
title: Thématisation
description: Personnaliser l'apparence de LastMenu via des variables CSS custom properties — couleurs, typographie, layout, radial et notifications.
order: 1
lastUpdated: 2026-04-14
---

## Principe

LastMenu utilise exclusivement des **CSS custom properties** pour le theming. Aucune valeur n'est codée en dur dans les composants — tout est surchargeable.

---

## Mise en place

**1. Créer un fichier CSS de thème** (ex. `ui/theme/mytheme.css`)

**2. Le déclarer dans `fxmanifest.lua` après `ui/theme/**` :**

```lua
files {
    'ui/index.html',
    'ui/assets/**',
    'ui/theme/**',
    'ui/theme/mytheme.css',  -- ton thème
}
```

**3. Le charger dans `ui/index.html` après le lien par défaut :**

```html
<link rel="stylesheet" href="./theme/default.css">
<link rel="stylesheet" href="./theme/mytheme.css">
```

**4. Dans `mytheme.css`, surcharger uniquement les variables nécessaires :**

```css
:root {
    --ui-accent:     #00ffcc;
    --ui-ctx-bg:     rgba(5, 5, 10, 0.97);
    --ui-ctx-radius: 2px;
}
```

---

## Variables de référence

### Couleurs globales

| Variable | Défaut | Usage |
|---|---|---|
| `--ui-accent` | `#e94560` | Couleur principale (boutons actifs, badges, toggles ON) |
| `--ui-accent-dim` | `#c73652` | Variante sombre (hover states) |
| `--ui-accent-text` | `#ffffff` | Texte sur fond accent |
| `--ui-success` | `#4ade80` | Notifications success, stat bar haute |
| `--ui-warning` | `#fb923c` | Notifications warning |
| `--ui-error` | `#f87171` | Notifications error, stat bar basse |
| `--ui-info` | `#60a5fa` | Notifications info |

### Typographie

| Variable | Défaut | Usage |
|---|---|---|
| `--ui-font-body` | Inter | Police principale |
| `--ui-font-heading` | Rajdhani | Titres des menus |
| `--ui-font-scale` | `1` | Échelle globale (modifié par le panel utilisateur) |
| `--ui-font-size-base` | `13px × scale` | Taille de base des items |

### Context menu — Layout

| Variable | Défaut | Usage |
|---|---|---|
| `--ui-ctx-top` | `72px` | Distance depuis le haut |
| `--ui-ctx-left` | `16px` | Distance depuis la gauche |
| `--ui-ctx-width` | `320px` | Largeur du panneau |
| `--ui-ctx-item-height` | `40px` | Hauteur minimale d'un item |
| `--ui-ctx-radius` | `8px` | Rayon des coins du panneau |

### Context menu — Couleurs

| Variable | Défaut |
|---|---|
| `--ui-ctx-bg` | `rgba(12, 12, 22, 0.97)` |
| `--ui-ctx-bg-hover` | `rgba(255,255,255,0.08)` |
| `--ui-ctx-text` | `rgba(255,255,255,0.82)` |
| `--ui-ctx-text-dim` | `rgba(255,255,255,0.45)` |
| `--ui-ctx-border` | `rgba(255,255,255,0.07)` |

---

## Thèmes prêts à l'emploi

Trois thèmes d'exemple sont commentés dans `ui/theme/default.css` — décommente et copie dans ton fichier :

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

## Accent dynamique (panel utilisateur)

Le joueur peut définir une couleur d'accent personnalisée depuis les Paramètres (F12). `--ui-accent` et `--ui-accent-dim` sont alors recalculés dynamiquement par `App.svelte`.

Pour désactiver cette fonctionnalité, supprime le champ `accentColor` de `loadSettings()` dans `ui/src/App.svelte`.

---

## Polices personnalisées

**1. Placer les fichiers font dans `ui/theme/fonts/`**

**2. Les déclarer dans ton CSS :**

```css
@font-face {
    font-family: 'MaFont';
    src: url('./fonts/mafont.woff2') format('woff2');
}
:root {
    --ui-font-body: 'MaFont', sans-serif;
}
```

**3. Ajouter dans `fxmanifest.lua` :**

```lua
files {
    'ui/theme/fonts/**',
}
```

---

## Toutes les variables

Consulte `ui/theme/default.css` pour la liste exhaustive de toutes les variables disponibles, avec commentaires inline.
