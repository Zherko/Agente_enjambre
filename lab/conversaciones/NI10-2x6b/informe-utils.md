# Informe: utils

## Resumen
Módulo transversal utils en P6-complex. 121 líneas, 17 operaciones auto-referenciales. Provee `validate` consumido por todos los dominios pero él mismo se importa a sí mismo y replica el patrón valida-emite.

## Funciones
17 funciones `utils_op1`..`op17(data: Dict)->Dict`: guard vacío, `utils.validate(data)` recursivo potencial, `events.emit("utils.N")`, retorno dict. No expone `validate` definido aquí, lo importa.

## Dependencias
Imports: `config`, `utils` (auto-import circular), `events`, `auth`. Falta `from typing import Dict` (NameError). Todos los módulos dependen de él; punto único de fallo.

## Riesgos
Auto-import circular, `Dict` sin importar rompe runtime, recursión `utils.validate` si no resuelta, sin manejo de errores, acoplamiento fan-out total, sin tests unitarios detectables.
