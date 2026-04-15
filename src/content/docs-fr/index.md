---
title: LastMenu
description: Système de menus universel et standalone pour FiveM — zéro dépendance, une seule API, réactivité temps réel.
order: 0
---

## Qu'est-ce que LastMenu ?

**LastMenu** est une bibliothèque UI complète pour FiveM. Elle unifie tous les types de menus courants (contextuel, radial, formulaire, alerte, notification, barre de progression, target) sous une **API builder cohérente**, sans nécessiter `ox_lib`, `qbx_core` ni aucun autre framework.

La UI Svelte 5 est **pré-compilée** dans `ui/assets/` — aucun `npm install` n'est requis côté serveur de jeu.

## Pourquoi LastMenu ?

| Problème courant | Solution |
|---|---|
| Dépendance à `ox_lib` ou un framework | Zéro dépendance runtime |
| API différente par type de menu | Un seul pattern builder pour tout |
| Pas de réactivité — fermer/rouvrir pour rafraîchir | Moteur réactif polling intégré |
| Verrouillé à un framework (ESX / QBCore) | Fonctionne dans n'importe quel environnement |
| Bugs de watcher crashent tout le menu | Safe Mode désactive automatiquement les watchers défectueux |
| Le retour arrière revient au mauvais niveau | Navigation stack préserve toute la profondeur |

## Premiers pas

Commence par l'[Installation](/docs/introduction/installation) pour mettre LastMenu en place sur ton serveur, puis consulte le [Quick Start](/docs/introduction/quickstart) pour des exemples concrets.

## Aperçu rapide

Toute l'API LastMenu suit le même pattern : un appel d'export + une fonction builder.

```lua
local UI = exports['LastMenu']

-- Menu contextuel
UI:context(function(menu)
    menu:title("Mon Menu")
    menu:button("Dire bonjour", {
        icon = "hand",
        cb   = function() print("Bonjour !") end
    })
end)

-- Notification
UI:notify(function(n)
    n:message("Action réussie.")
    n:type("success")
end)

-- Formulaire bloquant (dans un Citizen.CreateThread)
local values = UI:input_async(function(b)
    b:title("Achat")
    b:field("Quantité", { type = "number", min = 1, max = 10 })
end)
```

## Structure de la documentation

| Section | Contenu |
|---|---|
| [Installation](/docs/introduction/installation) | fxmanifest, server.cfg, premiers pas |
| [Quick Start](/docs/introduction/quickstart) | Exemples concrets par cas d'usage |
| [Context Menu](/docs/composants/context-menu) | Menu vertical — tous les types d'items |
| [Radial Menu](/docs/composants/radial) | Roue circulaire d'actions rapides |
| [Input Form](/docs/composants/input) | Formulaires multi-champs modaux |
| [Modal / Alert](/docs/composants/modal) | Boîtes de confirmation |
| [Notifications](/docs/composants/notifications) | Toasts non-bloquants |
| [Progress Bar](/docs/composants/progress) | Barre de progression avec side-effects |
| [Target System](/docs/composants/target) | Remplacement ox_target / qtarget |
| [Réactivité](/docs/avance/reactivite) | Moteur de polling diff/patch |
| [API Async](/docs/avance/async-api) | input_async et alert_async (coroutine-style) |
| [Sous-menus & Stack](/docs/avance/sous-menus) | Navigation stack et imbrication |
| [Thématisation](/docs/personnalisation/theming) | Variables CSS custom properties |
| [Migration](/docs/personnalisation/migration) | Depuis ox_lib, RageUI, qb-menu |
| [Débogage](/docs/personnalisation/debugging) | Outils de diagnostic intégrés |
| [Pièges courants](/docs/personnalisation/pitfalls) | Anti-patterns à éviter absolument |
