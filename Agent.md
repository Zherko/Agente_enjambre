# Agent.md — Carta del proyecto Enjambre

> Cargado automaticamente por `opencode.json` -> `instructions`.
> Norma operativa, no decorativa. Aprobado por comite + investigaciones.

## Que es Enjambre

Sistema de resolucion con agentes especializados sobre opencode, con una regla
de oro: **la velocidad no viene de lanzar mas agentes, sino de lanzar menos,
aislados y solo cuando el grafo de dependencias lo permite.**

## Regla 0 — Clasificador de 3 niveles (maxima prioridad)

Antes de CUALQUIER accion, el orquestador clasifica la tarea:

**TRIVIAL -> respuesta directa, SIN subagentes (<=500 tokens):**
- Leer un archivo y reportar contenido
- Pregunta factual sobre el proyecto
- Listar archivos o buscar patrones
- Ediciones simples (cambiar un string, renombrar una variable)
- Generar informe corto de un solo archivo
- Respuestas si/no
- Resumir lo que se hablo
- Cualquier tarea que el orquestador resuelva en <30s de razonamiento

**SMALL COMPLEX -> respuesta directa, SIN subagentes (<=5k tokens de trabajo real):**
- Multiples outputs pequenos (4-5 informes de 90 palabras)
- Ediciones simples en 3-5 archivos
- Analisis de 3-4 modulos con resumen
- Salida estructurada desde multiples inputs
- **Umbral:** si el trabajo real cabe en <10k tokens -> hacerlo directamente

**REQUIERE SESION -> pasar a Regla 1:**
- Documento/spec completo desde cero
- Cambios en multiples archivos con logica compleja
- Code review con findings
- Analisis que requiere explorar el codebase
- Cualquier tarea que necesite contexto aislado (worktree)
- Multiples archivos grandes (>200 lineas c/u)

**Por que?** Cada subagente paga ~62k tokens de contexto base (con --pure).
En tareas pequenas, el overhead supera el trabajo real en 136:1.

## Regla 1 — Desfragmentar solo lo desfragmentable

Despues de pasar el clasificador (Regla 0), solo se autoriza multiagente
en paralelo si se cumplen TODAS:

1. La tarea se parte en subtareas con **interfaces estables** entre ellas.
2. Cada subtarea toca un **conjunto de archivos disjunto** (verificado con
   `lab/validar-block.ps1` ANTES de lanzar; si hay solape -> secuencial).
3. Las subtareas son **I/O-bound independientes** (explorar, leer, buscar,
   redactar informes). Lo CPU-bound del modelo NO paraleliza.

Si hay dependencias o solape -> ejecucion secuencial. Sin excepciones.

## Regla 2 — Agentes especializados selectivos

**No todos los agentes se invocan siempre.** Solo el adecuado para la tarea:

| Agente | Modelo | Quando usar | Cuantas sesiones |
|--------|--------|-------------|------------------|
| orquestador | muse-spark-1.2 | SIEMPRE (clasifica + decide) | 1 |
| writer | deepseek-v4-flash | Batch de archivos (>3 archivos) | 1 por batch |
| reader | deepseek-v4-flash | Solo lectura, sin escritura | 1 por consulta |
| reviewer | muse-spark-1.2 | Code review profundo (>8 archivos) | 1 por review |
| exp-worker | muse-spark-1.2 | Experimento benchmark | 1 por tarea |

**Clave:** un writer batch hace en 1 sesion lo que N workers hacen en N sesiones.
Ejemplo: 5 informes = 1 sesion writer (71k tokens) vs 5 sesiones workers (327k tokens).

## Regla 3 — Contexto entre agentes

- El orquestador dispatcha con **mensaje minimo**: "lee X, escribe Y".
- El worker ya tiene su instruccion en el system prompt.
- **No inyectar contexto redundante** en el dispatch (medido: 0.3% overhead).
- Cada agente es **self-contained**: lee archivos, produce output, termina.
- Sin comparticion de contexto entre sesiones hermanas (opencode no lo soporta).

## Regla 4 — block.json (ledger, no lock)

```json
{
  "run": "<slug>",
  "workspaceRoot": "<ruta absoluta worktree>",
  "claims": [
    {"agent": "enjambre-implementer", "subtask": "tarea-3", "files": ["src/pagos/**"], "status": "active"}
  ]
}
```

- Lo escribe el orquestador. Los subagentes lo leen, no lo negocian.
- `status`: `active` | `done`. Solo informativo.
- Prohibido implementar claim-via-escritura.

## Regla 5 — Medir antes de generalizar (3 ramas + sistema de logs)

Toda afirmacion de ventaja se demuestra con la skill
`enjambre-benchmark` (protocolo en `.opencode/skills/enjambre-benchmark/`):

