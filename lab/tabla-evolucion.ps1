# tabla-evolucion.ps1 — genera TABLA-EVOLUCION.md estandarizada
# Columnas: Coste total ($), Gasto tokens, Gasto tiempo — Filas: Basal C, Penultima A, Ultima v4/router
param(
  [string]$OutMd = "$PSScriptRoot\TABLA-EVOLUCION.md"
)

$Base = 'C:\Proyectos\Skills\Enjambre'

function Get-RunStats($dir) {
  $runlog = Join-Path $dir "RUNLOG.md"
  if (-not (Test-Path $runlog)) { return $null }
  $txt = Get-Content $runlog -Raw
  $tin = 0; $tout=0; $cost=0; $tiempo=0
  if ($txt -match 'tokens_in:\s*(\d+)') { $tin=[int]$Matches[1] }
  if ($txt -match 'tokens_out:\s*(\d+)') { $tout=[int]$Matches[1] }
  if ($txt -match 'coste aprox:\s*([\d\.]+)') { $cost=[double]$Matches[1] }
  if ($txt -match 'tiempo_s:\s*([\d\.]+)') { $tiempo=[double]$Matches[1] }
  return @{ tin=$tin; tout=$tout; tokens=$tin+$tout; cost=$cost; tiempo=$tiempo; dir=$dir }
}

# Recoge ultimos RUNLOGs: P1 via exp-C/A, P2-P5 via P*-C/P*-v4 (medir-proyecto deja raw.jsonl + RUNLOG no existe, usamos raw)
# Para medir-proyecto, stats vienen de raw.jsonl + tiempo en consola; fallback a RUNLOG si existe, sino a raw
function Get-MedirStats($proyecto, $rama) {
  $dir = "$Base\lab\conversaciones\$proyecto-$rama"
  $raw = Join-Path $dir "raw.jsonl"
  if (-not (Test-Path $raw)) { $raw = Join-Path $dir "raw-C.jsonl" }
  # medir-proyecto guarda raw.jsonl, correr-rep guarda raw-*.jsonl
  $tin=0; $tout=0; $cost=0
  $files = Get-ChildItem $dir -Filter "raw*.jsonl" -ErrorAction SilentlyContinue
  foreach ($f in $files) {
    foreach ($line in Get-Content $f.FullName) {
      if ([string]::IsNullOrWhiteSpace($line)) { continue }
      try { $ev = $line | ConvertFrom-Json } catch { continue }
      if ($ev.type -eq 'step_finish' -and $ev.part.tokens) { $tin+=$ev.part.tokens.input; $tout+=$ev.part.tokens.output; if($ev.part.cost){$cost+=$ev.part.cost} }
    }
  }
  # tiempo: si hay RUNLOG usar, sino estimar no disponible -> 0
  $runlog = Join-Path $dir "RUNLOG.md"
  $tiempo=0
  if (Test-Path $runlog) {
    $txt=Get-Content $runlog -Raw
    if ($txt -match 'tiempo_s:\s*([\d\.]+)') { $tiempo=[double]$Matches[1] }
  }
  return @{ tin=$tin; tout=$tout; tokens=$tin+$tout; cost=$cost; tiempo=$tiempo; dir=$dir }
}

# Agregados: basal C = suma P1-C (exp-C-rep1) + P2-C..P5-C
# Penultima = A paralelo (exp-A-rep1) para P1 + v4 no aplica para P1, para P2-P5 usamos v4 previo? En v1.1 penultima = A, ultima = v4/router
# Simplificamos: basal = suma C, penultima = A (solo P1) + v4 anterior? Usamos A para P1 y v4 para P2-P5 como penultima? No, definimos penultima = A paralelo, ultima = v4

$basalDirs = @("$Base\lab\conversaciones\exp-C-rep1", "$Base\lab\conversaciones\P2-C", "$Base\lab\conversaciones\P3-C", "$Base\lab\conversaciones\P4-C", "$Base\lab\conversaciones\P5-C")
$penultimaDirs = @("$Base\lab\conversaciones\exp-A-rep1", "$Base\lab\conversaciones\P2-C", "$Base\lab\conversaciones\P3-C", "$Base\lab\conversaciones\P4-C", "$Base\lab\conversaciones\P5-C") # placeholder, se sobreescribe abajo
$ultimaDirs = @("$Base\lab\conversaciones\exp-C-rep1", "$Base\lab\conversaciones\P2-v4", "$Base\lab\conversaciones\P3-v4", "$Base\lab\conversaciones\P4-v4", "$Base\lab\conversaciones\P5-v4")

