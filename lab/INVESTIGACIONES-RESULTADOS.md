# Resultados de Microinvestigaciones — Enjambre (Final)

> Fecha: 2026-09-20 | 6 investigaciones ejecutadas

## Resumen ejecutivo

| Inv | Hipotesis | Resultado | Ahorro | Veredicto |
|-----|-----------|-----------|--------|-----------|
| 1A | Worker prompt minimo | FALSO: +10% tokens | -10% | CERRADO |
| 3A | Agent.md comprimido | FALSO: +9% tok, +96% t | -9% | CERRADO |
| 4A | Batch vs 4 workers | CONFIRMADO: -71% | -71% | v4 ya hace |
| 3C | --pure sin plugins | CONFIRMADO: -8.5% | -5.8k/ses | IMPLEMENTADO |
| 1 | Modelos por complejidad | CONFIRMADO: deepseek -38% t | -38% tiempo | Para workers |
| 5 | Agentes selectivos | CONFIRMADO: writer batch -77% | -77% tokens | Para batch |
| 6 | Contexto entre agentes | REDUNDANCIA MINIMA (0.3%) | -191 tok | No prioridad |

---

## NI-1: Perfiles de modelo

| Modelo | Tiempo | Tokens | Palabras | vs muse |
|--------|--------|--------|----------|---------|
| muse-spark-1.2 (paid) | 32.5s | 67,357 | 444 | base |
| deepseek-v4-flash | 20.1s | 69,838 | 351 | -38% tiempo |
| mimo-v2.5 | 61.5s | 75,739 | 368 | +89% tiempo |
| muse-spark-1.2-free | 29.5s | 68,862 | 416 | -9% tiempo |

Conclusion: deepseek-v4-flash es 38% mas rapido para lectura+escritura.
Usar para workers de batch, NO para orquestador (necesita razonamiento).

## NI-5: Agentes especializados

| Enfoque | Tokens P2 | Tiempo P2 | Tokens P4 | Tiempo P4 |
|---------|-----------|-----------|-----------|-----------|
| Generico (4 workers) | 327,175 | 85.1s | - | - |
| Writer batch (1 sesion) | 71,827 | 73.1s | - | - |
| Orquestador directo | - | - | 4,376 | 34.7s |
| Reviewer especializado | - | - | 68,793 | 53.3s |

Conclusion: el writer batch ahorra 77% vs 4 workers separados.
El orquestador directo es mejor que reviewer especializado para P4.
Los agentes selectivos ayudan solo en BATCH de archivos.

## NI-6: Contexto entre agentes

- System prompt worker: ~62,700 tokens (fijo)
- Dispatch message: ~191 tokens (0.3% del total)
- Redundancia: MINIMA, no prioridad

El problema real es el system prompt (~62k), no el dispatch.

---

## VEREDICTO FINAL: Que funciona y que no

### SI funciona (implementable ahora):

1. **--pure en todas las corridas**: -5,808 tokens/sesion (-8.5%)
2. **v4 clasificador 3 niveles**: evitar sesiones innecesarias
3. **Writer batch para multiples archivos**: 1 sesion en vez de N
4. **deepseek-v4-flash para workers de batch**: -38% tiempo

### NO funciona (cerrado):

1. Comprimir prompts de workers (pierde eficiencia)
2. Comprimir Agent.md (degrada calidad)
3. Routing de modelo para reducir tokens (mismo overhead)
4. Contexto entre agentes (redundancia minima)

### Estructura optima descubierta:

```
Orquestador (muse-spark-1.2, --pure):
  - Clasifica: TRIVIAL/SMALL/LARGE
  - TRIVIAL/SMALL: responde directo (1 sesion, ~62k tokens)
  - LARGE: dispatch a worker especializado batch

Worker batch (deepseek-v4-flash, --pure):
  - 1 worker por tipo de tarea (reader/writer/reviewer)
  - Multiples archivos en 1 sesion (no N sesiones)
  - Solo si trabajo real > 10k tokens
```

### Ahorro total proyectado vs v1 original:

| Componente | Ahorro |
|------------|--------|
| Clasificador 3 niveles | -50 a -73% en triviales |
| --pure | -8.5% por sesion |
| Writer batch | -77% vs workers separados |
| deepseek para workers | -38% tiempo |
| **Combinado** | **~40-60% tokens, ~30-40% tiempo** |
