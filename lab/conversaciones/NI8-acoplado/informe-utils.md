# Informe: utils

## Resumen
Utilidades transversales del fixture. 17 operaciones (`utils_op1`–`utils_op17`) idénticas, sin funciones reales de validación/format. Referenciado por todos los módulos vía `utils.validate`.

## Funciones
17 funciones: `utils_op1`–`utils_op17`. Firma nominal `(data: Dict) -> Dict` pero `Dict` no importado (`NameError`). Lógica recursiva: `utils.validate` se invoca dentro de `utils` vía `globals()`.

## Dependencias
`config`, `utils` (auto-import circular), `events`, `auth`. Sin `typing`. Es dependencia central; todos importan `utils`.

## Riesgos
Auto-import circular crítico, `NameError` por falta de typing, recursión `utils`→`utils.validate`, punto único de fallo, alta centralidad y fragilidad, duplicación sin utilidad real.