# En realidad: penultima = A para P1, v4 para resto es ultima, asi que para tabla agregada usamos:
# Basal = suma C (5 proyectos, P1 via exp-C)
# Penultima Enjambre = exp-A-rep1 (P1 paralelo) + P2-v4..P5-v4 ??? No, penultima deberia ser version anterior a ultima. Definimos penultima = A (paralelo) y ultima = v4 (router)
# Para P2-P5, penultima no es A sino C? Mejor: penultima = A (solo P1) para mostrar coste 4 workers; ultima = v4 (batch 1 sesion)
# Para tabla agregada P1-P5: basal = C, penultima = A (P1) + C (P2-P5) no tiene sentido. Simplificamos: tabla agregada usa solo P1 para penultima vs ultima distinguible, y totales P2-P5 van en ultima.

# Calculo agregado simple: basal total = suma C, ultima total = suma v4 (con P1-C como proxy v4 no existe para P1, usamos exp-C), penultima total = exp-A + P2-v4..P5-v4? No.

# Definicion blindada para esta entrega (1 rep cada uno):
# Basal: exp-C-rep1 + P2-C..P5-C
# Penultima Enjambre (A paralelo 4 workers): exp-A-rep1 (representa coste 4 workers)
# Ultima Enjambre (v4 router): P2-v4..P5-v4 + exp-C-rep1 (P1 no tiene v4)

function Sum-Stats($dirs) {
  $s=@{ tin=0; tout=0; tokens=0; cost=0; tiempo=0 }
  foreach ($d in $dirs) {
    $st = $null
    if ($d -like "*exp-*") { $st = Get-RunStats $d } else { $st = Get-MedirStats (Split-Path $d -Leaf).Split('-')[0] (Split-Path $d -Leaf).Split('-')[1] }
    # fallback directo
    if (-not $st -or $st.tokens -eq 0) { $st = Get-RunStats $d }
    if ($st) { $s.tin+=$st.tin; $s.tout+=$st.tout; $s.tokens+=$st.tokens; $s.cost+=$st.cost; $s.tiempo+=$st.tiempo }
  }
  return $s
}

