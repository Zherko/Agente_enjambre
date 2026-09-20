# NI11: MICRO-tech (6×2 paralelo) vs BATCH 1×12 sobre P6-complex 1461 líneas
# Medición: pared + tokens_in/out desde raw JSONL (step_finish.part.tokens)
# Uso: .\NI11-harness.ps1 -Rama BATCH|MICRO  |  .\NI11-harness.ps1 -RunBoth  (hace las 2 ramas)

param(
  [ValidateSet('BATCH','MICRO')][string]$Rama,
  [switch]$RunBoth
)

$Base = 'C:\Proyectos\Skills\Enjambre'
$Fix  = "$Base\lab\fixture\P6-complex"
$ModeloBatch = 'opencode-go/deepseek-v4-flash'   # igual que NI7-batch
$ModeloMicro = 'opencode-go/muse-spark-1.2-contributor' # 6 workers
$Exe = (Get-Command opencode -ErrorAction SilentlyContinue).Source
if (-not $Exe) { $Exe = 'opencode' }

# 12 módulos P6
$mods = @('analytics','auth','config','events','gateway','inventory','notifications','orders','payments','shipping','users','utils')

# Agrupación MICRO: 6 dominios x2 archivos (simula css/html/js/seo/python/postgres pero con python reales)
$microGroups = @(
  @{name='micro-dominio-auth';     files=@('auth','users'); label='auth/users'},
  @{name='micro-dominio-payments'; files=@('payments','orders'); label='payments/orders'},
  @{name='micro-dominio-infra';    files=@('config','gateway'); label='config/gateway'},
  @{name='micro-dominio-events';   files=@('events','notifications'); label='events/notifications'},
  @{name='micro-dominio-logistics';files=@('shipping','inventory'); label='shipping/inventory'},
  @{name='micro-dominio-analytics';files=@('analytics','utils'); label='analytics/utils'}
)

function Invoke-LabRun([string]$msg, [string]$raw, [string]$model) {
  & $Exe run --dir $Base --model $model --pure --format json $msg 2>$null | Set-Content $raw -Encoding UTF8
}

