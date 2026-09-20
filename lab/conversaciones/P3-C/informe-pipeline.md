# Informe: Pipeline de Datos

## Resumen
Pipeline ETL batch Python (6 módulos, ~180 líneas) que extrae CSV, limpia y castea tipos, valida reglas de negocio y persiste a JSON. Orquestado por `orchestrate.py` con config centralizada. Sin dependencias externas, pero con validación duplicada, acoplamiento frágil y dos bugs bloqueantes que impiden uso en producción.

## Flujo de Datos
1. **Extract** (`extract_csv`): lee CSV con `DictReader` según `PIPELINE_CONFIG.source` y retorna lista de dicts.
2. **Transform** (`clean_record` → `cast_types` → `filter_valid`): normaliza strings, castea a `int`/`float` según `FIELD_TYPES` y filtra emails con regex.
3. **Validate** (`validate_batch`): verifica `REQUIRED_FIELDS`, `monto>=0` y formato email; separa válidos/inválidos.
4. **Load** (`load_to_json` + `summary_stats`): vuelca válidos a JSON y calcula total, promedio y emails únicos. `run_pipeline` retorna contadores por etapa.

## Dependencias entre Modulos
- `config.py`: ninguna interna; define constantes.
- `extract.py`: `csv`, `io` únicamente.
- `transform.py`: `re` únicamente.
- `validate.py`: `from config import FIELD_TYPES, REQUIRED_FIELDS`.
- `load.py`: `json` únicamente (bug: usa `csv` sin importar).
- `orchestrate.py`: `from config import PIPELINE_CONFIG, FIELD_TYPES`; `from extract import extract_csv, validate_extract`; `from transform import clean_record, cast_types, filter_valid`; `from load import load_to_json`; `from validate import validate_batch, summary_stats`.

## Funciones Principales
- `extract_csv(filepath, delimiter=",", encoding="utf-8") -> list[dict]`
- `extract_from_string(csv_string, delimiter=",") -> list[dict]`
- `validate_extract(records, required_fields) -> (valid, invalid)`
- `clean_record(record) -> dict`
- `cast_types(record, field_types) -> dict`
- `validate_email_field(record) -> bool`
- `filter_valid(records, field_types) -> list`
- `validate_record(record) -> (bool, errors)`
- `validate_batch(records) -> {valid, invalid}`
- `summary_stats(records) -> dict`
- `load_to_json(records, filepath, indent=2) -> int`
- `load_to_csv(records, filepath, fieldnames=None) -> int`
- `run_pipeline(input_path, output_path) -> dict`

## Riesgos
- `load.py:20` usa `csv.DictWriter` sin `import csv` → `NameError` en `load_to_csv`.
- `orchestrate.py:32` importa `FIELD_TYPES` después de usarlo; frágil y falla en linters.
- `cast_types` sin `try/except` → `ValueError` con `monto` no numérico aborta pipeline.
- `filter_valid` ignora parámetro `field_types`; firma engañosa.
- `summary_stats` hace `float(r["monto"])` sin validar → `ValueError` si monto corrupto.

## Propuesta de Tests
1. **CSV vacío**: `extract_from_string("id,nombre,email,monto\n")` → `[]`, `valid=0`.
2. **Casteo y limpieza**: `clean_record({"email":" A@B.COM "})` + `cast_types({"id":"1","monto":"10.5"}, FIELD_TYPES)` → `email="a@b.com"`, `id=1`, `monto=10.5`.
3. **Monto negativo**: `validate_record({"id":1,"nombre":"Ana","email":"a@b.com","monto":-5})` → `False`, error "monto no puede ser negativo".
4. **Load round-trip**: `load_to_json([{"id":1}], tmp)` → archivo igual a entrada, retorna `1`.
5. **E2E email inválido**: CSV con 1 email válido y 1 `bad-email` → `run_pipeline` retorna `after_transform=1`, `rejected=1`, `loaded=1`.
