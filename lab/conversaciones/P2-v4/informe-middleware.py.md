# Informe: middleware.py
## Resumen
Implementa middlewares transversales: logging de peticiones, autenticación Bearer, cabeceras CORS y limitación por tasa. Usa lista en memoria REQUEST_LOG como almacén temporal de trazas.
## Funciones
- logging_middleware - registra método, ruta y timestamp
- auth_middleware - valida token Bearer contra secreto
- cors_middleware - añade cabeceras CORS a la respuesta
- rate_limit_middleware - limita peticiones por ventana temporal
## Dependencias
- Ninguna (solo módulo estándar time)
## Riesgos
- REQUEST_LOG en memoria crece sin límite y no es thread-safe
- Secreto hardcodeado por defecto ("secret123")
- Rate limit recalcula lista completa en cada petición
