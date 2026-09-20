# Informe: inventory

## Resumen
Módulo `inventory` del fixture P6-complex (106 líneas). Representa inventario con 17 operaciones repetitivas validadas y publicadas como eventos.

## Funciones
17 funciones `inventory_op1` a `inventory_op17`. Lógica clonada, sin diferenciación por operación.

## Dependencias
`import config, utils, events`, `import auth`, `from typing import Dict, List`. Usa `utils.validate` y `events.emit("inventory.N", ...)`.

## Riesgos
Sin control de stock ni concurrencia, imports circulares, validación trivial, riesgo de inundación de eventos y mantenimiento costoso por duplicación.
