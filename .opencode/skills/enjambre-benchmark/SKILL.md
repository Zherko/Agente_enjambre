---
name: enjambre-benchmark
description: Benchmark A/B/C determinista de Enjambre. Ejecuta un task-set fijo sobre fixture congelado en rama A (workers en paralelo), B (mismos workers en secuencia) y C (un agente normal sin Enjambre) y registra tiempo pared + tokens con RUNLOG por repeticion. Usar para medir si el multiagente paralelo compensa y si Enjambre aporta frente al uso normal.
---

# Skill enjambre-benchmark — ejecución blindada del experimento

## 0. Blindaje (no negociable, invalida la repetición si se incumple)

1. **Fixture congelado** `lab/fixture/P1-pagos/` (SHA256 de referencia):
   - `pagos.py` `6C88743EA566D95DB5CD5632A3ADD3682DEB7FA8E9A7874C4F7D30960D9552CB`
   - `usuarios.py` `4B88F4FA64680455573E0EF866302D7F3ED05123AFBCD3340B8878BA64C76F56`
   - `inventario.py` `089C6FB4EE30BC41D4941CF5BB8744DA84E99FBD57FE9B0D76`
   - `notificaciones.py` `5B69B0858EFA6BA03B523FDE2DB45020826B1928A0EA1FBE19C5B68C3F170A8C`
   - Antes de cada repetición: `Get-FileHash lab/fixture/P1-pagos/*.py` debe coincidir. Si no → abortar y registrar causa.
2. **Modelo fijo:** `opencode-go/muse-spark-1.2-contributor` en ejecutor, workers y rama C.
3. **Workers fijos (A/B):** `enjambre-exp-worker` (`temperature: 0`, solo read+write, un módulo → un informe).
4. **Prompts verbatim:** los briefs de §2/§3b se copian literalmente; prohibido parafrasear entre repeticiones o ramas.
5. **Sesión fresca por repetición** (prohibido `--continue` — bug de wrapper documentado en `lab/USO-GLOBAL.md`).
6. **Salidas separadas por rama/repetición:** `lab/conversaciones/exp-<RAMA>-rep<N>/informe-<modulo>.md` + `RUNLOG.md` (plantilla: `lab/conversaciones/RUNLOG-template.md`). Nunca mezclar. Repetición sin RUNLOG completo no existe.
7. **Misma máquina, sin carga pesada concurrente.** Orden: A1,B1,C1,A2,B2,C2,A3,B3,C3.
8. **3 repeticiones por rama (9 en total).** Menos no decide.

## 1. Task-set fijo (4 informes, esquema fijo)

`BASE = C:\Proyectos\Skills\Enjambre`, `FIX = BASE\lab\fixture\P1-pagos`, `OUT = BASE\lab\conversaciones\exp-<RAMA>-rep<N>`.

Encabezados exactos por informe: `# Informe: <modulo>`, `## Resumen` (≤40 palabras), `## Funciones`, `## Dependencias`, `## Riesgos`. Total ≤150 palabras/informe.

- **T1:** `FIX\pagos.py` → `OUT\informe-pagos.md`
- **T2:** `FIX\usuarios.py` → `OUT\informe-usuarios.md`
- **T3:** `FIX\inventario.py` → `OUT\informe-inventario.md`
- **T4:** `FIX\notificaciones.py` → `OUT\informe-notificaciones.md`

## 2. Runbook rama A (paralelo, con Enjambre)

1. Crear `OUT`. Escribir `block.json` de la corrida con 4 claims `active` (uno por informe, sets disjuntos) y correr `lab/validar-block.ps1` → verde obligatorio. En rojo → abortar.
2. Lanzar T1–T4 como 4 dispatches de `enjambre-exp-worker` **en UN solo mensaje**, brief verbatim: `Lee MODULO y redacta SALIDA según tu system prompt. No hagas nada más.`
3. Medir tiempo pared con `Measure-Command` envolviendo el paso 2. Anotar tokens (input+output, overhead incluido).
4. Cerrar RUNLOG (veredicto_rep, esquema_ok y palabras por informe). Claims a `done`.

## 3. Runbook rama B (secuencial, con Enjambre)

Idéntico salvo paso 2: T1, esperar `done`, luego T2, T3, T4 (secuencial, mismos briefs). Mismas mediciones y RUNLOG.

## 3b. Runbook rama C (basal, SIN Enjambre)

Representa el uso normal sin Enjambre: un solo agente primario (build/general), sin especialistas, sin partición, sin validador, sin worktree, sin `block.json`.

1. Crear `OUT`. Sesión fresca.
2. UN solo mensaje al agente con este prompt verbatim: `Lee los 4 modulos de FIX (pagos.py, usuarios.py, inventario.py, notificaciones.py) y redacta los 4 informes en OUT (informe-pagos.md, informe-usuarios.md, informe-inventario.md, informe-notificaciones.md) con exactamente los encabezados: '# Informe: <modulo>', '## Resumen' (max 40 palabras), '## Funciones', '## Dependencias', '## Riesgos'. Max 150 palabras por informe. No hagas nada mas.`
3. Medir tiempo pared (`Measure-Command`) y tokens igual que A/B. Cerrar RUNLOG (validador: N/A).

## 4. Registro y decisión

1. Por repetición: `RUNLOG.md` completo en su carpeta.
2. Una fila por repetición en `lab/conversaciones/RESULTADOS.md`:
   `| fecha | rama | rep | tiempo_s | tokens_in | tokens_out | informes_ok | esquema_ok | palabras_tot | hash_ok | runlog_ok | notas |`
3. Observación reutilizable (fallo de método, sorpresa de nºs, idea) → entrada en `lab/HALLAZGOS.md` con evidencia y acción. Lo que no está en HALLAZGOS no se aprendió.
4. Decisión con medianas de 3 reps:
   - `speedup_AB = mediana(B)/mediana(A)` (¿compensa paralelizar?)
   - `speedup_CB = mediana(B)/mediana(C)`, `speedup_CA = mediana(A)/mediana(C)` (¿aporta Enjambre frente a uso normal?)
   - `coste = tokens_rama / tokens_C`.
   - Gana una rama si speedup > 1 en 3/3 comparaciones pareadas con esquema 4/4.
5. Regla operativa (Agent.md Regla 4): si `overhead > ganancia` → secuencial por defecto.
6. Validez acotada: N=4, ~25 líneas/módulo, informe ≤150 palabras. Generalizar exige nuevo task-set.

## 6. Harness de ejecución (lab/correr-rep.ps1)

El ejecutor NO lanza a mano: usa `.\correr-rep.ps1 -Rama <A|B|C> -Rep <N>`.
El script: verifica hashes, escribe `block.json` + gate (A/B), lanza
(A: 4 Start-Job paralelos con `@enjambre-exp-worker` + brief verbatim;
B: 4 secuenciales; C: 1 mensaje basal), cronometra, guarda `raw-<t>.jsonl`
(`--format json`), suma tokens de eventos `step_finish` (fuente oficial de
tokens_in/out), verifica esquema/palabras y escribe `RUNLOG.md` + fila lista
para RESULTADOS. La fila impresa por el script se copia tal cual al ledger.

## 5. Fallos que invalidan una repetición

Worker lee/escribe fuera de MODULO/SALIDA · informe sin los 4 encabezados · fixture con hash distinto · `--continue` usado · prompts alterados · carga concurrente pesada · en C: usar especialistas, partición o validador (deja de ser basal). Se repite la repetición, no se promedia el fallo.
