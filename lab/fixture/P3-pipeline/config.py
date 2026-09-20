# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P3-Pipeline: Config
# Version: v1.0-fija

PIPELINE_CONFIG = {
    "source": {"type": "csv", "delimiter": ",", "encoding": "utf-8"},
    "transforms": ["clean", "validate", "aggregate"],
    "sink": {"type": "json", "indent": 2},
    "batch_size": 1000,
    "max_retries": 3,
}

FIELD_TYPES = {
    "id": "integer",
    "nombre": "string",
    "email": "string",
    "monto": "float",
    "fecha": "date",
    "estado": "string",
}

REQUIRED_FIELDS = ["id", "nombre", "email", "monto"]
