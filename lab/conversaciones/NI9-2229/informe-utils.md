# Informe: utils
## Resumen
Utilidades transversales. 30 ops y funcion validate usada por todos. Alto acoplamiento y auto-import. 185 lineas, 30 funciones (utils_op1..utils_op30), patron homogeneo y sin estado.
## Funciones
30 funciones: utils_op1, utils_op2, utils_op3 ... utils_op29, utils_op30. Firma Dict->Dict, primer bloque con utils.validate+events.emit, bloque final retorno directo.
## Dependencias
config, utils, events, auth. Internas del fixture P6; typing solo hints.
## Riesgos
Auto-import circular. validate() sin contrato tipado; fallo silencioso si falta. Punto unico de fallo. Riesgo medio.
