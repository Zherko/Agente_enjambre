# Informe: orders
## Resumen
Modulo orders con 17 operaciones (orders_op1..17). Mock de gestion pedidos sin estado ni persistencia.
## Funciones
17 funciones orders_op1..17 (Dict->Dict). Implementacion repetida validate+emit+return. Sin diferenciacion.
## Dependencias
Importa config, utils, events, auth y typing. Acoplado a utils.validate y events.emit.
## Riesgos
Sin transacciones ni idempotencia. Duplicacion. Riesgo inconsistencia pedidos si utils.validate es no-op.
