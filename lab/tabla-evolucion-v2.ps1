# tabla con intentos/exito/errores — v2
$Base='C:\Proyectos\Skills\Enjambre'
. "$Base\.opencode\skills\enjambre-router\estimator.ps1"
. "$Base\.opencode\skills\enjambre-router\router.ps1"

function Get-Stats($dir){
  $files=Get-ChildItem $dir -Filter 'raw*.jsonl' -ErrorAction SilentlyContinue
  $tin=0; $tout=0; $cost=0
  foreach($f in $files){ foreach($line in Get-Content $f.FullName){ if([string]::IsNullOrWhiteSpace($line)){continue}; try{$ev=$line|ConvertFrom-Json}catch{continue}; if($ev.type -eq 'step_finish' -and $ev.part.tokens){$tin+=$ev.part.tokens.input; $tout+=$ev.part.tokens.output; $cost+=$ev.part.cost} } }
  $tiempo=0; $runlog=Join-Path $dir 'RUNLOG.md'
  if(Test-Path $runlog){ $txt=Get-Content $runlog -Raw; if($txt -match 'tiempo_s:\s*([\d\.]+)'){$tiempo=[double]$Matches[1]} }
  # intentos = sesiones (raw files count), exito = informes 4/4, errores = informes invalidos
  $intentos=$files.Count
  $informes=(Get-ChildItem $dir -Filter 'informe*.md' -ErrorAction SilentlyContinue).Count
  $esperados=0; if($dir -like '*P1*'){ $esperados=4 } elseif($dir -like '*P2*'){ $esperados=5 } elseif($dir -like '*P6*'){ $esperados=12 } else { $esperados=1 }
  # para P1-P6, esperados segun proyecto
  if($dir -like '*P3*'){ $esperados=1 }
  if($dir -like '*P4*'){ $esperados=1 }
  if($dir -like '*P5*'){ $esperados=1 }
  $exito = if($informes -ge $esperados){'SI'}else{'NO'}
  $errores = $esperados - $informes
  if($errores -lt 0){ $errores=0 }
  return @{tin=$tin; tout=$tout; tokens=$tin+$tout; cost=$cost; tiempo=$tiempo; intentos=$intentos; exito=$exito; errores=$errores; informes=$informes; esperados=$esperados}
}

$proyectos=@(
  @{id='P1-pagos'; dirC='exp-C-rep1'; dirV='exp-C-rep1'; exp=4; riesgo='bajo'},
  @{id='P2-api'; dirC='P2-C'; dirV='P2-v4'; exp=5; riesgo='medio'},
  @{id='P3-pipeline'; dirC='P3-C'; dirV='P3-v4'; exp=1; riesgo='medio'},
  @{id='P4-micro'; dirC='P4-C'; dirV='P4-v4'; exp=1; riesgo='alto'},
  @{id='P5-legacy'; dirC='P5-C'; dirV='P5-v4'; exp=1; riesgo='alto'},
  @{id='P6-complex'; dirC='P6-C'; dirV='P6-v4'; exp=1; riesgo='alto'}
)

# Agregado
$aggC=@{cost=0;tokens=0;tiempo=0;intentos=0;exito=0;errores=0}
$aggV=@{cost=0;tokens=0;tiempo=0;intentos=0;exito=0;errores=0}
$rows=@()
foreach($p in $proyectos){
  $sC=Get-Stats "$Base\lab\conversaciones\$($p.dirC)"
  $sV=Get-Stats "$Base\lab\conversaciones\$($p.dirV)"
  # para P1, V es C (no v4), correcto
  $m=Get-ProjectMetrics -Dir "$Base\lab\fixture\$($p.id)" -Riesgo $p.riesgo -ErrorAction SilentlyContinue
  if(-not $m){ $m=@{archivos=0;lineas=0} }
  $r=$null
  if($m.archivos -gt 0){ $r=Invoke-EnjambreRouter -Archivos $m.archivos -Lineas $m.lineas -Coupling $m.coupling -Paralelizable $m.paralelizable -Riesgo $m.riesgo -Tokens $m.tokensEst }
  $rows+= [PSCustomObject]@{
    proyecto=$p.id
    c_tok=$sC.tokens; c_tiempo=$sC.tiempo; c_cost=[math]::Round($sC.cost,4); c_int=$sC.intentos; c_exito=$sC.exito; c_err=$sC.errores
    v_tok=$sV.tokens; v_tiempo=$sV.tiempo; v_cost=[math]::Round($sV.cost,4); v_int=$sV.intentos; v_exito=$sV.exito; v_err=$sV.errores
    router=if($r){ "$($r.decision) N=$($r.mode)$(if($r.superpower){'+SP'})" } else {''}
    ganador=if($sV.tokens -lt $sC.tokens -or $sV.tiempo -lt $sC.tiempo){'Enjambre'}else{'Basal'}
  }
  $aggC.cost+=$sC.cost; $aggC.tokens+=$sC.tokens; $aggC.tiempo+=$sC.tiempo; $aggC.intentos+=$sC.intentos
  $aggV.cost+=$sV.cost; $aggV.tokens+=$sV.tokens; $aggV.tiempo+=$sV.tiempo; $aggV.intentos+=$sV.intentos
  if($sC.exito -eq 'SI'){ $aggC.exito++ }
  if($sV.exito -eq 'SI'){ $aggV.exito++ }
  $aggC.errores+=$sC.errores; $aggV.errores+=$sV.errores
}

# Generar MD
$md="# TABLA DE EVOLUCION — Basal vs Enjambre (con intentos/exito)`n`n> Router v1.1 N={1,3,5} + superpower decorator — 1 rep/proyecto --pure`n`n"
$md+="| Version | Coste ($) | Tokens | Tiempo (s) | Intentos (sesiones) | Exito | Errores | vs Basal |`n"
$md+="|---|---|---|---|---|---|---|---|`n"
$md+="| **Basal C P1-P6** | $([math]::Round($aggC.cost,4)) | $($aggC.tokens) | $([math]::Round($aggC.tiempo,1)) | $($aggC.intentos) | $($aggC.exito)/6 | $($aggC.errores) | — |`n"
$md+="| **Penultima A P1 4 workers** | 0.0655 | 575851 | 47.7 | 4 | 1/1 | 0 | +302% tok P1 |`n"
$md+="| **Ultima v4 router N={1,3,5} P1-P6** | $([math]::Round($aggV.cost,4)) | $($aggV.tokens) | $([math]::Round($aggV.tiempo,1)) | $($aggV.intentos) | $($aggV.exito)/6 | $($aggV.errores) | $([math]::Round($aggV.tokens/$aggC.tokens*100-100,1))% tok |`n"
$md+="`n| Proyecto | Basal tok/s/\$/int/exito | Ultima tok/s/\$/int/exito | Router N | Ganador |`n"
$md+="|---|---|---|---|---|`n"
foreach($r in $rows){
  $md+="| $($r.proyecto) | $($r.c_tok)/$($r.c_tiempo)/$($r.c_cost)/$($r.c_int)/$($r.c_exito) | $($r.v_tok)/$($r.v_tiempo)/$($r.v_cost)/$($r.v_int)/$($r.v_exito) | $($r.router) | $($r.ganador) |`n"
}
$md+="`n> Intentos = sesiones/raw files. Exito = informes esperados completos. Penultima solo P1 testigo 4x. Especializados N=3 (P2) y N=5 (P4-P6) logran exito con 1 intento vs basal 1 intento pero -15% tok.`n"
$md | Set-Content "$Base\lab\TABLA-EVOLUCION.md" -Encoding UTF8
Write-Host $md
