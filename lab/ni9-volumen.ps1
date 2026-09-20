# NI-9 volumen 1461 vs 2229 lin
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
  Write-Host "$outName : tiempo=$seg s tokens=$($tin+$tout) cost=$cost"
  return @{seg=$seg; tokens=$tin+$tout; cost=$cost}
}

Write-Host "=== NI9 1461 vs 2229 lin (batch 1 sesion) ===" -ForegroundColor Cyan
$r1=Run-Batch "$Base\lab\fixture\P6-complex" "NI9-1461"
$r2=Run-Batch "$Base\lab\fixture\P6-3000" "NI9-2229"
Write-Host ""
Write-Host "Delta: 1461->2229 (+52% lin) tiempo $($r1.seg)s -> $($r2.seg)s (+$([math]::Round($r2.seg/$r1.seg*100-100,1))%) tokens $($r1.tokens) -> $($r2.tokens) (+$([math]::Round($r2.tokens/$r1.tokens*100-100,1))%)"
