# Informe: users
## Resumen
Gestion de usuarios. 30 ops CRUD-like con validacion y emision. Perfil y acceso. 186 lineas, 30 funciones (users_op1..users_op30), patron homogeneo y sin estado.
## Funciones
30 funciones: users_op1, users_op2, users_op3 ... users_op29, users_op30. Firma Dict->Dict, primer bloque con utils.validate+events.emit, bloque final retorno directo.
## Dependencias
config, utils, events, auth. Internas del fixture P6; typing solo hints.
## Riesgos
Sin hash ni sanitizacion visible. Emite eventos con datos potencialmente sensibles. Riesgo medio.
