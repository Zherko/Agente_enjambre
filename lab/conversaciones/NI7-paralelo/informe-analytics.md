# Informe: analytics
## Resumen
Módulo analytics con 17 operaciones que validan entrada, emiten evento y retornan dict.
## Funciones
- analytics_op1: emite analytics.1
- analytics_op2: emite analytics.2
- analytics_op3: emite analytics.3
- analytics_op4: emite analytics.4
- analytics_op5: emite analytics.5
- analytics_op6: emite analytics.6
- analytics_op7: emite analytics.7
- analytics_op8: emite analytics.8
- analytics_op9: emite analytics.9
- analytics_op10: emite analytics.10
- analytics_op11: emite analytics.11
- analytics_op12: emite analytics.12
- analytics_op13: emite analytics.13
- analytics_op14: emite analytics.14
- analytics_op15: emite analytics.15
- analytics_op16: emite analytics.16
- analytics_op17: emite analytics.17
## Dependencias
- config
- utils
- events
- auth
## Riesgos
- Validación vía globals frágil.
- Emisión sin manejo de errores.
- Error genérico oculta causa.
