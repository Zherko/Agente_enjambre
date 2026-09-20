# Enjambre — Resultados del Experimento

> Resumen ejecutivo de todas las iteraciones, hallazgos y veredictos.
> Fecha: 2026-09-19 | Modelo: opencode-go/muse-spark-1.2-contributor

## 1. Qué es Enjambre

Sistema de resolución con agentes especializados sobre opencode. El objetivo
es medir si usar multiagente paralelo (especializados) es mejor que usar un
solo agente normal, en tiempo y tokens.

## 2. Iteraciones realizadas

### v1 — Sin optimizar (9 reps A/B/C)

4 workers paralelos + orquestador. Todos con muse-spark-1.2-contributor.

| Rama | Descripción | Tiempo mediana | Tokens mediana |
|------|-------------|----------------|----------------|
| A | Paralelo (4 workers) | 67.0s | 281,450 |
| B | Secuencial (4 workers) | 202.7s | 275,704 |
| C | Basal (sin Enjambre) | 63.7s | 76,223 |

- A vs B: A ahorra 66.9% tiempo (speedup 3.03), tokens empatados (+1.7%)
- A vs C: empate tiempo, C ahorra 72.9% tokens
- Conclusión: con fragmentos pequeños (~90 palabras), el basal gana

### Piloto v2 — Fragmentos pesados (1+1 corridas)

| Rama | Tiempo | Tokens | Palabras |
|------|--------|--------|----------|
| A (4 workers-v2) | 81s | 278,558 | 1,558 |
| C (basal extendido) | 120.8s | 84,743 | 1,925 |

- A ahorra 32.9% tiempo vs C con fragmentos ~4x más grandes
- C ahorra 69.6% tokens vs A
- Hallazgo: existe umbral de tamaño donde el paralelismo compensa

### v2 — Clasificador binario

Añadido al orquestador: "¿justifica sesión separada?" → trivial responde directo.

| Test | Tiempo | Tokens | vs v1 |
|------|--------|--------|-------|
| Trivial (1 archivo) | 22.6s | 68,865 | -50.1% |
| Compleja (4 informes) | 60.1s | 277,487 | -1.4% |

- Trivial: ahorra 50% tokens (69k vs 138k)
- Compleja: sin cambio significativo

### v3 — Routing de modelo

Workers a modelo gratuito (muse-spark-1.2-free), plan/implementer a deepseek-v4-flash.

| Test | Tiempo | Tokens | vs v1 |
|------|--------|--------|-------|
| Trivial | 16.1s | 47,300 | -65.7% |
| Compleja | 52.6s | 309,852 | +10.1% (PEOR) |

- Hallazgo: modelos gratuitos tienen contexto base igual o MAYOR
- Routing NO ahorra tokens, solo cambia velocidad
- Revertido: exp-worker vuelto a muse-spark-1.2-paid

### v4 — Clasificador de 3 niveles (ORQUESTADOR DIRECTO)

Añadida categoría "SMALL COMPLEX": si trabajo real <10k tokens → directo.

| Test | Tiempo | Tokens | vs v1 | vs C basal |
|------|--------|--------|-------|------------|
| 4 informes (~90 palabras c/u) | 46.7s | 73,964 | -73.7% | -3.0% |

- **GANADOR en tareas pequeñas** (vs paralelo original)
- 73.7% menos tokens que paralelo
- 30.3% más rápido que paralelo

## 3. Hallazgos clave (H-0 a H-13)

| ID | Hallazgo | Implicación |
|----|----------|-------------|
| H-0 | Comité rechaza plan generalizado; solo orquestador restringido | Agent.md v1 reescrito |
| H-1 | Falta rama basal sin Enjambre | Añadida rama C |
| H-3 | Overhead ~69k/sesión × N workers | Duplicación estructural, no ruido |
| H-5 | A gana tiempo vs C con fragmentos pesados (-33%) | Umbral de tamaño existe |
| H-7 | Clasificador binario ahorra 50% en triviales | Acción más impactante y barata |
| H-8 | Orquestador SIEMPRE paga ~69k contexto base | Constraint de opencode |
| H-9 | Routing de modelo NO ahorra tokens | muse-spark-1.2 ya es el más barato |
| H-10 | Compresión de prompts SÍ ahorra (-31%) | Priorizar sobre routing |
| H-11 | Orquestador directo gana en tareas pequeñas | Clasificador de 3 niveles funciona |
| H-12 | Enjambre v4 es mejor que no tenerlo | Trade-off = 0 en tareas pequeñas |
| H-13 | **Estimaciones corregidas**: v4 vs basal real = -2.0% tokens, -10.4% tiempo | El 73.7% era vs paralelo, no vs basal |

