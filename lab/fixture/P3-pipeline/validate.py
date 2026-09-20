# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P3-Pipeline: Validate
# Version: v1.0-fija

from config import FIELD_TYPES, REQUIRED_FIELDS


def validate_record(record):
    errors = []
    for field in REQUIRED_FIELDS:
        if field not in record or record[field] is None:
            errors.append(f"campo {field} faltante")
    if "monto" in record:
        try:
            monto = float(record["monto"])
            if monto < 0:
                errors.append("monto no puede ser negativo")
        except (ValueError, TypeError):
            errors.append("monto debe ser numerico")
    if "email" in record and record["email"]:
        import re
        if not re.match(r"^[^@]+@[^@]+\.[^@]+$", record["email"]):
            errors.append("email formato invalido")
    return len(errors) == 0, errors


def validate_batch(records):
    results = {"valid": [], "invalid": []}
    for i, rec in enumerate(records):
        ok, errs = validate_record(rec)
        if ok:
            results["valid"].append(rec)
        else:
            results["invalid"].append({"index": i, "errors": errs})
    return results


def summary_stats(records):
    total = len(records)
    montos = [float(r.get("monto", 0)) for r in records if r.get("monto")]
    return {
        "total_registros": total,
        "monto_total": round(sum(montos), 2),
        "monto_promedio": round(sum(montos) / max(len(montos), 1), 2),
        "emails_unicos": len(set(r.get("email", "") for r in records)),
    }
