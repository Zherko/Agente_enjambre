# Informe: events
## Resumen
Módulo events con 17 operaciones que validan entrada vía utils y emiten evento.
## Funciones
- events_op1: valida-emite events.1
- events_op2: valida-emite events.2
- events_op3: valida-emite events.3
- events_op4: valida-emite events.4
- events_op5: valida-emite events.5
- events_op6: valida-emite events.6
- events_op7: valida-emite events.7
- events_op8: valida-emite events.8
- events_op9: valida-emite events.9
- events_op10: valida-emite events.10
- events_op11: valida-emite events.11
- events_op12: valida-emite events.12
- events_op13: valida-emite events.13
- events_op14: valida-emite events.14
- events_op15: valida-emite events.15
- events_op16: valida-emite events.16
- events_op17: valida-emite events.17
## Dependencias
- config
- utils
- auth
- events (autoimportación circular)
## Riesgos
- Import circular `import events` provoca recursión potencial
- Uso de `globals()` oculta dependencia real de utils
- Duplicación de 17 funciones idénticas dificulta mantenimiento