## 4. Benchmark de 6 proyectos (determinista)

### Resultados reales — C basal vs v4

| Proyecto | Tipo | C basal | v4 | Delta tokens | Delta tiempo |
|----------|------|---------|-----|-------------|--------------|
| P1 Extraer funciones | TRIVIAL | 23.5s / 70,272 | 19.1s / 69,328 | -1.3% | -18.7% |
| P2 Generar docs | SMALL | 80.9s / 79,003 | 59.0s / 75,744 | -4.1% | -27.1% |
| P3 Análisis pipeline | SESIÓN | 71.8s / 82,091 | 77.6s / 82,930 | +1.0% | +8.1% |
| P4 Review microservicios | SESIÓN | 78.4s / 85,362 | 80.2s / 80,549 | -5.6% | +2.3% |
| P5 Plan refactor | PESADO | 125.1s / 97,638 | 127.5s / 99,312 | +1.7% | +1.9% |
| P6 Paralelo 4 archivos | PARALELO | 85.1s / 78,974 | 52.9s / 75,815 | -4.0% | -37.8% |
| **TOTAL** | | **464.8s / 493,340** | **416.3s / 483,678** | **-2.0%** | **-10.4%** |

### Corrección de estimaciones

| Estimación anterior (vs paralelo) | Realidad (vs basal) |
|-----------------------------------|---------------------|
| v4 ahorra 73.7% tokens | **v4 ahorra solo 2.0% tokens** |
| v4 ahorra 26.7% tiempo | **v4 ahorra 10.4% tiempo** |
| 58% ahorro si 80% triviales | **Las tareas reales no son triviales** |

### Calidad

- P1: ambos generan JSON válido (correcto)
- P2: 5/5 informes esquema OK (ambos)
- P3: 1/1 esquema OK (ambos)
- P4: 1/1 pero sin todos los encabezados (ambos)
- P5: 1/1 sin todos los encabezados (ambos)
- P6: 4/4 informes esquema OK (ambos)

## 5. Umbral operativo

```
< 10k tokens de trabajo real → orquestador directo (SIN subagentes)
> 10k tokens de trabajo real → subagentes paralelos (CON Enjambre)
```

## 6. Métrica canónica

**tokens_por_resultado_util** (no tokens totales). Incluye overhead
amortizado de toda la cadena de decisión.

## 7. Veredicto consolidado

### Dónde gana Enjambre (realmente)

| Escenario | Enjambre gana | No gana |
|-----------|---------------|---------|
| Tareas triviales | Tokens + velocidad vs paralelo original | Empate vs basal |
| Tareas pequeñas | Velocidad (-10 a -37%) | Tokens (~igual vs basal) |
| Tareas grandes con fragmentos pesados | Velocidad (-33%) | Tokens (+3.7x vs basal) |

### La foto honesta

- **vs paralelo original (v1)**: v4 gasta 73.7% menos tokens — gran mejora
- **vs basal (sin Enjambre)**: v4 gasta solo 2.0% menos tokens — mejora marginal
- **La ventaja real de Enjambre es VELOCIDAD**, no ahorro de tokens vs basal
- **C basal ya es bastante óptimo** para tareas de 1 sesión

## 8. Estado actual

- Harness: lab/correr-rep.ps1, lab/validar-block.ps1, lab/medir-proyecto.ps1
- Skill: enjambre-benchmark (6 proyectos deterministas)
- Agentes: orquestador v4 + 5 especializados
- Agent.md: Regla 0 (3 niveles) + Reglas 1-4
- Benchmark: 6 proyectos con PROYECTO.md, MANIFEST.md, fixtures
- Ledger: lab/conversaciones/RESULTADOS.md, lab/HALLAZGOS.md

## 9. Investigaciones pendientes

Ver `lab/INVESTIGACIONES.md` para el plan de microinvestigaciones.
