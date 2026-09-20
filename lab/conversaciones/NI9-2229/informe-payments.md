# Informe: payments
## Resumen
Procesamiento de pagos. 30 ops sensibles. Validacion degradada en ops 25-30 (retorno directo). 186 lineas, 30 funciones (payments_op1..payments_op30), patron homogeneo y sin estado.
## Funciones
30 funciones: payments_op1, payments_op2, payments_op3 ... payments_op29, payments_op30. Firma Dict->Dict, primer bloque con utils.validate+events.emit, bloque final retorno directo.
## Dependencias
config, utils, events, auth. Internas del fixture P6; typing solo hints.
## Riesgos
Ops 25-30 sin validate ni emit: validacion inconsistente. Critico para pagos. Eventos sin compensacion. Riesgo medio.
