# Informe: utils

## Resumen
Modulo utils del fixture P6-complex (utilidades transversales y validacion). Implementa 17 operaciones homogeneas (utils_op1..utils_op17) que validan entrada con utils.validate y emiten evento.

## Funciones
- 17 funciones: utils_op1 a utils_op17 (firma data: Dict -> Dict).
- Cada op verifica empty, valida y emite "utils.N".
- Sin logica diferenciada; boilerplate repetitivo y recursivo.

## Dependencias
- Imports: config, utils (auto-import), events, auth.
- Runtime: utils.validate, events.emit (auto-referencia).
- Acoplamiento directo a config/events.

## Riesgos
- Auto-import circular critico (utils se importa a si mismo), recursion infinita potencial en validate, globals() fragil, falta typing.Dict.
