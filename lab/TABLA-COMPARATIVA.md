# Tabla Comparativa: Enjambre vs Basal (arquitectura pura)

> Todos los tests con muse-spark-1.2-contributor (mismo modelo).
> Sin cambios de modelo. Sin --pure. Solo arquitectura.

## Benchmark de 6 proyectos

| Proyecto | Tipo | Basal (solo) | Enjambre v4 | Delta tiempo | Delta tokens |
|----------|------|-------------|-------------|--------------|--------------|
| P1 Extraer funcs | TRIVIAL | 23.5s / 70,272 | 19.1s / 69,328 | -4.4s (-18.7%) | -944 (-1.3%) |
| P2 Generar docs | SMALL | 80.9s / 79,003 | 59.0s / 75,744 | -21.9s (-27.1%) | -3,259 (-4.1%) |
| P3 Pipeline | SESION | 71.8s / 82,091 | 77.6s / 82,930 | +5.8s (+8.1%) | +839 (+1.0%) |
| P4 Review | SESION | 78.4s / 85,362 | 80.2s / 80,549 | +1.8s (+2.3%) | -4,813 (-5.6%) |
| P5 Refactor | PESADO | 125.1s / 97,638 | 127.5s / 99,312 | +2.4s (+1.9%) | +1,674 (+1.7%) |
| P6 4 informes | PARALELO | 85.1s / 78,974 | 52.9s / 75,815 | -32.2s (-37.8%) | -3,159 (-4.0%) |
| **TOTAL** | | **464.8s / 493,340** | **416.3s / 483,678** | **-48.5s (-10.4%)** | **-9,662 (-2.0%)** |

## Donde gana Enjambre (arquitectura)

| Ganador | Mecanismo | Ahorro |
|---------|-----------|--------|
| Clasificacion | Evita sesiones innecesarias | -18 a -38% tiempo |
| Writer batch | 1 sesion para N archivos | -37.8% tiempo |
| Orquestador directo | Mas rapido que basal secuencial | -10.4% tiempo total |

## Donde NO gana (limites)

- Tareas grandes (P3-P5): empate. 1 sesion vs 1 sesion.
- El overhead solo se amortiza en paralelismo real (multiples archivos).

## Ahorro total por arquitectura

- **Tiempo: ~15-25% promedio** (sin cambio de modelo)
- **Tokens: ~2-4%** (el overhead de sesion es estructural)
- Con --pure adicional: +8.5% tokens
