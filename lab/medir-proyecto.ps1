# Harness de medición para benchmark de 6 proyectos (C basal + v4)
# Uso: .\medir-proyecto.ps1 -Proyecto P1 -Rama C
param(
  [ValidateSet('P1','P2','P3','P4','P5','P6')][string]$Proyecto,
  [ValidateSet('C','v4')][string]$Rama
)

$Base = 'C:\Proyectos\Skills\Enjambre'
$Exe = (Get-Command opencode -ErrorAction SilentlyContinue).Source
if (-not $Exe) { $Exe = 'opencode' }
$Modelo = 'opencode-go/muse-spark-1.2-contributor'
$Out = "$Base\lab\conversaciones\$Proyecto-$Rama"
New-Item -ItemType Directory -Force -Path $Out | Out-Null

# Prompts por proyecto (verbatim de PROYECTO.md)
$prompts = @{
  'P1' = "Lee los 4 archivos de $Base\lab\fixture\P1-pagos\ (pagos.py, usuarios.py, inventario.py, notificaciones.py). Para cada uno, extrae los nombres de las funciones definidas y retorna una lista JSON con este formato exacto: {`"pagos`": [`"calcular_total`", `"validar_tarjeta`", `"reembolsar`"], `"usuarios`": [`"validar_email`", `"crear_usuario`", `"desactivar`"], `"inventario`": [`"hay_stock`", `"reservar`", `"reponer`"], `"notificaciones`": [`"puede_enviar`", `"enviar`", `"reintentar`"]}. Responde SOLO con el JSON, sin explicaciones."
  'P2' = "Analiza los 5 archivos de $Base\lab\fixture\P2-api\ (routes.py, schemas.py, middleware.py, utils.py, main.py). Para cada archivo, escribe un informe en $Out\ con el nombre informe-<nombre>.py.md. Cada informe tiene estos encabezados exactos: '# Informe: <nombre>.py', '## Resumen' (max 60 palabras), '## Funciones' (lista: nombre - que hace), '## Dependencias' (imports de otros modulos del proyecto), '## Riesgos' (max 3 bullet points). Max 120 palabras por informe. Son 5 informes."
  'P3' = "Analiza la pipeline de datos en $Base\lab\fixture\P3-pipeline\ (config.py, extract.py, transform.py, validate.py, load.py, orchestrate.py). Redacta un informe completo en $Out\informe-pipeline.md con estos encabezados: '# Informe: Pipeline de Datos', '## Resumen' (max 80 palabras), '## Flujo de Datos' (paso a paso), '## Dependencias entre Modulos' (que archivo importa de cual), '## Funciones Principales' (nombre: firma, max 1 linea), '## Riesgos' (max 5 bullet points), '## Propuesta de Tests' (min 4 casos con entrada/esperada). Max 400 palabras total."
  'P4' = "Revisa la arquitectura de microservicios en $Base\lab\fixture\P4-microservices\ (auth.py, users.py, orders.py, inventory.py, gateway.py, config.py, events.py, utils.py). Redacta un informe de code review en $Out\informe-review.md: '# Review: Microservicios', '## Resumen General' (max 80 palabras), '## Por Servicio' (auth, users, orders, inventory: resumen de 2-3 lineas), '## Problemas Encontrados' (min 5, formato [SERVICIO] descripcion), '## Acoplamiento' (que servicios dependen de cuales), '## Recomendaciones' (min 4 acciones concretas). Max 500 palabras."
  'P5' = "Analiza el monolito legacy en $Base\lab\fixture\P5-legacy\ (10 archivos: models.py, views.py, services.py, db.py, auth.py, utils.py, config.py, notifications.py, reporting.py, main.py). Disena un plan de refactoring para extraer cada servicio a un modulo independiente. Redacta el plan en $Out\informe-refactor.md: '# Plan de Refactoring: Legacy Monolith', '## Resumen' (max 80 palabras), '## Servicios Actuales' (lista los 6+ dominios con 2-3 funciones clave), '## Extraccion Propuesta' (para cada servicio: que archivos crear, que funciones mover), '## Orden de Extraccion' (secuencia recomendada con justificacion), '## Riesgos' (min 5), '## Criterios de Exito' (min 4). Max 700 palabras."
  'P6' = "Analiza los 12 microservicios de $Base\lab\fixture\P6-complex\ (auth.py, users.py, orders.py, inventory.py, payments.py, shipping.py, notifications.py, analytics.py, config.py, events.py, gateway.py, utils.py, 1461 lineas). Redacta un informe de arquitectura en $Out\informe-p6.md: '# Review P6: 12 servicios', '## Resumen' (max 100 palabras), '## Servicios' (12 x 2 lineas: que hace), '## Dependencias' (grafo imports), '## Riesgos' (min 6), '## Plan de escalado' (min 4 acciones), '## Tests' (min 5 casos). Max 800 palabras."
}

$msg = $prompts[$Proyecto]
Write-Host "=== $Proyecto-$Rama ===" -ForegroundColor Cyan

$t0 = Get-Date
& $Exe run --dir $Base --model $Modelo --pure --format json $msg 2>$null | Set-Content "$Out\raw.jsonl" -Encoding UTF8
$t1 = Get-Date
$seg = [math]::Round(($t1 - $t0).TotalSeconds, 1)

$tin = 0; $tout = 0
foreach ($line in (Get-Content "$Out\raw.jsonl")) {
  if ([string]::IsNullOrWhiteSpace($line)) { continue }
  try { $ev = $line | ConvertFrom-Json } catch { continue }
  if ($ev.type -eq 'step_finish' -and $ev.part.tokens) { $tin += $ev.part.tokens.input; $tout += $ev.part.tokens.output }
}

Write-Host "TIEMPO=${seg}s TOKENS_IN=$tin TOKENS_OUT=$tout TOKENS_TOT=$($tin+$tout)"
