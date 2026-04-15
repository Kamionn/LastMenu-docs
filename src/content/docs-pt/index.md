---
title: LastMenu
description: Sistema de menu universal para FiveM — zero dependências, uma API, reatividade em tempo real.
order: 0
---

## O que é LastMenu?

**LastMenu** é uma biblioteca UI completa para FiveM. Ela unifica todos os tipos de menu comuns (contextual, radial, formulário de entrada, alerta, notificação, barra de progresso, target) sob uma **API builder consistente**, sem precisar de `ox_lib`, `qbx_core` ou qualquer outro framework.

A UI Svelte 5 é **pré-compilada** em `ui/assets/` — nenhum `npm install` necessário no lado do servidor do jogo.

## Por que LastMenu?

| Problema comum | Solução |
|---|---|
| Dependência de `ox_lib` ou um framework | Zero dependências em runtime |
| APIs diferentes por tipo de menu | Um padrão builder para tudo |
| Sem reatividade — fechar/abrir para atualizar | Motor de polling reativo integrado |
| Travado em um framework (ESX / QBCore) | Funciona em qualquer ambiente |