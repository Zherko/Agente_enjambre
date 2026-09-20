# Informe: shipping
## Resumen
Módulo de dominio shipping: 122 líneas, 17 operaciones homogéneas (`shipping_op1`–`op17`) con flujo idéntico — guarda empty, validación vía `utils.validate`, emisión de evento y retorno dict. Sin especialización logística.
## Funciones
17 funciones `shipping_opN(data: Dict)->Dict` con misma firma y cuerpo: retorno `{"error":"empty"}` si vacío, `events.emit("shipping.N")`.
## Dependencias
`config`, `utils`, `events`, `auth` y `typing.Dict/List`. Depende del bus `events` y del validador `utils`.
## Riesgos
Duplicación total, validación condicional frágil, `List` no usado, sin manejo de estados de envío ni reintentos, sin tipado de salida diferenciado.
