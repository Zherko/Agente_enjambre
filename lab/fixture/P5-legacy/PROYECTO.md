# Proyecto P5-PLAN-REFACTOR
# Tipo: REQUIERE SESIÓN (Regla 0 nivel 3, complejo pesado)
# Fixture: P5-legacy/ (10 archivos, ~280 lineas total)
# Objetivo: medir si Enjambre paralelo es sustancialmente mejor en tareas grandes

## Prompt verbatim

Analiza el monolito legacy en lab/fixture/P5-legacy/ (10 archivos: models.py, views.py, services.py, db.py, auth.py, utils.py, config.py, notifications.py, reporting.py, main.py). Diseña un plan de refactoring para extraer cada servicio a un módulo independiente. Redacta el plan en lab/conversaciones/P5-<RAMA>-rep<N>/informe-refactor.md:

# Plan de Refactoring: Legacy Monolith
## Resumen (max 80 palabras)
## Servicios Actuales (lista los 6+ dominios identificados en el código, con 2-3 funciones clave de cada uno)
## Extracción Propuesta (para cada servicio: qué archivos crear, qué funciones mover, qué dependencias romper)
## Orden de Extracción (secuencia recomendada con justificación: qué servicio se extrae primero y por qué)
## Riesgos (min 5: qué puede romperse, edge cases, datos compartidos)
## Criterios de Éxito (min 4: cómo saber que el refactoring funcionó)

Max 700 palabras.

## Archivos de entrada
- lab/fixture/P5-legacy/*.py (10 archivos)

## Archivo de salida
- lab/conversaciones/P5-<RAMA>-rep<N>/informe-refactor.md

## Criterio de éxito
1. Informe existe con 6 encabezados exactos
2. ≤700 palabras
3. "Servicios Actuales" identifica ≥6 dominios (users, orders, products, auth, payments, notifications, reporting)
4. "Extracción Propuesta" cubre al menos 4 servicios con archivos concretos a crear
5. "Orden" tiene lógica clara (ej: extraer auth antes de orders porque orders depende de auth)
6. "Riesgos" incluye al menos 2 problemas reales del código (ej: models.py tiene toda la lógica de negocio, config.py tiene secret hardcoded)

## Scoring
- 1 punto por encabezado (6 max)
- 3 puntos por servicios identificados (6+)
- 3 puntos por extracción concreta (4+ servicios)
- 2 puntos por orden lógico
- 3 puntos por riesgos reales (2+)
- 1 punto por criterios de éxito (4+)
- Total: 16 puntos max

## Tokens estimados
- Trabajo real: ~5k-8k tokens
- Tarea más pesada del benchmark
