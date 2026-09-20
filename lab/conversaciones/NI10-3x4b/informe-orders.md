# Informe: orders

## Resumen
Módulo de pedidos de P6-complex. Implementa 17 operaciones genéricas validadas y publicadas como `orders.N`. Sin máquina de estados ni persistencia observable.

## Funciones
17 funciones `orders_op1`..`orders_op17` (122 líneas). Cada una valida dict, emite evento y retorna `{module:"orders", op:N, data}`. Sin diferenciación funcional.

## Dependencias
`config`, `utils`, `events`, `auth`, `typing`. Núcleo en `utils.validate` y `events.emit`. `auth` importado pero no verificado.

## Riesgos
Clonación masiva, sin validación de transiciones de pedido, sin idempotencia, sin manejo de errores de `events`, `auth` ocioso permite creación fraudulenta, sin tests unitarios.
