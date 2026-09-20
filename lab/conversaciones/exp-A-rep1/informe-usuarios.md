# Informe: usuarios
## Resumen
Módulo de gestión básica de usuarios con validación de email por regex y roles fijos. Permite crear usuarios validados y desactivarlos mediante flag activo.
## Funciones
- validar_email: valida formato de email usando regex.
- crear_usuario: crea diccionario usuario tras validar nombre, email y rol.
- desactivar: marca usuario como inactivo cambiando activo a False.
## Dependencias
- re
## Riesgos
- validación email solo sintáctica, permite emails inválidos semánticamente.
- diccionario mutable compartido puede mutarse externamente sin control.
- sin persistencia ni control de duplicados por email.
