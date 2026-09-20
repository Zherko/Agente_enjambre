# Informe: gateway
## Resumen
Puerta de entrada API. 30 ops que validan y emiten eventos. Facade sobre servicios internos. 186 lineas, 30 funciones (gateway_op1..gateway_op30), patron homogeneo y sin estado.
## Funciones
30 funciones: gateway_op1, gateway_op2, gateway_op3 ... gateway_op29, gateway_op30. Firma Dict->Dict, primer bloque con utils.validate+events.emit, bloque final retorno directo.
## Dependencias
config, utils, events, auth. Internas del fixture P6; typing solo hints.
## Riesgos
Fachada sin rate-limit ni auth-check explicito. Reenvio ciego a eventos. Superficie expuesta. Riesgo medio.
