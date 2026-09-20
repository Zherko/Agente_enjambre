# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P3-Pipeline: Extract
# Version: v1.0-fija

import csv
import io


def extract_csv(filepath, delimiter=",", encoding="utf-8"):
    records = []
    with open(filepath, "r", encoding=encoding) as f:
        reader = csv.DictReader(f, delimiter=delimiter)
        for row in reader:
            records.append(row)
    return records


def extract_json_list(data):
    if isinstance(data, list):
        return data
    return []


def extract_from_string(csv_string, delimiter=","):
    reader = csv.DictReader(io.StringIO(csv_string), delimiter=delimiter)
    return list(reader)


def validate_extract(records, required_fields):
    valid = []
    invalid = []
    for i, rec in enumerate(records):
        missing = [f for f in required_fields if f not in rec or not rec[f]]
        if missing:
            invalid.append({"index": i, "record": rec, "missing": missing})
        else:
            valid.append(rec)
    return valid, invalid
