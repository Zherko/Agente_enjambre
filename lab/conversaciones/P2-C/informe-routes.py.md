# Informe: routes.py
## Resumen
Mapea endpoints REST de usuarios y pagos. Expone tres handlers sobre db que delegan validación y cálculo a módulos externos y centraliza el diccionario ENDPOINTS como documentación.
## Funciones
- route_get_users - consulta todos los usuarios en db
- route_create_user - valida email y crea usuario
- route_create_payment - calcula total y registra pago
## Dependencias
- usuarios.validar_email
- pagos.calcular_total
## Riesgos
- Imports de módulos inexistentes en fixture rompen ejecución
- Sin validación de esquema ni sanitización de entrada
- db.query con SQL crudo facilita inyección
