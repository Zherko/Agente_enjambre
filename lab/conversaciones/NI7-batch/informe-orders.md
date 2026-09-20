# Informe: orders

## Resumen
Modulo orders del fixture P6-complex (gestion del ciclo de pedidos). Implementa 17 operaciones homogeneas (orders_op1..orders_op17) que validan entrada con utils.validate y emiten evento.

## Funciones
- 17 funciones: orders_op1 a orders_op17 (firma data: Dict -> Dict).
- Cada op verifica empty, valida y emite "orders.N".
- Sin logica diferenciada; boilerplate repetitivo.

## Dependencias
- Imports: config, utils, events, auth, typing.
- Runtime: utils.validate, events.emit.
- Acoplamiento directo a config/utils/events.

## Riesgos
- Import circular indirecto, validacion fragil con globals(), emit sin transaccionalidad, sin idempotencia en pedidos.
