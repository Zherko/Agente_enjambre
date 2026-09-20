# Informe: shipping

## Resumen
Módulo shipping de P6-disjunto (103 líneas). 17 ops homogéneas, validan entrada vacía y retornan dict con módulo y op. Sin cálculo logístico; fixture disjunto.

## Funciones
17 funciones: `shipping_op1` a `shipping_op17` (`data: Dict -> Dict`). Mismo guard `if not data: return {"error":"empty"}` y retorno `{"module":"shipping","op":N,"data":result}`.

## Dependencias
`typing.Dict`, `typing.List` (sin uso). Sin imports de otros servicios. Aislado.

## Riesgos
Bajo acoplamiento. Duplicación, sin validación de direcciones, tarifas o tracking. Sin manejo de errores de transporte.
