# Informe: notifications

## Resumen
Servicio de notificaciones del fixture. 17 operaciones (`notifications_op1`–`notifications_op17`) idénticas, sin envío real (email, push, SMS) ni plantillas.

## Funciones
17 funciones: `notifications_op1`–`notifications_op17`. Firma `(data: Dict) -> Dict`. Emiten `notifications.N` tras validar.

## Dependencias
`config`, `utils`, `events`, `auth`, `typing (Dict, List)`. Depende del bus `events` para supuesta entrega.

## Riesgos
Sin integración real de canales, duplicación, acoplamiento a `events` sin garantía de entrega, `import auth` sin uso, validación vía `globals()` poco robusta.
