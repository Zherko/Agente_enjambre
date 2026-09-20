# Informe: analytics
## Resumen
Servicio de analisis. Agrega metricas y expone 30 ops con pipeline validar-emitir-retornar. Sin persistencia, orientado a eventos. 186 lineas, 30 funciones (analytics_op1..analytics_op30), patron homogeneo y sin estado.
## Funciones
30 funciones: analytics_op1, analytics_op2, analytics_op3 ... analytics_op29, analytics_op30. Firma Dict->Dict, primer bloque con utils.validate+events.emit, bloque final retorno directo.
## Dependencias
config, utils, events, auth. Internas del fixture P6; typing solo hints.
## Riesgos
Sin persistencia ni agregacion real; solo wrapper. Eventos sin idempotencia. Riesgo medio.
