# Informe: utils.py
## Resumen
Utilidades compartidas: sanitización básica, hash de contraseñas, paginación y formateo de respuestas. Provee helpers sin estado usados por rutas y capa API.
## Funciones
- sanitize_string - escapa caracteres HTML peligrosos
- hash_password - genera hash SHA-256 de contraseña
- paginate - pagina lista y calcula metadatos de páginas
- format_response - envuelve datos con estado y flag ok
## Dependencias
- Ninguna (solo módulos estándar re y hashlib)
## Riesgos
- SHA-256 sin salt es vulnerable a ataques de diccionario
- Sanitización solo cubre < y > incompleta para XSS
- EMAIL_REGEX definido pero nunca usado
