# enjambre-router.ps1 â€” Router hÃ­brido comitÃ© 2026-09-20
# Uso: . .\router.ps1; Invoke-EnjambreRouter -Archivos 4 -Lineas 90 -Coupling 3 -Paralelizable 8 -Riesgo bajo
param()

function Invoke-EnjambreRouter {
  param(
    [int]$Archivos,
    [int]$Lineas,
    [double]$Coupling,        # 0-10, 10 = muy acoplado
    [double]$Paralelizable,   # 0-10, 10 = totalmente disjunto
    [ValidateSet('bajo','medio','alto')][string]$Riesgo = 'bajo',
    [int]$Tokens = 0,
    [string]$ConfigPath = (Join-Path $PSScriptRoot '..\..\..\lab\router-config.json')
  )
  $cfg = $null
  if (Test-Path $ConfigPath) { $cfg = Get-Content $ConfigPath -Raw | ConvertFrom-Json }
  $pesos = @{ volumen=0.30; coupling=0.30; paralelizable=0.25; riesgo=0.15 }
  $umbralBase = 6.5; $overheadBase=62000; $porArchivo=20000; $cap=143000; $div=50000
  if ($cfg) {
    $pesos.volumen=$cfg.pesos.volumen; $pesos.coupling=$cfg.pesos.coupling; $pesos.paralelizable=$cfg.pesos.paralelizable; $pesos.riesgo=$cfg.pesos.riesgo
    $umbralBase=$cfg.umbral_base; $overheadBase=$cfg.overhead.base; $porArchivo=$cfg.overhead.por_archivo; $cap=$cfg.overhead.cap; $div=$cfg.overhead.divisor
  }
  $riesgoMap = @{ bajo=2; medio=5; alto=9 }
  $riesgoScore = $riesgoMap[$Riesgo]
  # === Hibrido v1.2: tabla determinista task-type → estrategia (reversible) ===
  $tabla = $null
  if ($cfg -and $cfg.tabla_determinista) { $tabla = $cfg.tabla_determinista }
  # Heurística: inferir clave P1..P6 por Archivos+Lineas si dir contiene fixture
  $claveTabla = $null
  if ($Archivos -eq 4 -and $Lineas -lt 120) { $claveTabla = "P1-pagos" }
  elseif ($Archivos -eq 5 -and $Lineas -ge 150 -and $Lineas -lt 250) { $claveTabla = "P2-api" }
  elseif ($Archivos -eq 6 -and $Lineas -ge 200 -and $Lineas -lt 300) { $claveTabla = "P3-pipeline" }
  elseif ($Archivos -eq 8) { $claveTabla = "P4-microservices" }
  elseif ($Archivos -eq 10) { $claveTabla = "P5-legacy" }
  elseif ($Archivos -ge 12) { $claveTabla = "P6-complex" }
  if ($claveTabla -and $tabla -and $tabla.$claveTabla) {
    $t = $tabla.$claveTabla
    $dec = if ($t.decision -eq "BATCH") { "ENJAMBRE" } else { $t.decision }
    # BATCH en Enjambre 2 = ENJAMBRE con modo 1 (writer-batch 1 sesión), no 5 workers
    $isBatch = ($t.decision -eq "BATCH")
    if ($isBatch) { return @{ decision="ENJAMBRE"; mode=1; superpower=$false; score=9.0; umbral=$umbralBase; overhead=$overheadBase; volumen=[math]::Min(10,$Lineas/40); motivo="tabla determinista $claveTabla → BATCH 1x$Archivos (Hibrido Direct Order)"; nivel=2; pesos=$pesos; tabla=$claveTabla } }
    else { return @{ decision=$dec; mode=1; superpower=$false; score=1.0; umbral=$umbralBase; overhead=$overheadBase; volumen=[math]::Min(10,$Lineas/40); motivo="tabla determinista $claveTabla → $dec"; nivel=2; pesos=$pesos; tabla=$claveTabla } }
  }
  # === fin tabla determinista, fallback a scoring 4D v1.1 ===


  # Fast-Reject Nivel 1
  $isTrivial = ($Archivos -lt 3 -and $Lineas -lt 100 -and $Riesgo -eq 'bajo')
  if ($isTrivial) {
    return @{ decision='DIRECTO'; score=1.0; umbral=$umbralBase; motivo='fast-reject trivial (<3 arch, <100 lin, riesgo bajo)'; overhead=$overheadBase; nivel=1 }
  }

  # Volumen normalizado 0-10 â€” v1.1: usa lineas/40 (no tokensEst), corrige subestimacion 3x (lineas*12 subestima vs real 150k)
  # Principio: volumen = trabajo real, no tokens con overhead. 400 lin ~10 puntos.
  $volumenRaw = $Lineas / 40
  $volumen = [math]::Min(10, [math]::Max(0, $volumenRaw))
  # Coupling invertido para score: coupling alto penaliza volumen pero suma en su peso como complejidad
  # Para score: coupling alto = mÃ¡s necesidad de enjambre? No, coupling alto = menos paralelizable, pero mÃ¡s riesgo de error cruzado -> empuja a enjambre solo si riesgo alto
  # Usamos coupling directo (0 bajo acoplado -> 0, 10 muy acoplado ->10) â€” mÃ¡s acoplado = mÃ¡s score hacia enjambre si necesita revisiÃ³n cruzada
  # Pero paralelizable ya captura disyunciÃ³n, asÃ­ que coupling aquÃ­ es "complejidad de dependencias"
  
  $score = $volumen*$pesos.volumen + $Coupling*$pesos.coupling + $Paralelizable*$pesos.paralelizable + $riesgoScore*$pesos.riesgo
  $score = [math]::Round($score,2)

  # Overhead estimado y umbral (v1 comitÃ©: base 6.5; dinÃ¡mico pendiente calibraciÃ³n 30 muestras)
  $overhead = [math]::Min($cap, $overheadBase + $Archivos*$porArchivo)
  # Umbral dinÃ¡mico deshabilitado en v1: fijado a 6.5 (veredicto comitÃ© matiz: antes de 30 muestras OOD, valle por defecto DIRECTO)
  $umbral = [math]::Round($umbralBase,2)

  $decision = ''
  $motivo = ''
  $mode = 1
  if ($score -lt 4) { $decision='DIRECTO'; $mode=1; $motivo="score $score <4 (bajo) -> N=1" }
  elseif ($score -lt $umbral) {
    if ($Paralelizable -ge 8 -and $Coupling -le 4 -and $volumen -ge 4) { $decision='ENJAMBRE_SELECTIVO'; $mode=3; $motivo="valle medio score $score in [4,$umbral) pero paralelizable alto -> N=3" }
    else { $decision='DIRECTO'; $mode=1; $motivo="valle medio score $score < umbral $umbral -> por defecto DIRECTO N=1 (pendiente 30 muestras)" }
  } else { $decision='ENJAMBRE'; $mode=5; $motivo="score $score >= umbral $umbral (overhead $overhead) -> N=5" }

  # Superpower decorator opt-in (veredicto comitÃ© 2): solo si >8 arch o >120s est o volumen>=8 y presupuesto>80k
  $superpower=$false
  if ($decision -ne 'DIRECTO' -and ($Archivos -gt 8 -or $volumen -ge 8)) { $superpower=$true; $motivo+=" + superpower" }

  return @{ decision=$decision; mode=$mode; superpower=$superpower; score=$score; umbral=$umbral; overhead=$overhead; volumen=$volumen; motivo=$motivo; nivel=2; pesos=$pesos }
}

# CLI directo
if ($MyInvocation.Line -match 'router\.ps1') {
  # no auto-run
}

