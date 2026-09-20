# Informe: events

## Resumen
Módulo `events` de P6-complex. Bus de eventos con 17 operaciones homogéneas. Actúa simultáneamente como emisor y definición, generando acoplamiento circular.

## Funciones
17 funciones `events_op1`..`events_op17` con firma `(data: Dict) -> Dict`. Patrón: chequeo vacío, `utils.validate`, `events.emit("events.N", result)` y retorno `{"module":"events","op":N,"data":result}`.

## Dependencias
`config`, `utils`, `events` (auto-import), `auth`, `typing.Dict/List`. Dependencia circular sobre sí mismo y sobre `utils`.

## Riesgos
Circular `import events` dentro de `events.py`; recursión de emisión sin control de backpressure; `emit` sin try/except puede causar cascada; guardia `globals()` frágil; sin tipado de eventos ni idempotencia; duplicación dificulta evolución del esquema.
