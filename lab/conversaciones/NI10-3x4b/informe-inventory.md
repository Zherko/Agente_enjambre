# Informe: inventory

## Resumen
Módulo de gestión de stock de P6-complex. Expone 17 operaciones genéricas que validan inventario y emiten eventos. Estructura idéntica a gateway sin reglas de dominio.

## Funciones
17 funciones `inventory_op1`..`inventory_op17` (122 líneas). Flujo idéntico: check vacío, `utils.validate(data)`, `events.emit("inventory.N")`, retorno dict.

## Dependencias
`config`, `utils`, `events`, `auth`, `typing`. Fuerte acoplamiento a `utils` y `events`. `auth` no aplicado pese a ser crítico para stock.

## Riesgos
Código clonado, sin control de concurrencia ni atomicidad, sin validación de cantidades negativas, eventos sin garantía de entrega, `auth` inerte expone manipulación de stock.
