# Informe: orders
## Resumen
Gestion de pedidos. 30 ops de ciclo de vida de orden. Depende de validacion y eventos. 186 lineas, 30 funciones (orders_op1..orders_op30), patron homogeneo y sin estado.
## Funciones
30 funciones: orders_op1, orders_op2, orders_op3 ... orders_op29, orders_op30. Firma Dict->Dict, primer bloque con utils.validate+events.emit, bloque final retorno directo.
## Dependencias
config, utils, events, auth. Internas del fixture P6; typing solo hints.
## Riesgos
Sin validacion de inventario ni pago atomico. Eventos sin saga compensatoria. Riesgo medio.
