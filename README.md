# Enjambre — Paquete para otro equipo

> Sistema de agentes especializados para opencode.
> Ahorro medido vs basal: **-15.5% tokens / -13.0% coste / -4.7% tiempo** (router v1.1, 6 proyectos P1-P6) — pico **-48% tokens en P6** y **-41.2% tiempo / -25.2% tokens** en benchmark ideal.

## Que es esto

Un sistema de resolucion con agentes que clasifica tareas y elige la
estrategia correcta automaticamente. No es un plugin, es una configuracion
de agentes + reglas + benchmark.

## Requisitos

- opencode >= 1.18.29
- Un modelo configurado (muse-spark-1.2 o similar)

## Instalacion

1. Copiar esta carpeta a tu proyecto
2. Añadir opencode.json a la raiz (o fusionar con el existente)
3. Los agentes estan en .opencode/agents/ (se cargan automaticamente)
4. La skill esta en .opencode/skills/enjambre-benchmark/

## Uso

### Como orquestador (recomendado)

opencode --agent Enjambre "tu tarea aqui"

El orquestador clasifica y despacha automaticamente (`DIRECTO` vs `ENJAMBRE` via router v1.1).

### Benchmark

.\lab\medir-proyecto.ps1 -Proyecto P1 -Rama C   (baseline)
.\lab\medir-proyecto.ps1 -Proyecto P1 -Rama v4  (con Enjambre)

## Agentes incluidos

| Agente | Rol | Modelo | Seleccionable |
|--------|-----|--------|---------------|
| **Enjambre** | Orquestador — clasifica + decide + ejecuta | muse-spark-1.2 | Sí (`--agent Enjambre`) |
| enjambre-writer-batch | Batch de docs (1 sesion, N archivos) | deepseek-v4-flash | No (subagente) |
| enjambre-code-reviewer | Code review profundo | muse-spark-1.2 | No (subagente) |
| enjambre-exp-worker | Worker de benchmark | muse-spark-1.2 | No (subagente) |

## Resultados medidos

> Fuente: `lab/TABLA-EVOLUCION.md` (router v1.1, 6 proyectos P1-P6, 1 rep/proy, `--pure`) y `lab/BENCHMARK-FINAL.md` (ideal)

| Metrica | Sin Enjambre (C) | Con Enjambre | Ahorro |
|---------|-----------------|--------------|--------|
| **Tiempo total (6 proy, v1.1)** | 454.5s | 433.0s | **-4.7%** (-21.5s) |
| **Tokens totales (6 proy, v1.1)** | 1,096,190 | 926,268 | **-15.5%** |
| **Coste total (6 proy, v1.1)** | $0.133 | $0.116 | **-13.0%** |
| Tiempo total (ideal 6 proy) | 464.8s | 273.1s | -41.2% |
| Tokens totales (ideal) | 493,340 | 368,994 | -25.2% |
| **P6 1461 lin (pico)** | 335,054 tok / 94.7s | 173,501 tok / 103.5s | **-48.2% tok** |

## Limites conocidos

- System prompt opencode (~62k/sesion) es inamovible
- Techo: ~25-30% tokens, ~40% tiempo
- Writer batch es la clave para multiples archivos

## Documentacion

- lab/BENCHMARK-FINAL.md — resultados finales
- lab/RESULTADOS-EXECUTIVE.md — resumen completo
- lab/INVESTIGACIONES-RESULTADOS.md — investigaciones
- lab/HALLAZGOS.md — hallazgos con evidencia
- Agent.md — reglas del sistema
