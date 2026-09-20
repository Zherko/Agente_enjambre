# Informe: notificaciones

## Resumen
Módulo de envío de notificaciones por email y SMS con control de estado de usuario y reintentos limitados a tres.

## Funciones
- `puede_enviar(usuario, canal)`: verifica usuario activo y canal válido.
- `enviar(usuario, canal, mensaje)`: envía si es válido, valida mensaje no vacío.
- `reintentar(envio_previo)`: incrementa intentos hasta `MAX_REINTENTOS`.

## Dependencias
Sin imports externos. Usa constantes `CANALES` y `MAX_REINTENTOS` y campo `usuario.activo`.

## Riesgos
Sin integración real de envío ni manejo de errores de red. Validación de mensaje solo por vacío, sin límite de tamaño. Reintentos sin backoff ni registro.