- **Rama A** (paralelo con Enjambre) vs **rama B** (secuencial con Enjambre)
  vs **rama C** (basal: un agente normal SIN Enjambre).
- 3 repeticiones por rama (9 total), orden A1,B1,C1,A2,B2,C2,A3,B3,C3,
  sesiones frescas, modelo y prompts fijos.
- **Sistema de logs (3 niveles, todos obligatorios):**
  1. `lab/conversaciones/exp-<RAMA>-rep<N>/RUNLOG.md` — log por repetición.
  2. `lab/conversaciones/RESULTADOS.md` — ledger comparativo.
  3. `lab/HALLAZGOS.md` — hallazgos con evidencia y accion.
- Metrica canonica: **tokens_por_resultado_util** (no tokens totales).
- Umbral vigente: si `overhead_orquestacion > ganancia_max_fragmentos`,
  forzar secuencial.

## Regla 6 — Flags obligatorios

- **`--pure`** en TODAS las llamadas a opencode run (elimina plugins, -8.5% tokens).
- **`--format json`** para metricas de tokens (step_finish.tokens).
- **Sesion fresca** por cada corrida (prohibido `--continue`).

## Regla 7 — Tabla de evolución estandarizada (blinda la salida)

Toda comparativa basal vs Enjambre **debe** cerrar con esta tabla (1 fila por versión, 3 versiones fijas). Fuente: `lab/conversaciones/*/RUNLOG.md` (`tokens_in/out`, `coste`, `tiempo_s`). Sin tabla no hay conclusión.

| Versión | Coste total ($) | Gasto tokens (in+out) | Gasto tiempo (s) | vs Basal |
|---|---|---|---|---|
| **Basal sin Enjambre (C)** | `sum step_finish.cost` | `in+out` | `tiempo_s` | — |
| **Penúltima Enjambre (A paralelo 4 workers)** | `sum` | `in+out` | `tiempo_s` | `% vs C` |
| **Última Enjambre (v4 / router v1.1)** | `sum` | `in+out` | `tiempo_s` | `% vs C` |

- `Coste total` = suma `part.cost` de `raw-*.jsonl` (`step_finish`). Si no hay `cost`, usar `tokens_in*precio_in + tokens_out*precio_out`.
- `Gasto tokens` y `tiempo` del `RUNLOG.md` (mediana de 3 reps cuando haya 9; si 1 rep, usar esa).
- Generador: `lab/tabla-evolucion.ps1` (lee `RUNLOG.md` + `router-decisiones.json`, escribe `lab/TABLA-EVOLUCION.md`).
- La tabla se versiona en `lab/TABLA-EVOLUCION.md` y `lab/HALLAZGOS.md` cada vez que se cambie `router-config.json`.

## Ahorros validados (investigaciones NI-1 a NI-6)

| Componente | Ahorro | Tipo |
|------------|--------|------|
| Clasificador 3 niveles | -50 a -73% en triviales | Arquitectura |
| --pure (sin plugins) | -8.5% por sesion | Config |
| Writer batch (1 sesion, N archivos) | -77% vs N workers | Arquitectura |
| Orquestador directo (SMALL) | -10.4% tiempo vs basal | Arquitectura |

**No se usan atajos de modelo** para ahorrar tiempo. Todos los ahorros
provienen de arquitectura: menos sesiones, mejor clasificacion, batch.

## Estructura del proyecto

```
Enjambre/
  Agent.md                    <- este archivo (carta)
  opencode.json               <- modelo lab + instructions (carga Agent.md)
  .opencode/agents/           <- 6 agentes (orquestador + writer + reader + reviewer + 2 experimento)
  .opencode/skills/
    mi-primera-skill/         <- plantilla de prueba del lab
    enjambre-benchmark/       <- skill del experimento A/B/C
  block.json / block.schema.json <- ledger de corrida + esquema
  lab/
    LAB.md / USO-GLOBAL.md / EXPERIMENTO.md
    conversar.ps1 / validar-block.ps1 / correr-rep.ps1 / medir-proyecto.ps1
    fixture/                  <- 5 proyectos congelados (P1-P5)
    INVESTIGACIONES.md        <- plan de microinvestigaciones
    INVESTIGACIONES-RESULTADOS.md <- resultados de investigaciones
    conversaciones/
      RUNLOG-template.md / RESULTADOS.md / HALLAZGOS.md
      P1-C/ ... P5-C/         <- resultados por proyecto rama C
      v4-P1/ ... v4-P6/       <- resultados por proyecto v4
      ni1/ ... ni6/           <- resultados de investigaciones
    HALLAZGOS.md
```
