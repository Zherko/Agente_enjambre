# Proyecto P6-PARALELO-4ARCHIVOS
# Tipo: REQUIERE SESIÓN paralela (Regla 0 nivel 3, discriminator de paralelismo)
# Fixture: P1-pagos/ (4 archivos, ~25 lineas c/u)
# Objetivo: medir speedup real de paralelización (A vs B vs C)

## Prompt verbatim (rama A: paralelo)

Lanza 4 workers en paralelo. Cada worker lee UN archivo de lab/fixture/P1-pagos/ y escribe UN informe en lab/conversaciones/P6-<RAMA>-rep<N>/:
- Worker 1: pagos.py → informe-pagos.md
- Worker 2: usuarios.py → informe-usuarios.md
- Worker 3: inventario.py → informe-inventario.md
- Worker 4: notificaciones.py → informe-notificaciones.md

Cada informe tiene estos encabezados:
# Informe: <nombre>.py
## Resumen (max 40 palabras)
## Funciones (lista: nombre - una línea)
## Dependencias (imports)
## Riesgos (max 3)

Max 100 palabras por informe.

## Prompt verbatim (rama B: secuencial)

Misma tarea que rama A, pero ejecuta 1 worker a la vez (secuencial).

## Prompt verbatim (rama C: basal, sin Enjambre)

Lee los 4 archivos de lab/fixture/P1-pagos/ y redacta los 4 informes en lab/conversaciones/P6-C-rep<N>/ con los mismos encabezados.

## Archivos de entrada
- lab/fixture/P1-pagos/*.py (4 archivos)

## Archivos de salida
- lab/conversaciones/P6-<RAMA>-rep<N>/informe-pagos.md
- lab/conversaciones/P6-<RAMA>-rep<N>/informe-usuarios.md
- lab/conversaciones/P6-<RAMA>-rep<N>/informe-inventario.md
- lab/conversaciones/P6-<RAMA>-rep<N>/informe-notificaciones.md

## Criterio de éxito
1. 4 informes existen con encabezados correctos
2. Cada uno ≤100 palabras
3. Funciones reales del fixture listadas
4. Los 4 informes son distintos (no copia del mismo)

## Scoring
- 2 puntos por informe válido = 8 puntos max
- 1 punto extra si todos son distintos = 9 puntos max

## Métrica discriminator
- speedup = tiempo_B / tiempo_A (¿compensa paralelizar?)
- tokens_ratio = tokens_A / tokens_B (¿cuánto más cuesta A?)
- Si speedup > 1.5 Y tokens_ratio < 2.0 → Enjambre compensa
- Si speedup < 1.5 O tokens_ratio > 2.0 → Enjambre no compensa

## Tokens estimados
- Trabajo real por worker: ~500 tokens
- Total trabajo real: ~2k tokens
- Con Enjambre paralelo: ~272k (4 × 68k overhead)
- Con Enjambre secuencial: ~272k (4 × 68k overhead)
- Basal: ~68k (1 sesión)
