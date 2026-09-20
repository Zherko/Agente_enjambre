# Informe: analytics

## Resumen
Módulo analytics de P6-complex (122 líneas). Expone lógica de analítica con 17 operaciones homogéneas. Valida entrada, emite evento y retorna diccionario con módulo, operación y datos.

## Funciones
17 funciones: `analytics_op1` a `analytics_op17` (analytics.py:5-122). Firma `data: Dict -> Dict`. Flujo idéntico: guarda `{"error":"empty"}` si `data` vacío, `utils.validate`, `events.emit("analytics.N", result)`.

## Dependencias
`config`, `utils`, `events`, `auth` (analytics.py:2-3) y `typing.Dict/List`. Dependencia fuerte a `utils.validate` y `events.emit`. `auth` importado sin uso directo.

## Riesgos
Auto-import indirecto vía `auth`/`events`; validación frágil con `globals()`; sin manejo de excepciones en `emit`; sin autenticación pese a importar `auth`; duplicación masiva dificulta mantenimiento.
