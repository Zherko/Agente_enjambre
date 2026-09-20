# Proyecto P3-ANALISIS-PIPELINE
# Tipo: REQUIERE SESIÓN (Regla 0 nivel 3)
# Fixture: P3-pipeline/ (6 archivos, ~180 lineas total)
# Objetivo: medir si Enjambre paralelo gana vs basal en análisis de flujo de datos

## Prompt verbatim

Analiza la pipeline de datos en lab/fixture/P3-pipeline/ (config.py, extract.py, transform.py, validate.py, load.py, orchestrate.py). Redacta un informe completo en lab/conversaciones/P3-<RAMA>-rep<N>/informe-pipeline.md con estos encabezados:

# Informe: Pipeline de Datos
## Resumen (max 80 palabras)
## Flujo de Datos (paso a paso: extract → transform → validate → load, qué hace cada paso)
## Dependencias entre Módulos (qué archivo importa de cuál, en lista)
## Funciones Principales (nombre: firma, max 1 línea por función)
## Riesgos (max 5 bullet points: bugs, edge cases, acoplamiento)
## Propuesta de Tests (min 4 casos de prueba con entrada/esperada)

Max 400 palabras total.

## Archivos de entrada
- lab/fixture/P3-pipeline/*.py (6 archivos)

## Archivo de salida
- lab/conversaciones/P3-<RAMA>-rep<N>/informe-pipeline.md

## Criterio de éxito
1. Informe existe con los 6 encabezados exactos
2. ≤400 palabras
3. Flujo de datos describe los 4 pasos en orden correcto
4. Lista al menos 8 funciones reales del fixture
5. Riesgos mencionan al menos 2 bugs reales (ej: load.py importa csv sin importarlo)

## Scoring
- 1 punto por encabezado válido (6 max)
- 2 puntos por flujo correcto
- 2 puntos por funciones correctas (8+)
- 2 puntos por riesgos reales (2+)
- 1 punto por tests válidos (4+)
- Total: 13 puntos max

## Tokens estimados
- Trabajo real: ~3k-5k tokens (1 informe largo)
- Umbral: justifica sesión si se usa subagente, pero el orquestador podría hacerlo directo