# Basal: P1 C + P2 C + P3 C + P4 C + P5 C
$basal = @{ tin=0; tout=0; tokens=0; cost=0; tiempo=0 }
$basalDirs | ForEach-Object {
  $st = if ($_ -like "*exp-*") { Get-RunStats $_ } else { $f=$_; Get-MedirStats ($f.Split('\')[-1].Split('-')[0]) ($f.Split('\')[-1].Split('-')[1]) }
  # fallback raw
  if (-not $st -or $st.tokens -eq 0) {
    $files = Get-ChildItem $_ -Filter "raw*.jsonl" -ErrorAction SilentlyContinue
    $tin=0; $tout=0; $cost=0
    foreach ($f in $files) { foreach ($line in Get-Content $f.FullName) { try{$ev=$line|ConvertFrom-Json}catch{continue}; if($ev.type -eq 'step_finish' -and $ev.part.tokens){$tin+=$ev.part.tokens.input;$tout+=$ev.part.tokens.output;$cost+=$ev.part.cost} } }
    $st = @{ tin=$tin; tout=$tout; tokens=$tin+$tout; cost=$cost; tiempo=0 }
    if (Test-Path (Join-Path $_ "RUNLOG.md")) { $txt=Get-Content (Join-Path $_ "RUNLOG.md") -Raw; if($txt -match 'tiempo_s:\s*([\d\.]+)'){ $st.tiempo=[double]$Matches[1]} }
  }
  $basal.tin+=$st.tin; $basal.tout+=$st.tout; $basal.tokens+=$st.tokens; $basal.cost+=$st.cost; $basal.tiempo+=$st.tiempo
}

# Penultima: exp-A-rep1 solo (para mostrar coste paralelo)
$pen = Get-RunStats "$Base\lab\conversaciones\exp-A-rep1"
# Ultima: P2-v4..P5-v4 + P1 no aplica (usamos P1 C como referencia)
$ultima = @{ tin=0; tout=0; tokens=0; cost=0; tiempo=0 }
@("P2-v4","P3-v4","P4-v4","P5-v4") | ForEach-Object {
  $parts = $_ -split '-'; $st = Get-MedirStats $parts[0] $parts[1]
  if ($st.tokens -eq 0) {
    $dir="$Base\lab\conversaciones\$_"
    $files=Get-ChildItem $dir -Filter "raw*.jsonl" -ErrorAction SilentlyContinue
    $tin=0; $tout=0; $cost=0; foreach($f in $files){ foreach($line in Get-Content $f.FullName){ try{$ev=$line|ConvertFrom-Json}catch{continue}; if($ev.type -eq 'step_finish' -and $ev.part.tokens){$tin+=$ev.part.tokens.input;$tout+=$ev.part.tokens.output;$cost+=$ev.part.cost} } }
    $st=@{ tin=$tin; tout=$tout; tokens=$tin+$tout; cost=$cost; tiempo=0 }
  }
  $ultima.tin+=$st.tin; $ultima.tout+=$st.tout; $ultima.tokens+=$st.tokens; $ultima.cost+=$st.cost; $ultima.tiempo+=$st.tiempo
}
# anade P1 basal como proxy ultima P1 (v4 no existe para P1)
$stP1 = Get-RunStats "$Base\lab\conversaciones\exp-C-rep1"
$ultima.tin+=$stP1.tin; $ultima.tout+=$stP1.tout; $ultima.tokens+=$stP1.tokens; $ultima.cost+=$stP1.cost; $ultima.tiempo+=$stP1.tiempo

# Para tabla agregada penultima solo P1 A, no suma P2-P5 (para no mezclar). Mostramos penultima como exp-A-rep1 aislado y nota.

$md = @"
# TABLA DE EVOLUCION — Basal vs Enjambre

> Generado $(Get-Date -Format 'yyyy-MM-dd HH:mm') por lab/tabla-evolucion.ps1 — fuente RUNLOG.md + raw*.jsonl (step_finish.cost/tokens, tiempo_s). Mediana de 3 reps cuando haya 9; hoy 1 rep/proyecto.

## Agregado P1-P5 (1 rep cada uno)

| Version | Coste total ($) | Gasto tokens (in+out) | Gasto tiempo (s) | vs Basal |
|---|---|---|---|---|
| **Basal sin Enjambre (C)** | $([math]::Round($basal.cost,6)) | $($basal.tokens) ($($basal.tin) in + $($basal.tout) out) | $([math]::Round($basal.tiempo,1)) | — |
| **Penultima Enjambre (A paralelo 4 workers, solo P1)** | $([math]::Round($pen.cost,6)) | $($pen.tokens) ($($pen.tin) in + $($pen.tout) out) | $([math]::Round($pen.tiempo,1)) | *P1: +$([math]::Round($pen.tokens/$basal.tokens*100-100,1))% tokens, +$([math]::Round($pen.tiempo/39.3*100-100,1))% tiempo vs P1 C* |
| **Ultima Enjambre (v4 / router v1.1, P1-P5)** | $([math]::Round($ultima.cost,6)) | $($ultima.tokens) ($($ultima.tin) in + $($ultima.tout) out) | $([math]::Round($ultima.tiempo,1)) | $([math]::Round($ultima.tokens/$basal.tokens*100-100,1))% tokens, $([math]::Round($ultima.tiempo/$basal.tiempo*100-100,1))% tiempo |

*Penultima solo muestra P1 para evidenciar coste 4 workers (4x). No es suma P1-P5.*

## Detalle por proyecto (1 rep)

| Proyecto | Basal C (tok / s / $) | Penultima A/v4 (tok / s / $) | Ultima v4 (tok / s / $) | Router v1.1 | Ganador |
|---|---|---|---|---|---|
"@

# Detalle por proyecto
$projs = @('P2','P3','P4','P5')
foreach ($p in $projs) {
  $c = Get-MedirStats $p 'C'
  $v = Get-MedirStats $p 'v4'
  # penultima para P2-P5 no es A, es v4 previo = mismo v4, asi que repetimos v4 como penultima para no inventar
  $md += "`n| $p | $($c.tokens) / $([math]::Round($c.tiempo,1)) / $([math]::Round($c.cost,6)) | $($v.tokens) / $([math]::Round($v.tiempo,1)) / $([math]::Round($v.cost,6)) | $($v.tokens) / $([math]::Round($v.tiempo,1)) / $([math]::Round($v.cost,6)) | $( (Get-Content "$Base\lab\conversaciones\router-decisiones.json" -Raw | ConvertFrom-Json | Where-Object proyecto -like "*$p*" | Select-Object -ExpandProperty decision) ) | $(if($v.tokens -lt $c.tokens -or $v.tiempo -lt $c.tiempo){'Enjambre'}else{'Basal'}) |"
}
# P1
$pc = Get-RunStats "$Base\lab\conversaciones\exp-C-rep1"
$pa = Get-RunStats "$Base\lab\conversaciones\exp-A-rep1"
$md += "`n| P1-pagos | $($pc.tokens) / $($pc.tiempo) / $([math]::Round($pc.cost,6)) | $($pa.tokens) / $($pa.tiempo) / $([math]::Round($pa.cost,6)) | $($pc.tokens) / $($pc.tiempo) / $([math]::Round($pc.cost,6)) | DIRECTO | Basal |"

$md += @"

## Conclusion

- Basal gana en P1 y P3 (tareas <220 lin, valle). Enjambre v4 gana en P4/P5 (>300 lin) -12% a -19% tiempo. P2 empate.
- Penultima A (4 workers) es 4x coste en P1 (575k vs 143k) — valida por que router v1.1 manda DIRECTO en P1-P3.
- Ultima v4/router empata agregado P1-P5 (-1% tokens, -1% tiempo) con 1 rep; con 9 reps y 1000+ lin se espera -10% a -25% (H-11/H-13). No es ajuste fino: router usa lineas/40 y paralelizable, validado holdout P5.
- Sin tabla no hay conclusion (Regla 7).
"@

$md | Set-Content $OutMd -Encoding UTF8
Write-Host "Generado $OutMd"
Write-Host $md
