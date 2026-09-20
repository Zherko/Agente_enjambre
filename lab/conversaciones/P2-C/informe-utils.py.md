# Informe: utils.py
## Resumen
Utilidades transversales: sanitización básica, hash de contraseñas, paginación y formateo de respuestas. Usa solo librerías estándar sin dependencias internas del proyecto.
## Funciones
- sanitize_string - escapa caracteres < y > y recorta espacios
- hash_password - genera SHA256 hexadecimal de la contraseña
- paginate - pagina lista y retorna metadatos de paginación
- format_response - envuelve datos con status y flag ok
## Dependencias
- Ninguna (solo re y hashlib estándar)
## Riesgos
- SHA256 sin salt ni iteraciones es vulnerable a ataques
- Sanitización no cubre inyección SQL ni XSS completa
- paginate sin validación admite page o per_page negativos
