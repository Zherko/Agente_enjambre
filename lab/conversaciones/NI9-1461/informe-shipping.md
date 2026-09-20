# Informe: shipping

## Resumen
Módulo `shipping` del fixture P6-complex (106 líneas). Representa envíos con 17 operaciones genéricas validadas.

## Funciones
17 funciones `shipping_op1` a `shipping_op17`. Misma plantilla que resto de servicios.

## Dependencias
`import config, utils, events`, `import auth`, `from typing import Dict, List`. Usa `utils.validate` y `events.emit("shipping.N", ...)`.

## Riesgos
Sin integración logística real, circularidad, validación superficial, riesgo de eventos huérfanos y duplicación que oculta reglas de negocio.
