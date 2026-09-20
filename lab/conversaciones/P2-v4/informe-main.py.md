# Informe: main.py
## Resumen
Orquesta la API: clase API con registro de rutas y dispatcher que encadena logging y autenticación. setup_api registra tres endpoints y delega formato de respuesta a utils.
## Funciones
- API.__init__ - inicializa BD y tabla de rutas
- API.register - registra handler por método y ruta
- API.handle - aplica middlewares y despacha al handler
- setup_api - crea instancia y registra rutas principales
## Dependencias
- routes.route_get_users, route_create_user, route_create_payment
- schemas.USER_SCHEMA, PAYMENT_SCHEMA, validate_schema
- middleware.logging_middleware, auth_middleware, cors_middleware
- utils.format_response
## Riesgos
- validate_schema importado pero nunca usado en handle
- Sin manejo de rutas dinámicas con <id>
- Lambdas en registro dificultan testeo y trazabilidad
