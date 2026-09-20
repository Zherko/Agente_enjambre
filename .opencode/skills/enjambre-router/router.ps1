# enjambre-router.ps1 — Router híbrido comité 2026-09-20
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

  # Fast-Reject Nivel 1
  $isTrivial = ($Archivos -lt 3 -and $Lineas -lt 100 -and $Riesgo -eq 'bajo')
  if ($isTrivial) {
    return @{ decision='DIRECTO'; score=1.0; umbral=$umbralBase; motivo='fast-reject trivial (<3 arch, <100 lin, riesgo bajo)'; overhead=$overheadBase; nivel=1 }
  }

  # Volumen normalizado 0-10 — v1.1: usa lineas/40 (no tokensEst), corrige subestimacion 3x (lineas*12 subestima vs real 150k)
  # Principio: volumen = trabajo real, no tokens con overhead. 400 lin ~10 puntos.
  $volumenRaw = $Lineas / 40
  $volumen = [math]::Min(10, [math]::Max(0, $volumenRaw))
  # Coupling invertido para score: coupling alto penaliza volumen pero suma en su peso como complejidad
  # Para score: coupling alto = más necesidad de enjambre? No, coupling alto = menos paralelizable, pero más riesgo de error cruzado -> empuja a enjambre solo si riesgo alto
  # Usamos coupling directo (0 bajo acoplado -> 0, 10 muy acoplado ->10) — más acoplado = más score hacia enjambre si necesita revisión cruzada
  # Pero paralelizable ya captura disyunción, así que coupling aquí es "complejidad de dependencias"
  
  $score = $volumen*$pesos.volumen + $Coupling*$pesos.coupling + $Paralelizable*$pesos.paralelizable + $riesgoScore*$pesos.riesgo
  $score = [math]::Round($score,2)

  # Overhead estimado y umbral (v1 comité: base 6.5; dinámico pendiente calibración 30 muestras)
  $overhead = [math]::Min($cap, $overheadBase + $Archivos*$porArchivo)
  # Umbral dinámico deshabilitado en v1: fijado a 6.5 (veredicto comité matiz: antes de 30 muestras OOD, valle por defecto DIRECTO)
  $umbral = [math]::Round($umbralBase,2)

  $decision = ''
  $motivo = ''
  $mode = 1
  if ($score -lt 4) { $decision='DIRECTO'; $mode=1; $motivo="score $score <4 (bajo) -> N=1" }
  elseif ($score -lt $umbral) {
    if ($Paralelizable -ge 8 -and $Coupling -le 4 -and $volumen -ge 4) { $decision='ENJAMBRE_SELECTIVO'; $mode=3; $motivo="valle medio score $score in [4,$umbral) pero paralelizable alto -> N=3" }
    else { $decision='DIRECTO'; $mode=1; $motivo="valle medio score $score < umbral $umbral -> por defecto DIRECTO N=1 (pendiente 30 muestras)" }
  } else { $decision='ENJAMBRE'; $mode=5; $motivo="score $score >= umbral $umbral (overhead $overhead) -> N=5" }

  # Superpower decorator opt-in (veredicto comité 2): solo si >8 arch o >120s est o volumen>=8 y presupuesto>80k
  $superpower=$false
  if ($decision -ne 'DIRECTO' -and ($Archivos -gt 8 -or $volumen -ge 8)) { $superpower=$true; $motivo+=" + superpower" }

  return @{ decision=$decision; mode=$mode; superpower=$superpower; score=$score; umbral=$umbral; overhead=$overhead; volumen=$volumen; motivo=$motivo; nivel=2; pesos=$pesos }
}

# CLI directo
if ($MyInvocation.Line -match 'router\.ps1') {
  # no auto-run
}
