# Informe: middleware.py
## Resumen
Implementa cuatro middlewares: logging, autenticación Bearer, CORS y rate limiting basado en REQUEST_LOG global. Gestionan trazabilidad, seguridad y control de tráfico por ventana temporal.
## Funciones
- logging_middleware - registra método, ruta y timestamp
- auth_middleware - valida token Bearer contra secret
- cors_middleware - añade cabeceras CORS a la respuesta
- rate_limit_middleware - limita peticiones por ruta y ventana
## Dependencias
- Ninguna (solo import time de librería estándar)
## Riesgos
- Secret hardcoded por defecto compromete autenticación
- REQUEST_LOG global sin purga crece indefinidamente
- Rate limit filtra solo por path, ignora IP/usuario
