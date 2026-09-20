# Informe: shipping

## Resumen
Servicio de envíos del fixture. 17 operaciones (`shipping_op1`–`shipping_op17`) plantilla, sin cálculo tarifa, tracking ni integración logística.

## Funciones
17 funciones: `shipping_op1`–`shipping_op17`. Firma `(data: Dict) -> Dict`. Patrón estándar de validación y emisión `shipping.N`.

## Dependencias
`config`, `utils`, `events`, `auth`, `typing (Dict, List)`.

## Riesgos
Funcionalidad logística ausente, duplicación, dependencia innecesaria de `auth`, fragilidad `globals()` check, sin manejo de estados de envío.
