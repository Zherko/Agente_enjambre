# Informe: usuarios
## Resumen
Modulo de gestion de usuarios con validacion de email, creacion con rol y desactivacion. Define constantes de regex y roles permitidos.
## Funciones
- validar_email: valida formato de email con regex.
- crear_usuario: crea diccionario de usuario validando nombre, email y rol.
- desactivar: marca usuario como inactivo y retorna diccionario.
## Dependencias
- re
## Riesgos
- Validacion email simple sin normalizacion ni unicidad.
- Sin persistencia ni control de duplicados.
- Roles hardcodeados sin extensibilidad.
