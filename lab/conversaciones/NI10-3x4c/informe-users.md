# Informe: users
## Resumen
Módulo de dominio users: 122 líneas, 17 operaciones homogéneas (`users_op1`–`op17`) con patrón plantilla — valida, emite evento y retorna dict. Sin lógica de autenticación o perfil diferenciada.
## Funciones
17 funciones `users_opN(data: Dict)->Dict` con guarda `empty`, validación `utils.validate` bajo `globals()` y `events.emit("users.N")`.
## Dependencias
`config`, `utils`, `events`, `auth` y `typing.Dict/List`. Acoplado a eventos y validador central; `auth` importado sin uso directo.
## Riesgos
Duplicación extrema, `auth` sin invocar, validación frágil, `List` ocioso, sin control de permisos ni sanitización, riesgo de crecimiento no mantenible.
