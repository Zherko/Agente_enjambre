# Informe: config
## Resumen
Módulo config de P6-complex que expone 17 operaciones (config_op1 a config_op17) para validar datos y emitir eventos.
## Funciones
- config_op1: valida y emite
- config_op2: valida y emite
- config_op3: valida y emite
- config_op4: valida y emite
- config_op5: valida y emite
- config_op6: valida y emite
- config_op7: valida y emite
- config_op8: valida y emite
- config_op9: valida y emite
- config_op10: valida y emite
- config_op11: valida y emite
- config_op12: valida y emite
- config_op13: valida y emite
- config_op14: valida y emite
- config_op15: valida y emite
- config_op16: valida y emite
- config_op17: valida y emite
## Dependencias
- utils.validate
- events.emit
- config
## Riesgos
- Import circular `import config` dentro del propio módulo
- Dict usado sin importar typing
- Validación condicional con `globals()` frágil
