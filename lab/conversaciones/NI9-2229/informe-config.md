# Informe: config
## Resumen
Modulo de configuracion global. 30 ops triviales que leen config y validan. Base compartida por todos. 184 lineas, 30 funciones (config_op1..config_op30), patron homogeneo y sin estado.
## Funciones
30 funciones: config_op1, config_op2, config_op3 ... config_op29, config_op30. Firma Dict->Dict, primer bloque con utils.validate+events.emit, bloque final retorno directo.
## Dependencias
config, utils, events. Internas del fixture P6; typing solo hints.
## Riesgos
Config global mutable compartida por 11 modulos; cambio rompe todo. Sin validacion de esquema ni cache. Riesgo medio.
