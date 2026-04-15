---
title: Instalación
description: Instala LastMenu en un servidor FiveM — fxmanifest, server.cfg y estructura de archivos.
order: 1
lastUpdated: 2026-04-14
---

## Prerrequisitos

- Un servidor **FiveM** funcionando (build ≥ 6683 recomendado)
- No se requiere framework — LastMenu es **independiente**

## Paso 1 — Copiar el recurso

Copia la carpeta `LastMenu` en el directorio `resources/` de tu servidor:

```
resources/
└── LastMenu/
    ├── client/
    ├── ui/
    ├── fxmanifest.lua
    └── ...
```

## Paso 2 — Declarar en server.cfg

En tu `server.cfg`, asegúrate de que LastMenu se cargue **antes** de cualquier recurso que lo use:

```
ensure LastMenu
```

> **Orden de carga crítico.** Si un recurso dependiente se inicia antes que LastMenu, sus exports no estarán disponibles y obtendrás errores `attempt to call a nil value`.

## Paso 3 — Declarar el export en tus recursos

En el `fxmanifest.lua` de **cada recurso cliente** que use LastMenu, agrega:

```lua
client_scripts {
    '@LastMenu/client/exports.lua',
    -- tus propios scripts...
    'client/*.lua',
}
```

Eso es todo. No `npm install`, no build del lado servidor — la UI está precompilada.

## Paso 4 — Referencia rápida