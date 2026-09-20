# Informe: events

## Resumen
Módulo events de P6-complex (122 líneas). Centraliza emisión de eventos con 17 operaciones homogéneas. Valida datos y re-emite sobre sí mismo, funcionando como bus interno.

## Funciones
17 funciones: `events_op1` a `events_op17` (events.py:5-122). Firma `data: Dict -> Dict`. Flujo: error si vacío, `utils.validate`, `events.emit("events.N", result)` y retorno estructurado.

## Dependencias
`config`, `utils`, `events` (auto-import), `auth` y `typing.Dict/List` (events.py:2-4). Fuerte acoplamiento circular `events`->`events` y dependencia de `utils.validate`.

## Riesgos
Recursión/import circular `import events` + `events.emit`; riesgo de bucle infinito si handler re-invoca; `auth` no usado; `emit` sin manejo de errores ni backpressure; validación frágil vía `globals()`; duplicación total.
