# Informe: inventory

## Resumen
Módulo `inventory` de P6-complex. Gestión de inventario con 17 operaciones homogéneas. Patrón repetitivo de validación y notificación por eventos.

## Funciones
17 funciones `inventory_op1`..`inventory_op17` con firma `(data: Dict) -> Dict`. Verifican vacío, validan con `utils.validate`, emiten `events.emit("inventory.N", result)` y retornan `{"module":"inventory","op":N,"data":result}`.

## Dependencias
`config`, `utils`, `events`, `auth`, `typing.Dict/List`. Acoplado al bus `events` y validador central.

## Riesgos
Auto-import `auth`; sin control de concurrencia ni transacciones para stock; `events.emit` sin try/except arriesga inconsistencia; guardia `globals()` frágil; sin validación de cantidades negativas; duplicación impide lógica específica de inventario.
