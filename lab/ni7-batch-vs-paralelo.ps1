# NI-7 — Batch 1 sesion vs Paralelo 12 workers en P6-complex
param([switch]$SoloBatch)

$Base='C:\Proyectos\Skills\Enjambre'
$Exe=(Get-Command opencode -ErrorAction SilentlyContinue).Source; if(-not $Exe){$Exe='opencode'}
$Modelo='opencode-go/muse-spark-1.2-contributor'
$Fix="$Base\lab\fixture\P6-complex"

# Batch: 1 sesion writer-batch hace 12 informes (simula v4 pero con P6)
$OutBatch="$Base\lab\conversaciones\NI7-batch"
New-Item -ItemType Directory -Force -Path $OutBatch | Out-Null
$msgBatch="Analiza los 12 archivos de $Fix. Para cada uno escribe un informe en $OutBatch\informe-<nombre>.md con encabezados '# Informe: <nombre>' '## Resumen' '## Funciones' '## Dependencias' '## Riesgos'. Max 120 palabras por informe. Son 12 informes."
Write-Host "=== NI7 Batch 1 sesion ===" -ForegroundColor Cyan
$t0=Get-Date
& $Exe run --dir $Base --model $Modelo --pure --format json $msgBatch 2>$null | Set-Content "$OutBatch\raw.jsonl" -Encoding UTF8
$t1=Get-Date
$segBatch=[math]::Round(($t1-$t0).TotalSeconds,1)
$tin=0; $tout=0; $cost=0
foreach($line in Get-Content "$OutBatch\raw.jsonl"){ if([string]::IsNullOrWhiteSpace($line)){continue}; try{$ev=$line|ConvertFrom-Json}catch{continue}; if($ev.type -eq 'step_finish' -and $ev.part.tokens){$tin+=$ev.part.tokens.input; $tout+=$ev.part.tokens.output; $cost+=$ev.part.cost} }
Write-Host "Batch: tiempo=$segBatch s tokens=$($tin+$tout) cost=$cost"

if($SoloBatch){ exit }

# Paralelo: 12 workers, cada uno 1 archivo
$OutPar="$Base\lab\conversaciones\NI7-paralelo"
New-Item -ItemType Directory -Force -Path $OutPar | Out-Null
$mods=(Get-ChildItem $Fix -Filter *.py | ForEach-Object BaseName)
Write-Host "=== NI7 Paralelo 12 workers ===" -ForegroundColor Cyan
$claims=@(); foreach($m in $mods){ $claims+=@{agent='enjambre-exp-worker'; subtask="T-$m"; files=@("lab/conversaciones/NI7-paralelo/informe-$m.md"); status='active'} }
@{ '$schema'='./block.schema.json'; run='NI7-paralelo'; workspaceRoot=$Base; claims=$claims; updated=(Get-Date).ToUniversalTime().ToString('o')} | ConvertTo-Json -Depth 5 | Set-Content "$Base\block.json" -Encoding UTF8
powershell -ExecutionPolicy Bypass -File "$Base\lab\validar-block.ps1" "$Base\block.json" | Write-Host

$t0=Get-Date
$jobs=@()
foreach($m in $mods){
  $modPath="$Fix\$m.py"; $sal="$OutPar\informe-$m.md"
  $msg="@enjambre-exp-worker Lee $modPath y redacta $sal segun tu system prompt. No hagas nada mas."
  $raw="$OutPar\raw-$m.jsonl"
  $jobs+=Start-Job -ScriptBlock { param($e,$b,$mm,$g,$r) & $e run --dir $b --model $mm --pure --format json $g 2>$null | Set-Content $r -Encoding UTF8 } -ArgumentList $Exe,$Base,$Modelo,$msg,$raw
}
$jobs | Wait-Job | Out-Null
$jobs | Receive-Job | Out-Null
$t1=Get-Date
$segPar=[math]::Round(($t1-$t0).TotalSeconds,1)
$tin=0; $tout=0; $cost=0
foreach($f in Get-ChildItem "$OutPar\raw-*.jsonl"){ foreach($line in Get-Content $f.FullName){ if([string]::IsNullOrWhiteSpace($line)){continue}; try{$ev=$line|ConvertFrom-Json}catch{continue}; if($ev.type -eq 'step_finish' -and $ev.part.tokens){$tin+=$ev.part.tokens.input; $tout+=$ev.part.tokens.output; $cost+=$ev.part.cost} } }
Write-Host "Paralelo: tiempo=$segPar s tokens=$($tin+$tout) cost=$cost"
Write-Host ""
Write-Host "NI7 Resultado: Batch $segBatch s vs Paralelo $segPar s"
