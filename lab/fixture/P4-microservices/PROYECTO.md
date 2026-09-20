# Proyecto P4-REVIEW-MICROSERVICIOS
# Tipo: REQUIERE SESIÓN (Regla 0 nivel 3)
# Fixture: P4-microservices/ (8 archivos, ~240 lineas total)
# Objetivo: medir si Enjambre paralelo gana vs basal en code review

## Prompt verbatim

Revisa la arquitectura de microservicios en lab/fixture/P4-microservices/ (auth.py, users.py, orders.py, inventory.py, gateway.py, config.py, events.py, utils.py). Redacta un informe de code review en lab/conversaciones/P4-<RAMA>-rep<N>/informe-review.md:

# Review: Microservicios
## Resumen General (max 80 palabras)
## Por Servicio (auth, users, orders, inventory: resumen de 2-3 líneas de cada uno)
## Problemas Encontrados (min 5, formato: [SERVICIO] descripción del problema)
## Acoplamiento (qué servicios dependen de cuáles, lista)
## Recomendaciones (min 4 acciones concretas)

Max 500 palabras.

## Archivos de entrada
- lab/fixture/P4-microservices/*.py (8 archivos)

## Archivo de salida
- lab/conversaciones/P4-<RAMA>-rep<N>/informe-review.md

## Criterio de éxito
1. Informe existe con 5 encabezados exactos
2. ≤500 palabras
3. "Por Servicio" cubre los 4 servicios principales (auth, users, orders, inventory)
4. "Problemas" lista ≥5 problemas reales verificables en el código
5. "Acompalmiento" describe al menos 3 dependencias reales (ej: gateway importa auth, users, orders, inventory)

## Scoring
- 1 punto por encabezado (5 max)
- 2 puntos por cobertura de servicios (4/4)
- 3 puntos por problemas reales (5+)
- 2 puntos por acoplamiento correcto (3+)
- 1 punto por recomendaciones (4+)
- Total: 13 puntos max

## Tokens estimados
- Trabajo real: ~4k-6k tokens
- Justifica sesión con subagente (nivel 3)
