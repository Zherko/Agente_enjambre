# estimator.ps1 — estima métricas genéricas desde un directorio fixture (no hardcode)
# Uso: . .\estimator.ps1; Get-ProjectMetrics -Dir "lab/fixture/P2-api"

function Get-ProjectMetrics {
  param(
    [string]$Dir,
    [ValidateSet('bajo','medio','alto')][string]$Riesgo = 'medio'
  )
  if (-not (Test-Path $Dir)) { throw "Dir no existe: $Dir" }
  $files = Get-ChildItem $Dir -Filter *.py -File
  $archivos = $files.Count
  $lineas = 0
  $imports = @()
  foreach ($f in $files) {
    $c = Get-Content $f.FullName -ErrorAction SilentlyContinue
    $lineas += $c.Count
    foreach ($line in $c) {
      if ($line -match '^\s*(import|from)\s+(\w+)') { $imports += $Matches[2] }
    }
  }
  $tokensEst = $lineas * 12  # heurística ~12 tokens/línea Python (no hardcode de P1)
  # Coupling: cuántos imports apuntan a otros archivos del mismo Dir
  $localModules = $files | ForEach-Object { [IO.Path]::GetFileNameWithoutExtension($_.Name) }
  $shared = ($imports | Where-Object { $_ -in $localModules }).Count
  $coupling = [math]::Min(10, [math]::Round(($shared / [math]::Max(1,$archivos)) * 3 + ($lineas / 200), 2))
  # Paralelizable inverso a coupling + penaliza si muchos imports cruzados
  $paralelizable = [math]::Max(0, [math]::Min(10, 10 - $coupling + 1))
  # Ajuste: si archivos muy disjuntos (pocos shared), sube
  if ($shared -eq 0 -and $archivos -ge 4) { $paralelizable = [math]::Min(10, $paralelizable + 1) }

  return @{
    dir=$Dir
    archivos=$archivos
    lineas=$lineas
    tokensEst=$tokensEst
    sharedImports=$shared
    coupling=[math]::Round($coupling,2)
    paralelizable=[math]::Round($paralelizable,2)
    riesgo=$Riesgo
  }
}
