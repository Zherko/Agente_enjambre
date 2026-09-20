# Informe: orders
## Resumen
Modulo con 17 operaciones que validan entrada, emiten evento y retornan dict.
## Funciones
- orders_op1: valida y emite orders.1
- orders_op2: valida y emite orders.2
- orders_op3: valida y emite orders.3
- orders_op4: valida y emite orders.4
- orders_op5: valida y emite orders.5
- orders_op6: valida y emite orders.6
- orders_op7: valida y emite orders.7
- orders_op8: valida y emite orders.8
- orders_op9: valida y emite orders.9
- orders_op10: valida y emite orders.10
- orders_op11: valida y emite orders.11
- orders_op12: valida y emite orders.12
- orders_op13: valida y emite orders.13
- orders_op14: valida y emite orders.14
- orders_op15: valida y emite orders.15
- orders_op16: valida y emite orders.16
- orders_op17: valida y emite orders.17
## Dependencias
- config
- utils
- events
- auth
## Riesgos
- Validacion via globals() fragil.
- Eventos sin manejo de errores.
- Error generico poco informativo.
