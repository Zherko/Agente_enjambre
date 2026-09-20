. "$PSScriptRoot\..\.opencode\skills\enjambre-router\router.ps1"
. "$PSScriptRoot\..\.opencode\skills\enjambre-router\estimator.ps1"

$Base = 'C:\Proyectos\Skills\Enjambre'
$proyectos = @(
  @{ id='P1-pagos'; dir="$Base\lab\fixture\P1-pagos"; riesgo='bajo' },
  @{ id='P2-api'; dir="$Base\lab\fixture\P2-api"; riesgo='medio' },
  @{ id='P3-pipeline'; dir="$Base\lab\fixture\P3-pipeline"; riesgo='medio' },
  @{ id='P4-microservices'; dir="$Base\lab\fixture\P4-microservices"; riesgo='alto' },
  @{ id='P5-legacy'; dir="$Base\lab\fixture\P5-legacy"; riesgo='alto' },
  @{ id='P6-complex'; dir="$Base\lab\fixture\P6-complex"; riesgo='alto' }
)

Write-Host "=== Router generico - metricas reales del fixture ===" -ForegroundColor Cyan
$tabla = @()
foreach ($p in $proyectos) {
  $m = Get-ProjectMetrics -Dir $p.dir -Riesgo $p.riesgo
  $r = Invoke-EnjambreRouter -Archivos $m.archivos -Lineas $m.lineas -Coupling $m.coupling -Paralelizable $m.paralelizable -Riesgo $m.riesgo -Tokens $m.tokensEst
  $antiguo = if ($m.tokensEst -gt 10000) {'ENJAMBRE'} else {'DIRECTO'}
  $diff = if ($r.decision -ne $antiguo) {' DIFIERE vs 10k'} else {''}
  Write-Host "$($p.id): arch=$($m.archivos) lin=$($m.lineas) tokensEst=$($m.tokensEst) shared=$($m.sharedImports) coup=$($m.coupling) par=$($m.paralelizable) riesgo=$($m.riesgo) => $($r.decision) score=$($r.score) antiguo10k=$antiguo $diff"
  Write-Host "  motivo: $($r.motivo)"
  $tabla += [PSCustomObject]@{ proyecto=$p.id; archivos=$m.archivos; lineas=$m.lineas; tokensEst=$m.tokensEst; coupling=$m.coupling; paralelizable=$m.paralelizable; riesgo=$m.riesgo; decision=$r.decision; score=$r.score; antiguo10k=$antiguo }
}

Write-Host ""
Write-Host "=== Casos extremos sinteticos ===" -ForegroundColor Cyan
$extremos = @(
  @{ nombre='50-arch bulk disjunto'; arch=50; lin=5000; coup=2; par=9; riesgo='bajo'; tokens=60000 },
  @{ nombre='1-arch monolitico acoplado'; arch=1; lin=800; coup=9; par=1; riesgo='alto'; tokens=9600 },
  @{ nombre='20-arch microservicios'; arch=20; lin=2000; coup=6; par=7; riesgo='alto'; tokens=24000 }
)
foreach ($e in $extremos) {
  $r = Invoke-EnjambreRouter -Archivos $e.arch -Lineas $e.lin -Coupling $e.coup -Paralelizable $e.par -Riesgo $e.riesgo -Tokens $e.tokens
  Write-Host "$($e.nombre): arch=$($e.arch) lin=$($e.lin) coup=$($e.coup) par=$($e.par) => $($r.decision) score=$($r.score)"
}

$tabla | Format-Table -AutoSize | Out-String | Write-Host
$tabla | ConvertTo-Json -Depth 3 | Set-Content "$Base\lab\conversaciones\router-decisiones.json" -Encoding UTF8
Write-Host "Guardado router-decisiones.json"
