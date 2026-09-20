# Informe: Pipeline de Datos

## Resumen
Pipeline ETL batch CSV→JSON de 6 módulos. Extrae con `DictReader` (`extract.py:9`), normaliza y castea según `FIELD_TYPES` (`config.py:13`), filtra emails, valida negocio (`validate.py:8`) y persiste a JSON (`load.py:8`). `run_pipeline` (`orchestrate.py:12`) orquesta y retorna contadores. En memoria, sin streaming ni reintentos.

## Flujo de Datos
1. `run_pipeline` lee `PIPELINE_CONFIG` (`config.py:5`) — delimiter y encoding.
2. `extract_csv` abre CSV → `list[dict]`; `validate_extract` (`extract.py:29`) separa por `REQUIRED_FIELDS`.
3. `clean_record` (`transform.py:16`) normaliza con `clean_string` (`strip().lower()`).
4. `cast_types` (`transform.py:28`) convierte `id→int`, `monto→float` redondeado.
5. `filter_valid` (`transform.py:46`) descarta email inválido vía `validate_email_field`.
6. `validate_batch`→`validate_record` (`validate.py:27,8`) valida monto≥0, numérico y email.
7. `load_to_json` (`load.py:8`) escribe válidos; `summary_stats` (`validate.py:38`) agrega totales y promedios.

## Dependencias entre Modulos
- `config.py`: sin imports; provee `PIPELINE_CONFIG`, `FIELD_TYPES`, `REQUIRED_FIELDS`.
- `extract.py`: `csv`, `io`; no importa `config` (recibe campos por parámetro).
- `transform.py`: `re`; independiente.
- `validate.py:5`: `from config import FIELD_TYPES, REQUIRED_FIELDS`.
- `load.py:5`: `import json` (usa `csv` en `load.py:20` sin importar).
- `orchestrate.py:5-9,32`: importa `config`, `extract`, `transform`, `load`, `validate`; raíz del DAG.

## Funciones Principales
- `extract_csv(filepath, delimiter=",", encoding="utf-8") -> list[dict]`: lee CSV.
- `extract_json_list(data) -> list`: retorna lista o [].
- `extract_from_string(csv_string, delimiter=",") -> list[dict]`: parsea string CSV.
- `validate_extract(records, required_fields) -> tuple`: separa por faltantes.
- `clean_string(value) -> str|any`: strip+lower si string.
- `clean_record(record) -> dict`: normaliza strings.
- `validate_email_field(record) -> bool`: regex email.
- `cast_types(record, field_types) -> dict`: castea por FIELD_TYPES.
- `filter_valid(records, field_types) -> list`: filtra email válido.
- `validate_record(record) -> tuple[bool, errors]`: valida requeridos/monto/email.
- `validate_batch(records) -> dict{valid,invalid}`: valida lote.
- `summary_stats(records) -> dict`: total, monto_total, promedio, emails_unicos.
- `load_to_json(records, filepath, indent=2) -> int`: escribe JSON.
- `load_to_csv(records, filepath, fieldnames=None) -> int`: escribe CSV (bug import).
- `append_record(filepath, record) -> int`: append a JSON.
- `run_pipeline(input_path, output_path) -> dict`: orquesta ETL.

## Riesgos
- `load.py:20` `csv.DictWriter` sin `import csv` → `NameError` en `load_to_csv`.
- `orchestrate.py:32` importa `FIELD_TYPES` al final → binding frágil.
- Validación duplicada: email en `filter_valid` y `validate_record`; requeridos en `validate_extract` vs `validate_batch`.
- `cast_types` sin `try/except` → `ValueError` aborta lote; `max_retries`/`batch_size` nunca usados.
- Todo en memoria, ignora `batch_size`; sin manejo encoding/delimiter ni campo `fecha`.

## Propuesta de Tests
1. **Happy path**: CSV `1,Ana,ana@test.com,100.5` → `run_pipeline` carga 1, `monto=100.5`, `stats.monto_total=100.5`.
2. **Faltantes**: `[{"id":"1","nombre":""}]` → `validate_extract` → `invalid.missing=["nombre","email","monto"]`.
3. **Email inválido**: `{"email":"bad@@"}` → `filter_valid`→`[]`; `validate_record`→`(False,["email formato invalido"])`.
4. **Monto negativo**: `{"id":"1","nombre":"x","email":"a@b.com","monto":"-5"}` → `(False,["monto no puede ser negativo"])`.
5. **Normalización+casteo**: `{"id":" 2 ","email":"BOB@TEST.COM","monto":"20.126"}` → `clean_record` email `bob@test.com`, `cast_types` `id=2, monto=20.13`.
