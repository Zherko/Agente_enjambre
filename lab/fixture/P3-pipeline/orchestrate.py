# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P3-Pipeline: Orchestrate
# Version: v1.0-fija

from config import PIPELINE_CONFIG
from extract import extract_csv, validate_extract
from transform import clean_record, cast_types, filter_valid
from load import load_to_json
from validate import validate_batch, summary_stats


def run_pipeline(input_path, output_path):
    config = PIPELINE_CONFIG
    records = extract_csv(input_path, config["source"]["delimiter"])
    valid, invalid_raw = validate_extract(records, ["id", "nombre", "email", "monto"])
    cleaned = [clean_record(r) for r in valid]
    typed = [cast_types(r, FIELD_TYPES) for r in cleaned]
    filtered = filter_valid(typed, FIELD_TYPES)
    validation = validate_batch(filtered)
    loaded = load_to_json(validation["valid"], output_path)
    stats = summary_stats(validation["valid"])
    return {
        "input_records": len(records),
        "after_extract": len(valid),
        "after_transform": len(filtered),
        "after_validate": len(validation["valid"]),
        "loaded": loaded,
        "rejected": len(invalid_raw) + len(validation["invalid"]),
        "stats": stats,
    }

from config import FIELD_TYPES
