# Informe: main.py
## Resumen
Orquesta la API: clase API registra rutas y despacha requests aplicando logging y autenticación previos. setup_api conecta handlers de routes con formateo uniforme de respuestas.
## Funciones
- API.__init__ - inicializa db y tabla de rutas
- API.register - registra handler por método y path
- API.handle - aplica middlewares y despacha al handler
- setup_api - crea instancia API y registra endpoints
## Dependencias
- routes.route_get_users, route_create_user, route_create_payment
- schemas.USER_SCHEMA, PAYMENT_SCHEMA, validate_schema
- middleware.logging_middleware, auth_middleware, cors_middleware
- utils.format_response
## Riesgos
- Autenticación obligatoria bloquea incluso rutas públicas
- validate_schema importado pero nunca usado
- Handlers envueltos en lambda dificultan testeo y trazabilidad
