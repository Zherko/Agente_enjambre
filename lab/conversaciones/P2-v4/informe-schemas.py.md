# Informe: schemas.py
## Resumen
Define esquemas de validación para usuarios y pagos. Contiene diccionarios de reglas por campo y códigos de respuesta HTTP, más una función validadora mínima que solo verifica campos requeridos.
## Funciones
- validate_schema - verifica campos requeridos y retorna errores
## Dependencias
- Ninguna (sin imports de módulos del proyecto)
## Riesgos
- Validación incompleta: ignora tipo, patrón, enum y límites
- PAYMENT_SCHEMA y RESPONSE_SCHEMAS sin uso verificado en código
- Mensajes de error poco detallados para el cliente
