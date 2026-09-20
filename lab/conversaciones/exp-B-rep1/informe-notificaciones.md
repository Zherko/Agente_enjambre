# Informe: notificaciones
## Resumen
Módulo de notificaciones por email y sms con validación de destinatario, envío simple y reintento limitado a tres intentos.
## Funciones
- puede_enviar: Valida usuario activo y canal permitido.
- enviar: Valida destinatario y mensaje antes de enviar.
- reintentar: Incrementa intentos y falla si supera límite.
## Dependencias
- ninguna
## Riesgos
- Mensaje vacío lanza excepción no capturada.
- Sin validación de formato de email/sms.
- Reintento sin backoff ni persistencia.
