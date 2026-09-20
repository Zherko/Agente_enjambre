# Informe: utils

## Resumen
Modulo utils de P6 complex con 17 operaciones genericas. Se esperaba como utilidad compartida (validacion), pero no define la funcion `validate` que otros 11 modulos invocan: el contrato central esta roto.

## Funciones
- utils_op1 a utils_op17: 17 funciones identicas; retornan error si data vacio, intentan utils.validate, emiten `utils.N` y devuelven dict con module, op y data.
- Nota: `validate` no esta definido en ningun modulo.

## Dependencias
- config (sin uso)
- utils (self-import del propio modulo)
- events (events.emit)
- auth (sin uso)

## Riesgos
- Falta `utils.validate`: causa AttributeError en los 11 modulos que lo llaman; single point of failure del fixture.
- events.emit no definido: falla en runtime.
- Self-import ciclico; imports sin uso.