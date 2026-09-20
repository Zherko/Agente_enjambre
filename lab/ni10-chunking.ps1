# NI-10 chunking 1x12 vs 2x6 vs 3x4 en P6 1461 lin
$Base='C:\Proyectos\Skills\Enjambre'
$Exe=(Get-Command opencode -ErrorAction SilentlyContinue).Source; if(-not $Exe){$Exe='opencode'}
$Modelo='opencode-go/muse-spark-1.2-contributor'
$Fix="$Base\lab\fixture\P6-complex"
$all=(Get-ChildItem $Fix -Filter *.py | ForEach-Object BaseName)

function Run-Chunk($names,$outDir){
  $msg="Analiza los $($names.Count) archivos de $Fix ($($names -join ', ')). Para cada uno escribe un informe en $outDir\informe-<nombre>.md con encabezados '# Informe: <nombre>' '## Resumen' '## Funciones' '## Dependencias' '## Riesgos'. Max 120 palabras por informe. Son $($names.Count) informes."
  $t0=Get-Date
  & $Exe run --dir $Base --model $Modelo --pure --format json $msg 2>$null | Set-Content "$outDir\raw.jsonl" -Encoding UTF8
  $t1=Get-Date
  $seg=[math]::Round(($t1-$t0).TotalSeconds,1)
  $tin=0; $tout=0; $cost=0
  foreach($line in Get-Content "$OutDir\raw.jsonl"){ if([string]::IsNullOrWhiteSpace($line)){continue}; try{$ev=$line|ConvertFrom-Json}catch{continue}; if($ev.type -eq 'step_finish' -and $ev.part.tokens){$tin+=$ev.part.tokens.input; $tout+=$ev.part.tokens.output; $cost+=$ev.part.cost} }
  return @{seg=$seg; tokens=$tin+$tout; cost=$cost; tin=$tin; tout=$tout}
}

Write-Host "=== NI10 1x12 ===" -ForegroundColor Cyan
$Out1="$Base\lab\conversaciones\NI10-1x12"; New-Item -ItemType Directory -Force -Path $Out1 | Out-Null
$r1=Run-Chunk $all $Out1
Write-Host "1x12: $($r1.seg)s tok=$($r1.tokens) cost=$($r1.cost)"

Write-Host "=== NI10 2x6 secuencial ===" -ForegroundColor Cyan
$Out2a="$Base\lab\conversaciones\NI10-2x6a"; $Out2b="$Base\lab\conversaciones\NI10-2x6b"; New-Item -ItemType Directory -Force -Path $Out2a,$Out2b | Out-Null
$mid=[int]($all.Count/2); $g1=$all[0..($mid-1)]; $g2=$all[$mid..($all.Count-1)]
$t0=Get-Date
$r2a=Run-Chunk $g1 $Out2a
$r2b=Run-Chunk $g2 $Out2b
$t1=Get-Date
$seg2=[math]::Round(($r2a.seg+$r2b.seg),1) # secuencial suma
$tok2=$r2a.tokens+$r2b.tokens; $cost2=$r2a.cost+$r2b.cost
Write-Host "2x6: ${seg2}s tok=$tok2 cost=$cost2 (a $($r2a.seg)s + b $($r2b.seg)s)"

Write-Host "=== NI10 3x4 secuencial ===" -ForegroundColor Cyan
$Out3a="$Base\lab\conversaciones\NI10-3x4a"; $Out3b="$Base\lab\conversaciones\NI10-3x4b"; $Out3c="$Base\lab\conversaciones\NI10-3x4c"; New-Item -ItemType Directory -Force -Path $Out3a,$Out3b,$Out3c | Out-Null
$g1=$all[0..3]; $g2=$all[4..7]; $g3=$all[8..11]
$r3a=Run-Chunk $g1 $Out3a; $r3b=Run-Chunk $g2 $Out3b; $r3c=Run-Chunk $g3 $Out3c
$seg3=[math]::Round(($r3a.seg+$r3b.seg+$r3c.seg),1)
$tok3=$r3a.tokens+$r3b.tokens+$r3c.tokens; $cost3=$r3a.cost+$r3b.cost+$r3c.cost
Write-Host "3x4: ${seg3}s tok=$tok3 cost=$cost3"

Write-Host ""
Write-Host "NI10 Resultado:"
Write-Host "1x12 $($r1.seg)s $($r1.tokens) vs 2x6 ${seg2}s $tok2 vs 3x4 ${seg3}s $tok3"
