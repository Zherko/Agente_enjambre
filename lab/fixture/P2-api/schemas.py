# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P2-API: Schemas
# Version: v1.0-fija

USER_SCHEMA = {
    "nombre": {"type": "string", "required": True, "max_length": 100},
    "email": {"type": "string", "required": True, "pattern": "email"},
    "rol": {"type": "string", "required": False, "default": "lector", "enum": ["admin", "editor", "lector"]},
}

PAYMENT_SCHEMA = {
    "base": {"type": "number", "required": True, "min": 0.01},
    "moneda": {"type": "string", "required": False, "default": "EUR", "enum": ["EUR", "USD"]},
}

RESPONSE_SCHEMAS = {
    200: {"description": "Exito"},
    201: {"description": "Creado"},
    400: {"description": "Error de validacion", "fields": {"error": "string"}},
    404: {"description": "No encontrado"},
    500: {"description": "Error interno"},
}


def validate_schema(data, schema):
    errors = []
    for field, rules in schema.items():
        if rules.get("required") and field not in data:
            errors.append(f"campo {field} requerido")
    return len(errors) == 0, errors