function Run-One([string]$which) {
  $Out = "$Base\lab\conversaciones\NI11-$which"
  New-Item -ItemType Directory -Force -Path $Out | Out-Null
  Remove-Item "$Out\raw-*.jsonl" -ErrorAction SilentlyContinue
  Remove-Item "$Out\informe-*.md" -ErrorAction SilentlyContinue

  # block.json
  if ($which -eq 'BATCH') {
    $claims = @(@{agent='enjambre-writer-batch'; subtask='T-batch-12'; files=@('lab/conversaciones/NI11-BATCH/informe-*.md'); status='active'})
  } else {
    $claims = @()
    foreach ($g in $microGroups) {
      $flist = $g.files | ForEach-Object { "lab/conversaciones/NI11-MICRO/informe-$_.md" }
      $claims += @{agent='enjambre-exp-worker'; subtask="T-$($g.name)"; files=$flist; status='active'}
    }
  }
  @{ '$schema'='./block.schema.json'; run="NI11-$which"; workspaceRoot=$Base; claims=$claims; updated=(Get-Date).ToUniversalTime().ToString('o') } | ConvertTo-Json -Depth 5 | Set-Content "$Base\block.json" -Encoding UTF8
  $valOut = (& "$Base\lab\validar-block.ps1" "$Base\block.json" 2>&1 | Out-String).Trim()
  Write-Host "Validador $which : $valOut" -ForegroundColor Cyan
  if ($valOut -notmatch '^OK:') { Write-Host "ABORTADO $which : validador rojo" -ForegroundColor Red; return }

  $t0 = Get-Date
  if ($which -eq 'BATCH') {
    # 1 sesión batch que hace los 12 informes (prompt verbatim genérico, igual que NI7-batch)
    $lista = ($mods | ForEach-Object { "$Fix\$_.py -> $Out\informe-$_.md" }) -join ', '
    $msg = "@enjambre-writer-batch Lee los 12 modulos de $Fix (analytics.py, auth.py, config.py, events.py, gateway.py, inventory.py, notifications.py, orders.py, payments.py, shipping.py, users.py, utils.py) y redacta 12 informes en $Out (informe-analytics.md ... informe-utils.md) con encabezados '# Informe: <modulo>', '## Resumen' (max 40 palabras), '## Funciones', '## Dependencias', '## Riesgos'. Max 150 palabras por informe. No hagas nada mas."
    Invoke-LabRun $msg "$Out\raw-batch.jsonl" $ModeloBatch
  } else {
    # 6 workers en paralelo, cada uno hace 2 archivos secuencialmente dentro de su sesión (simula micro especialista)
    # Para mantener 1 raw por worker, cada worker hace 2 writes en la misma sesión con 2 mensajes? No — 1 mensaje que pide 2 informes
    $jobs = @()
    foreach ($g in $microGroups) {
      $pair = $g.files
      $raw = "$Out\raw-$($g.name).jsonl"
      # Cada micro lleva hint de especialidad en el prompt (simula css/html/js/seo/python/postgres especializado)
      $m1 = "$Fix\$($pair[0]).py"; $s1 = "$Out\informe-$($pair[0]).md"
      $m2 = "$Fix\$($pair[1]).py"; $s2 = "$Out\informe-$($pair[1]).md"
      $especialidad = $g.name
      $msg = "Eres especialista $especialidad . Lee $m1 y redacta $s1 y lee $m2 y redacta $s2 , cada uno con encabezados '# Informe: <modulo>', '## Resumen' (max 40 palabras), '## Funciones', '## Dependencias', '## Riesgos'. Max 150 palabras por informe. No hagas nada mas. Actua como enjambre-exp-worker."
      $jobs += Start-Job -ScriptBlock { param($e,$b,$m,$g,$r) & $e run --dir $b --model $m --pure --format json $g 2>$null | Set-Content $r -Encoding UTF8 } -ArgumentList $Exe, $Base, $ModeloMicro, $msg, $raw
    }
    $jobs | Wait-Job | Out-Null
    $jobs | Receive-Job | Out-Null
  }
  $t1 = Get-Date
  $seg = [math]::Round(($t1-$t0).TotalSeconds,1)

  # Métricas
  $tin=0; $tout=0; $cost=0; $sids=@()
  foreach ($f in (Get-ChildItem "$Out\raw-*.jsonl" -ErrorAction SilentlyContinue)) {
    foreach ($line in (Get-Content $f.FullName -ErrorAction SilentlyContinue)) {
      if ([string]::IsNullOrWhiteSpace($line)) { continue }
      try { $ev = $line | ConvertFrom-Json } catch { continue }
      if ($ev.type -eq 'step_finish' -and $ev.part.tokens) { $tin+=$ev.part.tokens.input; $tout+=$ev.part.tokens.output; $cost+=$ev.part.cost }
      if ($ev.type -eq 'step_start') { $sids+=$ev.sessionID }
    }
  }
  $sids = @($sids | Select-Object -Unique)

  # Verificación 12 informes
  $heads = @('# Informe:','## Resumen','## Funciones','## Dependencias','## Riesgos')
  $okN=0; $palTot=0; $det=@()
  foreach ($m in $mods) {
    $p="$Out\informe-$m.md"
    if (Test-Path $p) {
      $txt=Get-Content $p -Raw
      $pal=(Get-Content $p | Measure-Object -Word).Words
      $palTot+=$pal
      $hq=$true; foreach ($h in $heads){ if ($txt -notmatch [regex]::Escape($h)){ $hq=$false } }
      if ($hq -and $pal -le 150){ $okN++ }
      $det+="  - informe-$m.md: $pal palabras, esquema_ok $hq"
    } else { $det+="  - informe-$m.md: AUSENTE" }
  }

  $runlog = @"
# RUNLOG NI11-$which

- fecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm')
- ejecutor: lab/NI11-harness.ps1 / modelo: $(if($which -eq 'BATCH'){$ModeloBatch}else{$ModeloMicro})
- rama: $which (P6-complex 12 modulos, 1461 lineas)
- session_id: $($sids -join ', ')
- validador: $valOut
- t_inicio: $($t0.ToString('HH:mm:ss')) / t_fin: $($t1.ToString('HH:mm:ss')) / tiempo_s: $seg
- tokens_in: $tin / tokens_out: $tout / tokens_tot: $($tin+$tout) (coste: $cost) / sesiones: $($sids.Count)
- informes: $okN/12 ok, palabras_tot: $palTot
$($det -join "`n")
- veredicto_rep: $(if($okN -eq 12){'valida'}else{'INVALIDA'})
"@
  $runlog | Set-Content "$Out\RUNLOG.md" -Encoding UTF8
  Write-Host "NI11-$which : tiempo_s=$seg tokens_in=$tin tokens_out=$tout tot=$($tin+$tout) informes=$okN/12 palabras=$palTot sesiones=$($sids.Count) coste=$cost" -ForegroundColor Green
  Write-Host "FILA: | $(Get-Date -Format 'yyyy-MM-dd') | NI11-$which | 1 | $seg | $tin | $tout | $okN/12 | $(if($okN -eq 12){'si'}else{'no'}) | $palTot | si | si | P6-1461 |"
  # block done
  $j = Get-Content "$Base\block.json" -Raw | ConvertFrom-Json
  foreach ($c in $j.claims){ $c.status='done' }
  $j | ConvertTo-Json -Depth 5 | Set-Content "$Base\block.json" -Encoding UTF8
}

if ($RunBoth) { Run-One 'BATCH'; Run-One 'MICRO' } else { Run-One $Rama }
