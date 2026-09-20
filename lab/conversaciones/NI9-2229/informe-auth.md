# Informe: auth
## Resumen
Servicio de autenticacion. 30 ops de validacion y emision. Punto critico de seguridad por dependencia circular. 186 lineas, 30 funciones (auth_op1..auth_op30), patron homogeneo y sin estado.
## Funciones
30 funciones: auth_op1, auth_op2, auth_op3 ... auth_op29, auth_op30. Firma Dict->Dict, primer bloque con utils.validate+events.emit, bloque final retorno directo.
## Dependencias
config, utils, events, auth. Internas del fixture P6; typing solo hints.
## Riesgos
Auto-import circular; riesgo RecursionError. Validacion via globals fragil. Sin manejo de tokens. Riesgo medio.
