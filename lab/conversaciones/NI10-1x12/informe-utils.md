# Informe: utils
## Resumen
Modulo utils con 17 operaciones (utils_op1..17) mas auto-referencia utils.validate. Deberia proveer utilidades.
## Funciones
17 funciones utils_op1..17 (Dict->Dict). Iguales a resto, usan utils.validate recursivo y events.emit utils.N.
## Dependencias
Importa config, utils (circular), events y auth. No importa typing pero usa Dict -> error.
## Riesgos
Circular utils se importa a si mismo. Falta import Dict -> NameError. Duplicacion. Recursion si validate llama a utils_op.
