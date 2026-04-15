---
title: Installation
description: Installer LastMenu sur un serveur FiveM — fxmanifest, server.cfg et structure de fichiers.
order: 1
lastUpdated: 2026-04-14
---

## Prérequis

- Un serveur **FiveM** fonctionnel (build ≥ 6683 recommandé)
- Aucun framework requis — LastMenu est **standalone**

## Étape 1 — Copier la ressource

Copie le dossier `LastMenu` dans le répertoire `resources/` de ton serveur :

```
resources/
└── LastMenu/
    ├── client/
    ├── ui/
    ├── fxmanifest.lua
    └── ...
```

## Étape 2 — Déclarer dans server.cfg

Dans ton `server.cfg`, assure-toi que LastMenu est chargé **avant** toute ressource qui l'utilise :

```
ensure LastMenu
```

> **Ordre de chargement critique.** Si une ressource dépendante démarre avant LastMenu, ses exports ne seront pas disponibles et tu obtiendras des erreurs `attempt to call a nil value`.

## Étape 3 — Déclarer l'export dans tes ressources

Dans le `fxmanifest.lua` de **chaque ressource cliente** qui utilise LastMenu, ajoute :

```lua
client_scripts {
    '@LastMenu/client/exports.lua',
    -- tes propres scripts...
    'client/*.lua',
}
```

C'est tout. Pas de `npm install`, pas de build côté serveur — la UI est pré-compilée.

## Étape 4 — Référence courte

Par convention, crée un alias local en tête de chaque fichier Lua :

```lua
local UI = exports['LastMenu']
```

Tu peux aussi utiliser directement `exports.LastMenu:context(...)` si tu préfères.

## Vérification de l'installation

Lance ton serveur et ouvre la console. Tu devrais voir :

```
[LastMenu] v1.0.0 — ready
```

Pour tester rapidement qu'un menu s'affiche, exécute ce code dans un command :

```lua
RegisterCommand('testmenu', function()
    local UI = exports['LastMenu']
    UI:notify(function(n)
        n:message("LastMenu fonctionne !")
        n:type("success")
    end)
end, false)
```

Lance `/testmenu` en jeu — une notification verte devrait apparaître.

## Structure des fichiers LastMenu

| Répertoire / Fichier | Rôle |
|---|---|
| `client/exports.lua` | **Point d'entrée** — seul fichier à importer |
| `client/builders/` | Constructeurs de payload par type de menu |
| `client/bridge.lua` | Couche NUI (batching, callbacks) |
| `client/stack.lua` | Navigation stack, gestion du curseur |
| `client/reactive.lua` | Moteur de réactivité polling diff/patch |
| `client/config.lua` | Flags debug et tunables globaux |
| `ui/` | Interface Svelte 5 pré-compilée |
| `ui/theme/default.css` | Toutes les variables CSS de thématisation |

## Problèmes courants

**`attempt to call a nil value` au démarrage**
→ LastMenu n'est pas encore démarré. Vérifie l'ordre `ensure` dans `server.cfg`.

**La UI ne s'affiche pas**
→ Le dossier `ui/assets/` est manquant ou corrompu. Re-copie la ressource.

**NUI focus bloqué après redémarrage d'une ressource**
→ Appelle `SetNuiFocus(false, false)` depuis la console F8, ou redémarre LastMenu.
