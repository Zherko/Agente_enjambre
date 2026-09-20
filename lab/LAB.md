# LAB — Laboratorio Enjambre

> Cargado por `opencode.json` via `instructions`. Complementa `Agent.md`.

## Qué es el lab

Entorno determinista para medir Enjambre vs basal:
- `fixture/` congelado (P1-P5) con hashes SHA256.
- Skills: `enjambre-benchmark` (A/B/C) + harness `medir-proyecto.ps1` (P1-P6 vs v4).
- 3 niveles de log: `RUNLOG.md` por repetición → `RESULTADOS.md` → `HALLAZGOS.md`.

## Uso rápido

```powershell
# Benchmark A/B/C (4 informes pagos)
.\lab\correr-rep.ps1 -Rama A -Rep 1  # paralelo
.\lab\correr-rep.ps1 -Rama B -Rep 1  # secuencial
.\lab\correr-rep.ps1 -Rama C -Rep 1  # basal sin Enjambre
# Requiere 9 reps: A1,B1,C1,A2,B2,C2,A3,B3,C3

# Benchmark 6 proyectos (v4 vs basal)
.\lab\medir-proyecto.ps1 -Proyecto P1 -Rama C
.\lab\medir-proyecto.ps1 -Proyecto P1 -Rama v4
```

## Requisitos

- `opencode >=1.18.30` en PATH (`opencode --version`).
- `opencode` resuelto vía `Get-Command`; no rutas harcodeadas.
- `ExecutionPolicy Bypass` para scripts (`powershell -ExecutionPolicy Bypass -File ...`).
- Modelo `opencode-go/muse-spark-1.2-contributor` configurado.

## Estructura esperada

- `lab/conversaciones/RUNLOG-template.md` — plantilla.
- `lab/conversaciones/RESULTADOS.md` — ledger comparativo.
- `lab/HALLAZGOS.md` — hallazgos con evidencia.

Ver `Agent.md` para reglas y `.opencode/skills/enjambre-benchmark/SKILL.md` para runbook.
