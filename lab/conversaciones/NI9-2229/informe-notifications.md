# Informe: notifications
## Resumen
Servicio de notificaciones. 30 ops emisoras con mayor tamano. Maneja side-effects asincronos. 186 lineas, 30 funciones (notifications_op1..notifications_op30), patron homogeneo y sin estado.
## Funciones
30 funciones: notifications_op1, notifications_op2, notifications_op3 ... notifications_op29, notifications_op30. Firma Dict->Dict, primer bloque con utils.validate+events.emit, bloque final retorno directo.
## Dependencias
config, utils, events, auth. Internas del fixture P6; typing solo hints.
## Riesgos
Side-effects sin retry ni DLQ. Tamano mayor sugiere duplicacion. Sin throttling. Riesgo medio.
