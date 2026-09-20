# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P3-Pipeline: Transform
# Version: v1.0-fija

import re

EMAIL_RE = re.compile(r"^[^@]+@[^@]+\.[^@]+$")


def clean_string(value):
    if not isinstance(value, str):
        return value
    return value.strip().lower()


def clean_record(record):
    cleaned = {}
    for k, v in record.items():
        cleaned[k] = clean_string(v) if isinstance(v, str) else v
    return cleaned


def validate_email_field(record):
    email = record.get("email", "")
    return bool(EMAIL_RE.match(email))


def cast_types(record, field_types):
    casted = {}
    for field, rtype in field_types.items():
        val = record.get(field)
        if val is None:
            casted[field] = None
            continue
        if rtype == "integer":
            casted[field] = int(val)
        elif rtype == "float":
            casted[field] = round(float(val), 2)
        elif rtype == "string":
            casted[field] = str(val)
        else:
            casted[field] = val
    return casted


def filter_valid(records, field_types):
    return [r for r in records if validate_email_field(r)]
