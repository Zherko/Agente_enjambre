# Informe: notifications
## Resumen
Módulo notifications con 17 operaciones que validan entrada, emiten evento y retornan dict.
## Funciones
- notifications_op1: emite notifications.1
- notifications_op2: emite notifications.2
- notifications_op3: emite notifications.3
- notifications_op4: emite notifications.4
- notifications_op5: emite notifications.5
- notifications_op6: emite notifications.6
- notifications_op7: emite notifications.7
- notifications_op8: emite notifications.8
- notifications_op9: emite notifications.9
- notifications_op10: emite notifications.10
- notifications_op11: emite notifications.11
- notifications_op12: emite notifications.12
- notifications_op13: emite notifications.13
- notifications_op14: emite notifications.14
- notifications_op15: emite notifications.15
- notifications_op16: emite notifications.16
- notifications_op17: emite notifications.17
## Dependencias
- config
- utils
- events
- auth
- typing
## Riesgos
- Validación vía globals frágil.
- Emisión sin manejo de errores.
- Error genérico oculta causa.
