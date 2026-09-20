# Informe: notificaciones
## Resumen
Módulo de envío de notificaciones por email y sms con validación de usuario activo y canal. Gestiona intentos y reintentos limitados a tres.
## Funciones
- puede_enviar: valida usuario activo y canal permitido.
- enviar: envía mensaje si válido, o retorna error.
- reintentar: incrementa intentos y controla límite de reintentos.
## Dependencias
- ninguna
## Riesgos
- mensaje vacío lanza ValueError no capturado por llamante.
- validación de canal limitada a tupla estática sin normalización.
- reintentar no valida estructura de envio_previo.
