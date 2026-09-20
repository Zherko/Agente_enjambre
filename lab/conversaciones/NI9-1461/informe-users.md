# Informe: users

## Resumen
Módulo `users` del fixture P6-complex (106 líneas). Gestiona usuarios con 17 operaciones clonadas.

## Funciones
17 funciones `users_op1` a `users_op17`. Reciben `Dict`, validan y emiten evento.

## Dependencias
`import config, utils, events`, `import auth`, `from typing import Dict, List`. Emite `users.N`.

## Riesgos
Sin modelo de usuario ni hash de contraseñas, dependencia circular con `auth`, validación vacía permite datos inválidos y duplicación extrema.
