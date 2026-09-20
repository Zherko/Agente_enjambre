# Harness de ejecucion del experimento (skill enjambre-benchmark).
# Rama A: 4 dispatches en paralelo (Start-Job). B: 4 en secuencia. C: 1 agente.
# Uso: .\correr-rep.ps1 -Rama A -Rep 1
# Deja en OUT: raw-<t>.jsonl, RUNLOG.md, 4 informes. Imprime fila RESULTADOS.
param(
  [ValidateSet('A', 'B', 'C')][string]$Rama,
  [ValidateRange(1, 9)][int]$Rep
)

$Base   = 'C:\Proyectos\Skills\Enjambre'
$Exe    = (Get-Command opencode -ErrorAction SilentlyContinue).Source
if (-not $Exe) { $Exe = 'opencode' }
$Modelo = 'opencode-go/muse-spark-1.2-contributor'
$Out    = "$Base\lab\conversaciones\exp-$Rama-rep$Rep"
$Fix    = "$Base\lab\fixture\P1-pagos"
New-Item -ItemType Directory -Force -Path $Out | Out-Null

# 0. Blindaje: fixture hashes
$Ref = @{
  'pagos.py' = '6C88743EA566D95DB5CD5632A3ADD3682DEB7FA8E9A7874C4F7D30960D9552CB'
  'usuarios.py' = '4B88F4FA64680455573E0EF866302D7F3ED05123AFBCD3340B8878BA64C76F56'
  'inventario.py' = '089C6FB4EE30BC41D4941CF5BB8744DA84E4DB8CE4EF6864E99FBD57FE9B0D76'
  'notificaciones.py' = '5B69B0858EFA6BA03B523FDE2DB45020826B1928A0EA1FBE19C5B68C3F170A8C'
}
$hashOk = $true
foreach ($f in $Ref.Keys) {
  $h = (Get-FileHash (Join-Path $Fix $f) -Algorithm SHA256).Hash
  if ($h -ne $Ref[$f]) { $hashOk = $false; Write-Host "HASH DISTINTO: $f" -ForegroundColor Red }
}
if (-not $hashOk) { Write-Host 'ABORTADO: fixture modificado.' -ForegroundColor Red; exit 2 }

$mods = @('pagos', 'usuarios', 'inventario', 'notificaciones')
$valOut = 'N/A'
if ($Rama -ne 'C') {
  # 1. block.json de la corrida + gate
  $claims = @()
  foreach ($m in $mods) { $claims += @{agent = 'enjambre-exp-worker'; subtask = "T-$m"; files = @("lab/conversaciones/exp-$Rama-rep$Rep/informe-$m.md"); status = 'active' } }
  @{ '$schema' = './block.schema.json'; run = "exp-$Rama-rep$Rep"; workspaceRoot = $Base; claims = $claims; updated = (Get-Date).ToUniversalTime().ToString('o') } | ConvertTo-Json -Depth 5 | Set-Content "$Base\block.json" -Encoding UTF8
  $valOut = (& "$Base\lab\validar-block.ps1" "$Base\block.json" 2>&1 | Out-String).Trim()
  Write-Host $valOut
  if ($valOut -notmatch '^OK:') { Write-Host 'ABORTADO: validador en rojo.' -ForegroundColor Red; exit 1 }
}

function Invoke-LabRun([string]$msg, [string]$raw) {
  & $Exe run --dir $Base --model $Modelo --pure --format json $msg 2>$null | Set-Content $raw -Encoding UTF8
}

$msgs = @()
if ($Rama -eq 'C') {
  $msgs += @{t = 'C'; msg = "Lee los 4 modulos de $Fix (pagos.py, usuarios.py, inventario.py, notificaciones.py) y redacta los 4 informes en $Out (informe-pagos.md, informe-usuarios.md, informe-inventario.md, informe-notificaciones.md) con exactamente los encabezados: '# Informe: <modulo>', '## Resumen' (max 40 palabras), '## Funciones', '## Dependencias', '## Riesgos'. Max 150 palabras por informe. No hagas nada mas." }
} else {
  foreach ($m in $mods) {
    $mod = "$Fix\$m.py"; $sal = "$Out\informe-$m.md"
    $msgs += @{t = $m; msg = "@enjambre-exp-worker Lee $mod y redacta $sal según tu system prompt. No hagas nada más." }
  }
}

