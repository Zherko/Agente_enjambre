# Informe: usuarios

## Resumen
Módulo de gestión de usuarios con validación de email por regex y roles fijos. Permite crear y desactivar usuarios con estado activo.

## Funciones
- `validar_email(email)`: verifica formato con `EMAIL_RE`.
- `crear_usuario(nombre, email, rol)`: valida datos y asigna rol lector por defecto.
- `desactivar(usuario)`: marca `activo` como False.

## Dependencias
Depende de `re` y constantes `EMAIL_RE` y `ROLES`. No importa otros módulos internos.

## Riesgos
Regex de email permisiva sin normalización. Sin unicidad de email ni hashing de credenciales. `desactivar` muta diccionario sin auditoría ni validación de permisos.
