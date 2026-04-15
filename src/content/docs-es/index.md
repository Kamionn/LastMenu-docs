---
title: LastMenu
description: Sistema de menús universal para FiveM — cero dependencias, una API, reactividad en tiempo real.
order: 0
---

## ¿Qué es LastMenu?

**LastMenu** es una biblioteca UI completa para FiveM. Unifica todos los tipos de menú comunes (contextual, radial, formulario de entrada, alerta, notificación, barra de progreso, target) bajo una **API builder consistente**, sin requerir `ox_lib`, `qbx_core` ni ningún otro framework.

La UI de Svelte 5 está **precompilada** en `ui/assets/` — no se requiere `npm install` del lado del servidor de juego.

## ¿Por qué LastMenu?

| Problema común | Solución |
|---|---|
| Dependencia de `ox_lib` o un framework | Cero dependencias en runtime |
| APIs diferentes por tipo de menú | Un patrón builder para todo |
| Sin reactividad — cerrar/abrir para refrescar | Motor de polling reactivo integrado |
| Bloqueado a un framework (ESX / QBCore) | Funciona en cualquier entorno |
