# Informe: users

## Resumen
Servicio de usuarios del fixture. 17 operaciones (`users_op1`–`users_op17`) idénticas, sin CRUD real, perfil ni persistencia.

## Funciones
17 funciones: `users_op1`–`users_op17`. Firma `(data: Dict) -> Dict`. Emiten `users.N` tras `utils.validate`.

## Dependencias
`config`, `utils`, `events`, `auth`, `typing (Dict, List)`. Solapa responsabilidad con `auth` sin delimitar frontera.

## Riesgos
Duplicación con `auth`, sin separación de concerns, `import auth` crea acoplamiento circular users↔auth, validación frágil, sin PII handling.
