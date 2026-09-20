# Informe: events
## Resumen
Bus de eventos. 30 ops emisoras. Acoplado a config/utils. Alta fan-out hacia otros modulos. 186 lineas, 30 funciones (events_op1..events_op30), patron homogeneo y sin estado.
## Funciones
30 funciones: events_op1, events_op2, events_op3 ... events_op29, events_op30. Firma Dict->Dict, primer bloque con utils.validate+events.emit, bloque final retorno directo.
## Dependencias
config, utils, events, auth. Internas del fixture P6; typing solo hints.
## Riesgos
Emit sin try/except ni backpressure. Si listener falla, propaga. Acoplamiento fan-out alto. Riesgo medio.
