# Enjambre — Paquete para otro equipo

> Sistema de agentes especializados para opencode.
> Ahorro medido: -25% tokens, -41% tiempo vs no usar Enjambre.

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

opencode run --agent enjambre-orquestador "tu tarea aqui"

El orquestador clasifica y despacha automaticamente.

### Benchmark

.\lab\medir-proyecto.ps1 -Proyecto P1 -Rama C   (baseline)
.\lab\medir-proyecto.ps1 -Proyecto P1 -Rama v4  (con Enjambre)

## Agentes incluidos

| Agente | Rol | Modelo |
|--------|-----|--------|
| enjambre-orquestador | Clasifica + decide + ejecuta | muse-spark-1.2 |
| enjambre-writer-batch | Batch de docs (1 sesion, N archivos) | deepseek-v4-flash |
| enjambre-code-reviewer | Code review profundo | muse-spark-1.2 |
| enjambre-exp-worker | Worker de benchmark | muse-spark-1.2 |

## Resultados medidos

| Metrica | Sin Enjambre | Con Enjambre | Ahorro |
|---------|-------------|-------------|--------|
| Tiempo total (6 proyectos) | 464.8s | 273.1s | -41.2% |
| Tokens totales | 493,340 | 368,994 | -25.2% |

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
