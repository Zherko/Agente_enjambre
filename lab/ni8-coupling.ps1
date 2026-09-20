# NI-8 coupling disjunto vs acoplado — mismo volumen, distinto paralelizable
$Base='C:\Proyectos\Skills\Enjambre'
$Exe=(Get-Command opencode -ErrorAction SilentlyContinue).Source; if(-not $Exe){$Exe='opencode'}
$Modelo='opencode-go/muse-spark-1.2-contributor'

function Run-Batch($dir,$outName){
  $Out="$Base\lab\conversaciones\$outName"
  New-Item -ItemType Directory -Force -Path $Out | Out-Null
  $msg="Analiza los 12 archivos de $dir. Para cada uno escribe un informe en $Out\informe-<nombre>.md con encabezados '# Informe: <nombre>' '## Resumen' '## Funciones' '## Dependencias' '## Riesgos'. Max 120 palabras por informe. Son 12 informes."
  $t0=Get-Date
  & $Exe run --dir $Base --model $Modelo --pure --format json $msg 2>$null | Set-Content "$Out\raw.jsonl" -Encoding UTF8
  $t1=Get-Date
  $seg=[math]::Round(($t1-$t0).TotalSeconds,1)
  $tin=0; $tout=0; $cost=0
  foreach($line in Get-Content "$Out\raw.jsonl"){ if([string]::IsNullOrWhiteSpace($line)){continue}; try{$ev=$line|ConvertFrom-Json}catch{continue}; if($ev.type -eq 'step_finish' -and $ev.part.tokens){$tin+=$ev.part.tokens.input; $tout+=$ev.part.tokens.output; $cost+=$ev.part.cost} }
  $tok=$tin+$tout
  Write-Host "$outName : tiempo=$seg s tokens=$tok cost=$cost"
  return @{seg=$seg; tokens=$tok; cost=$cost}
}

Write-Host "=== NI8 disjunto (coup 0 par 10) vs acoplado (coup 10 par 1) ===" -ForegroundColor Cyan
. "$Base\.opencode\skills\enjambre-router\estimator.ps1"
. "$Base\.opencode\skills\enjambre-router\router.ps1"

$mDis=Get-ProjectMetrics -Dir "$Base\lab\fixture\P6-disjunto" -Riesgo alto
$rDis=Invoke-EnjambreRouter -Archivos $mDis.archivos -Lineas $mDis.lineas -Coupling $mDis.coupling -Paralelizable $mDis.paralelizable -Riesgo $mDis.riesgo -Tokens $mDis.tokensEst
Write-Host "Disjunto: arch=$($mDis.archivos) lin=$($mDis.lineas) coup=$($mDis.coupling) par=$($mDis.paralelizable) => $($rDis.decision) score=$($rDis.score)"

$mAco=Get-ProjectMetrics -Dir "$Base\lab\fixture\P6-complex" -Riesgo alto
$rAco=Invoke-EnjambreRouter -Archivos $mAco.archivos -Lineas $mAco.lineas -Coupling $mAco.coupling -Paralelizable $mAco.paralelizable -Riesgo $mAco.riesgo -Tokens $mAco.tokensEst
Write-Host "Acoplado: arch=$($mAco.archivos) lin=$($mAco.lineas) coup=$($mAco.coupling) par=$($mAco.paralelizable) => $($rAco.decision) score=$($rAco.score)"
Write-Host ""

$r1=Run-Batch "$Base\lab\fixture\P6-disjunto" "NI8-disjunto"
$r2=Run-Batch "$Base\lab\fixture\P6-complex" "NI8-acoplado"
Write-Host ""
Write-Host "Delta: disjunto $($r1.seg)s/$($r1.tokens) vs acoplado $($r2.seg)s/$($r2.tokens)"
