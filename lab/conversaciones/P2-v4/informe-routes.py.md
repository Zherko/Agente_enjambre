# Informe: routes.py
## Resumen
Define endpoints REST para usuarios y pagos. Expone tres handlers que operan sobre BD: listado de usuarios, creación con validación de email y creación de pagos con cálculo de total según moneda.
## Funciones
- route_get_users - consulta y retorna todos los usuarios
- route_create_user - valida email y crea usuario con rol por defecto
- route_create_payment - calcula total y registra pago pendiente
## Dependencias
- usuarios.validar_email
- pagos.calcular_total
## Riesgos
- Imports de módulos inexistentes en P2-api rompen imports
- Sin validación de esquema ni sanitización de datos
- Sin manejo de errores de BD ni de campos faltantes
