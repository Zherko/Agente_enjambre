# Informe: shipping

## Resumen
Módulo shipping del fixture P6-complex con 17 operaciones homogéneas de gestión de envíos. Valida entrada, emite eventos y retorna diccionario estructurado. Código altamente repetitivo.

## Funciones
- `shipping_op1` a `shipping_op17` (Dict -> Dict): validan `data` vacío con `{"error": "empty"}`, aplican `utils.validate` condicional, emiten `events.emit("shipping.N", result)` y retornan `{"module": "shipping", "op": N, "data": result}`.

## Dependencias
- `config`, `utils`, `events`, `auth`, `typing.Dict`, `typing.List`. Acoplamiento directo a `utils.validate` y `events.emit`.

## Riesgos
- Validación frágil vía `"utils" in globals()`; `auth` importado sin uso; sin manejo de excepciones en `events.emit`; duplicación masiva (17 funciones idénticas) dificulta mantenimiento; sin validación de esquema ni autenticación efectiva.
