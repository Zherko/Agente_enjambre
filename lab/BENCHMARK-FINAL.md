# Resultado Final del Proyecto Enjambre

> Benchmark final: 6 proyectos deterministas, orquestador autonomo, mismo modelo
> Fecha: 2026-09-20

## Tabla comparativa: Enjambre vs Sin Enjambre

| Metrica | Sin Enjambre | Con Enjambre | Ahorro |
|---------|-------------|-------------|--------|
| Tiempo total (6 proyectos) | 464.8s | 273.1s | -191.7s (-41.2%) |
| Tokens totales (6 proyectos) | 493,340 | 368,994 | -124,346 (-25.2%) |
| Tokens promedio/proyecto | 82,223 | 61,499 | -20,724 (-25.2%) |
| Tiempo promedio/proyecto | 77.5s | 45.5s | -32.0s (-41.2%) |

## Por tipo de tarea

| Tipo | Ahorro tiempo | Ahorro tokens | Estrategia |
|------|--------------|---------------|------------|
| TRIVIAL | -26.8% | -12.5% | Orquestador directo |
| SMALL | -28.3% | -22.1% | Writer batch (1 sesion) |
| SESION | -49.4% | -26.6% | Orquestador directo |
| PESADO | -66.1% | -37.0% | Orquestador directo |
| PARALELO | -7.2% | -22.1% | Writer batch (1 sesion) |

## Donde viene el ahorro (arquitectura pura)

1. Clasificador 3 niveles: evita sesiones innecesarias
2. Writer batch: 1 sesion para N archivos
3. --pure: elimina plugins (-8.5% por sesion)
4. Orquestador eficiente: clasifica y ejecuta sin overhead

## Limites alcanzados

- System prompt opencode (~62k): inamovible (99.8% del overhead)
- Agent.md: solo 128 tokens (0.2%) -> reducirlo no ayuda
- Agentes especializados: cada uno paga 62k de overhead
- Techo: ~25% tokens, ~41% tiempo (YA ALCANZADO)

## Archivos del proyecto

- Agent.md: carta del proyecto
- lab/RESULTADOS-EXECUTIVE.md: resumen de iteraciones
- lab/TABLA-COMPARATIVA.md: tabla vs basal
- lab/INVESTIGACIONES-RESULTADOS.md: 6 investigaciones
- lab/HALLAZGOS.md: hallazgos con evidencia
- lab/ESTRUCTURA-OPTIMA.md: estructura final
- lab/benchmark-final.md: este archivo
