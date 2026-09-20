# Proyecto P2-GENERAR-DOCS
# Tipo: SMALL COMPLEX (Regla 0 nivel 2)
# Fixture: P2-api/ (5 archivos, ~130 lineas total)
# Objetivo: medir si el orquestador responde directo o lanza subagentes

## Prompt verbatim

Analiza los 5 archivos de lab/fixture/P2-api/ (routes.py, schemas.py, middleware.py, utils.py, main.py). Para cada archivo, escribe un informe en lab/conversaciones/P2-<RAMA>-rep<N>/ con el nombre informe-<nombre>.py.md. Cada informe tiene estos encabezados exactos:

# Informe: <nombre>.py
## Resumen (max 60 palabras)
## Funciones (lista: nombre - que hace)
## Dependencias (imports de otros módulos del proyecto)
## Riesgos (max 3 bullet points)

Max 120 palabras por informe. Son 5 informes.

## Archivos de entrada
- lab/fixture/P2-api/*.py (5 archivos)

## Archivos de salida
- lab/conversaciones/P2-<RAMA>-rep<N>/informe-routes.py.md
- lab/conversaciones/P2-<RAMA>-rep<N>/informe-schemas.py.md
- lab/conversaciones/P2-<RAMA>-rep<N>/informe-middleware.py.md
- lab/conversaciones/P2-<RAMA>-rep<N>/informe-utils.py.md
- lab/conversaciones/P2-<RAMA>-rep<N>/informe-main.py.md

## Criterio de éxito
1. 5 informes existen
2. Cada uno tiene los 4 encabezados exactos
3. Cada uno tiene ≤120 palabras
4. Funciones listadas coinciden con las reales del fixture
5. Dependencias correctas (ej: routes.py importa de usuarios y pagos)

## Scoring
- 2 puntos por informe válido (encabezados + palabras + funciones) = 10 puntos max
- 1 punto extra si todas las dependencias son correctas = 11 puntos max

## Tokens estimados
- Trabajo real: ~2k-3k tokens (5 informes × ~500 tokens c/u)
- Debe resolverse en 1 sesión (clasificador nivel 2)
