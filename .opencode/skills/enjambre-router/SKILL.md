---
name: enjambre-router
description: Router híbrido probabilístico para decidir DIRECTO vs ENJAMBRE. Evita sobreajuste a 10k fijo. Fast-reject triviales + scoring 4D + umbral dinámico por overhead + veto juez en valle medio. Veredicto comité 2026-09-20.
---

# enjambre-router — skill de decisión

## Objetivo
Decidir `DIRECTO | ENJAMBRE_SELECTIVO | ENJAMBRE` sin determinismo 10k. 10k es solo heurística bayesiana, no regla.

## Inputs (meta de tarea)
- `archivos`: lista de paths (o count)
- `lineas`: total líneas diff / líneas a tocar
- `coupling`: 0-10 (interdependencia, si no se calcula → heurística por imports compartidos)
- `paralelizable`: 0-10 (disyunción, 10 = files disjuntos)
- `riesgo`: bajo|medio|alto (pagos/seguridad = alto)
- `tokens_estimados`: opcional (para volumen normalizado)

## Algoritmo (veredicto comité)

1. **Fast-Reject (Nivel 1)**: si `archivos<3 && lineas<100 && riesgo==bajo` → `DIRECTO` (coste 0).
2. **Scoring (Nivel 2)**: `score = volumen*0.30 + coupling*0.30 + paralelizable*0.25 + riesgo*0.15` (0-10). `volumen` normalizado: `tokens/(1+factor_coupling)` o `min(10, lineas/50)`. `paralelizable = 1 - acoplados/total` escalado a 0-10.
3. **Umbral dinámico**: `umbral = 6.5 + (overhead-62000)/50000`. `overhead` estimado `62000 + archivos*20000` cap 143k (o `archivos*complejidad*1000`).
4. **Decisión**:
   - `score <4` → DIRECTO
   - `4 <= score < umbral` → VALLE MEDIO → juez con seeds fijos; veta Enjambre si `riesgo==alto || coupling>7`
   - `score >= umbral` → ENJAMBRE

## Uso
```powershell
Import-Module .\router.ps1
Invoke-EnjambreRouter -Archivos 4 -Lineas 100 -Coupling 3 -Paralelizable 8 -Riesgo bajo -Tokens 4000
# -> @{decision="DIRECTO"; score=...; umbral=...; motivo="..."}
```

## Config
`lab/router-config.json` contiene pesos y umbrales, calibrado con H-5/H-11. Recalibrar con 30+ muestras OOD antes de congelar.

## Integración orquestador
`enjambre-orquestador` debe llamar router antes de Regla 0. Si router dice DIRECTO → no workers. Si ENJAMBRE → validar-block.ps1 + workers.
