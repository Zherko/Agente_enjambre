# Validador anti-solape de block.json (Enjambre)
# Gate pre-lanzamiento del orquestador (Agent.md Regla 1.2).
# Falla (exit 1) si dos claims `active` de DISTINTOS agentes se solapan
# (igualdad exacta, prefijo de directorio o patron que lo contiene).
# Uso: .\validar-block.ps1 [ruta block.json]
param([string]$Block = (Join-Path $PSScriptRoot '..\block.json'))

function Norm([string]$p) { ($p -replace '/', '\').Trim('\').ToLowerInvariant() }
function Overlap([string]$a, [string]$b) {
  $a = Norm $a; $b = Norm $b
  if ($a -eq $b) { return $true }
  $pa = $a -replace '\*\*|\*', ''
  $pb = $b -replace '\*\*|\*', ''
  if ($pa -ne '' -and ($b.StartsWith($pa) -or $a.StartsWith($pb))) { return $true }
  return ($a.StartsWith($b) -or $b.StartsWith($a))
}

$j = Get-Content $Block -Raw | ConvertFrom-Json
$act = @($j.claims | Where-Object { $_.status -eq 'active' })
$fallos = @()
for ($i = 0; $i -lt $act.Count; $i++) {
  for ($k = $i + 1; $k -lt $act.Count; $k++) {
    if ($act[$i].agent -eq $act[$k].agent) { continue }
    foreach ($f1 in $act[$i].files) {
      foreach ($f2 in $act[$k].files) {
        if (Overlap $f1 $f2) { $fallos += "'$($act[$i].agent)' [$f1] <-> '$($act[$k].agent)' [$f2]" }
      }
    }
  }
}
if ($fallos.Count -gt 0) {
  Write-Output 'SOLAPE DETECTADO — paralelizar PROHIBIDO (ir a secuencial):'
  $fallos | ForEach-Object { Write-Output "  $_" }
  exit 1
}
Write-Output "OK: $($act.Count) claims activos sin solape. Paralelo autorizado."
