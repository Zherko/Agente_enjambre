. "$PSScriptRoot\..\.opencode\skills\enjambre-router\router.ps1"

function Test-Case {
  param($nombre,$arch,$lin,$coup,$par,$riesgo,$tokens,$esperado)
  $r = Invoke-EnjambreRouter -Archivos $arch -Lineas $lin -Coupling $coup -Paralelizable $par -Riesgo $riesgo -Tokens $tokens
  $ok = if ($r.decision -eq $esperado) {'OK'} else {'FAIL'}
  Write-Host "$ok $nombre -> $($r.decision) esperado $esperado score=$($r.score) umbral=$($r.umbral) $($r.motivo)"
}

Write-Host "=== Router comite - 5 casos ===" -ForegroundColor Cyan
Test-Case -nombre "P1-pagos-pequeno" -arch 4 -lin 100 -coup 3 -par 8 -riesgo bajo -tokens 4000 -esperado DIRECTO
Test-Case -nombre "P3-pipeline-pesado" -arch 6 -lin 300 -coup 5 -par 7 -riesgo medio -tokens 15000 -esperado ENJAMBRE
Test-Case -nombre "Valle-riesgo-alto" -arch 4 -lin 200 -coup 8 -par 6 -riesgo alto -tokens 8000 -esperado DIRECTO
Test-Case -nombre "Trivial-fast-reject" -arch 1 -lin 40 -coup 2 -par 2 -riesgo bajo -tokens 1000 -esperado DIRECTO
Test-Case -nombre "Bulk-10-arch" -arch 10 -lin 400 -coup 2 -par 9 -riesgo bajo -tokens 20000 -esperado ENJAMBRE
Write-Host ""
Write-Host "--- Detalle ---"
$r1 = Invoke-EnjambreRouter -Archivos 4 -Lineas 100 -Coupling 3 -Paralelizable 8 -Riesgo bajo -Tokens 4000
Write-Host "P1: $($r1.decision) score=$($r1.score) umbral=$($r1.umbral)"
$r5 = Invoke-EnjambreRouter -Archivos 4 -Lineas 200 -Coupling 8 -Paralelizable 3 -Riesgo alto -Tokens 8000
Write-Host "Valle alto: $($r5.decision) score=$($r5.score)"
