# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P3-Pipeline: Load
# Version: v1.0-fija

import json


def load_to_json(records, filepath, indent=2):
    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(records, f, indent=indent, ensure_ascii=False)
    return len(records)


def load_to_csv(records, filepath, fieldnames=None):
    if not records:
        return 0
    if fieldnames is None:
        fieldnames = list(records[0].keys())
    with open(filepath, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(records)
    return len(records)


def append_record(filepath, record):
    existing = []
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            existing = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        pass
    existing.append(record)
    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(existing, f, indent=2, ensure_ascii=False)
    return len(existing)
