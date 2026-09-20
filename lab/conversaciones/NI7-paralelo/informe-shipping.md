# Informe: shipping
## Resumen
Módulo con 17 ops idénticas que validan dict con utils.validate y emiten evento shipping.N.
## Funciones
- shipping_op1: valida emite shipping.1
- shipping_op2: valida emite shipping.2
- shipping_op3: valida emite shipping.3
- shipping_op4: valida emite shipping.4
- shipping_op5: valida emite shipping.5
- shipping_op6: valida emite shipping.6
- shipping_op7: valida emite shipping.7
- shipping_op8: valida emite shipping.8
- shipping_op9: valida emite shipping.9
- shipping_op10: valida emite shipping.10
- shipping_op11: valida emite shipping.11
- shipping_op12: valida emite shipping.12
- shipping_op13: valida emite shipping.13
- shipping_op14: valida emite shipping.14
- shipping_op15: valida emite shipping.15
- shipping_op16: valida emite shipping.16
- shipping_op17: valida emite shipping.17
## Dependencias
- config
- utils
- events
- auth
## Riesgos
- globals() frágil para validar
- sin try/except en validate/emit
- retorno genérico oculta error
