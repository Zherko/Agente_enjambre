# Informe: utils

## Resumen
Módulo utils de P6-disjunto (102 líneas). 17 operaciones genéricas con misma lógica mínima que el resto del fixture. Sin utilidades reales; fixture disjunto.

## Funciones
17 funciones: `utils_op1` a `utils_op17` (`data: Dict -> Dict`). Replican `if not data: return {"error":"empty"}` y `{"module":"utils","op":N,"data":result}`.

## Dependencias
Usa `Dict` en firmas pero **sin** `from typing import Dict` (igual que config). Sin dependencias internas. Aislado.

## Riesgos
Riesgo alto: `NameError` por `Dict` no importado. Duplicación masiva, sin helpers reutilizables. Rompe en import si se evalúan anotaciones en runtime.
