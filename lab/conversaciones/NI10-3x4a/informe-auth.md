# Informe: auth

## Resumen
Módulo auth de P6-complex (122 líneas). Provee 17 operaciones de autenticación con estructura uniforme. Valida payload, emite evento y devuelve estado, sin lógica criptográfica visible.

## Funciones
17 funciones: `auth_op1` a `auth_op17` (auth.py:5-122). Firma `data: Dict -> Dict`. Cada una verifica `data` vacío, aplica `utils.validate` condicional y ejecuta `events.emit("auth.N", result)`.

## Dependencias
`config`, `utils`, `events`, `auth` (auto-import en auth.py:3) y `typing.Dict/List`. Acoplado a `utils` y `events`. `config` importado sin uso explícito.

## Riesgos
Auto-import `import auth` circular; `utils.validate` sin fallback seguro; `events.emit` sin try/except puede propagar fallo; ausencia de hashing/validación real pese a nombre auth; alta duplicación y ausencia de tests visibles.
