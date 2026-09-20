# Informe: gateway

## Resumen
Fachada de entrada de P6-complex. Centraliza 17 operaciones genéricas que validan payload y propagan eventos. Patrón uniforme sin lógica de negocio diferenciada.

## Funciones
17 funciones `gateway_op1`..`gateway_op17` (122 líneas). Cada una: guarda `empty` si data vacío, valida vía `utils.validate`, emite `gateway.N` y retorna `{module, op, data}`.

## Dependencias
`config`, `utils`, `events`, `auth`, `typing.Dict/List`. Críticas: `utils.validate` y `events.emit`. Uso de `globals()` para check dinámico de `utils`.

## Riesgos
Duplicación extrema (DRY violado), `auth` importado sin uso, validación condicional frágil, emisión síncrona sin try/catch, sin tipado de retorno ni tests; ampliación de superficie de ataque.