$t0 = Get-Date
if ($Rama -eq 'A') {
  $jobs = @()
  foreach ($x in $msgs) {
    $raw = "$Out\raw-$($x.t).jsonl"
    $jobs += Start-Job -ScriptBlock { param($e, $b, $m, $g, $r) & $e run --dir $b --model $m --pure --format json $g 2>$null | Set-Content $r -Encoding UTF8 } -ArgumentList $Exe, $Base, $Modelo, $x.msg, $raw
  }
  $jobs | Wait-Job | Out-Null
  $jobs | Receive-Job | Out-Null
} else {
  foreach ($x in $msgs) { Invoke-LabRun $x.msg "$Out\raw-$($x.t).jsonl" }
}
$t1 = Get-Date
$seg = [math]::Round(($t1 - $t0).TotalSeconds, 1)

# 2. Metricas desde raw JSONL
$tin = 0; $tout = 0; $cost = 0; $sids = @()
foreach ($f in (Get-ChildItem "$Out\raw-*.jsonl")) {
  foreach ($line in (Get-Content $f.FullName)) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    try { $ev = $line | ConvertFrom-Json } catch { continue }
    if ($ev.type -eq 'step_finish' -and $ev.part.tokens) { $tin += $ev.part.tokens.input; $tout += $ev.part.tokens.output; $cost += $ev.part.cost }
    if ($ev.type -eq 'step_start') { $sids += $ev.sessionID }
  }
}
$sids = @($sids | Select-Object -Unique)

# 3. Verificacion de informes
$heads = @('# Informe:', '## Resumen', '## Funciones', '## Dependencias', '## Riesgos')
$okN = 0; $palTot = 0; $det = @()
foreach ($m in $mods) {
  $p = "$Out\informe-$m.md"
  if (Test-Path $p) {
    $txt = Get-Content $p -Raw
    $pal = (Get-Content $p | Measure-Object -Word).Words
    $palTot += $pal
    $hq = $true; foreach ($h in $heads) { if ($txt -notmatch [regex]::Escape($h)) { $hq = $false } }
    if ($hq -and $pal -le 150) { $okN++ }
    $det += "  - informe-$m.md: $pal palabras, esquema_ok $hq"
  } else { $det += "  - informe-$m.md: AUSENTE" }
}

$runlog = @"
# RUNLOG exp-$Rama-rep$Rep

- fecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm')
- ejecutor: lab/correr-rep.ps1 / modelo ejecutor: $Modelo
- session_id: $($sids -join ', ')
- fixture_hash_ok: $(if ($hashOk) {'OK'} else {'FALLO'})
- validador: $valOut
- t_inicio: $($t0.ToString('HH:mm:ss')) / t_fin: $($t1.ToString('HH:mm:ss')) / tiempo_s: $seg
- tokens_in: $tin / tokens_out: $tout (coste aprox: $cost)
- informes:
$($det -join "`n")
- incidencias: ninguna
- veredicto_rep: $(if ($okN -eq 4) {'valida'} else {'INVALIDA: esquema incompleto'})
"@
$runlog | Set-Content "$Out\RUNLOG.md" -Encoding UTF8

Write-Host "RAMA=$Rama REP=$Rep TIEMPO=$seg TOKENS_IN=$tin TOKENS_OUT=$tout INFORMES=$okN/4 PALABRAS=$palTot SESIONES=$($sids.Count)"
Write-Host "FILA: | $(Get-Date -Format 'yyyy-MM-dd') | $Rama | $Rep | $seg | $tin | $tout | $okN/4 | $(if ($okN -eq 4) {'si'} else {'no'}) | $palTot | si | si | auto |"
