# Informe: shipping

## Resumen
Modulo shipping del fixture P6-complex (logica de envios y logistica). Implementa 17 operaciones homogeneas (shipping_op1..shipping_op17) que validan entrada con utils.validate y emiten evento.

## Funciones
- 17 funciones: shipping_op1 a shipping_op17 (firma data: Dict -> Dict).
- Cada op verifica empty, valida y emite "shipping.N".
- Sin logica diferenciada; boilerplate repetitivo.

## Dependencias
- Imports: config, utils, events, auth, typing.
- Runtime: utils.validate, events.emit.
- Acoplamiento directo a config/utils/events.

## Riesgos
- Import circular indirecto, validacion con globals() fragil, emit sin manejo de errores, sin trazabilidad de envios.
