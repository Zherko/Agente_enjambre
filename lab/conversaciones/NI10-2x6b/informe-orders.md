# Informe: orders

## Resumen
Módulo de dominio orders en P6-complex. 122 líneas, 17 operaciones clonadas con flujo valida-emite-retorna. Estructura idéntica a otros servicios del fixture, sin reglas de pedido reales.

## Funciones
17 funciones `orders_op1`..`op17(data: Dict)->Dict`: verifica vacío, aplica `utils.validate`, emite `orders.N` vía `events.emit`, retorna dict con `module`, `op` y `data`.

## Dependencias
Imports: `config`, `utils`, `events`, `auth`, `typing`. Dependencia runtime sobre `utils.validate` y bus `events`. No expone dependencias externas.

## Riesgos
Clonación masiva sin abstracción, validación condicional inestable, eventos fire-and-forget sin confirmación, errores silenciados como dict, alto acoplamiento a `utils`.
