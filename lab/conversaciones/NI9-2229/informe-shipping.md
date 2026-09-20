# Informe: shipping
## Resumen
Logistica de envios. 30 ops de despacho. Similar a orders, sin logica de calculo visible. 186 lineas, 30 funciones (shipping_op1..shipping_op30), patron homogeneo y sin estado.
## Funciones
30 funciones: shipping_op1, shipping_op2, shipping_op3 ... shipping_op29, shipping_op30. Firma Dict->Dict, primer bloque con utils.validate+events.emit, bloque final retorno directo.
## Dependencias
config, utils, events, auth. Internas del fixture P6; typing solo hints.
## Riesgos
Sin calculo de costo ni tracking real. Dependencia ciega a orders/payments. Riesgo medio.
