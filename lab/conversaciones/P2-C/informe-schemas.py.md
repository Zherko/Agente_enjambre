# Informe: schemas.py
## Resumen
Define esquemas declarativos para usuario, pago y respuestas HTTP. Incluye validador mínimo que verifica solo campos requeridos, dejando el resto de reglas sin aplicar.
## Funciones
- validate_schema - valida campos requeridos y retorna errores
## Dependencias
- Ninguna (solo estructuras internas, sin imports de proyecto)
## Riesgos
- Validador incompleto ignora type, enum, pattern y límites
- Sin sanitización ni validación de formato email
- RESPONSE_SCHEMAS no se usa en validación real
