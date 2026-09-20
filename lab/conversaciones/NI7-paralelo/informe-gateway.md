# Informe: gateway
## Resumen
Gateway P6-complex: 17 operaciones que validan, emiten evento y retornan dict.
## Funciones
- gateway_op1: valida y emite gateway.1
- gateway_op2: valida y emite gateway.2
- gateway_op3: valida y emite gateway.3
- gateway_op4: valida y emite gateway.4
- gateway_op5: valida y emite gateway.5
- gateway_op6: valida y emite gateway.6
- gateway_op7: valida y emite gateway.7
- gateway_op8: valida y emite gateway.8
- gateway_op9: valida y emite gateway.9
- gateway_op10: valida y emite gateway.10
- gateway_op11: valida y emite gateway.11
- gateway_op12: valida y emite gateway.12
- gateway_op13: valida y emite gateway.13
- gateway_op14: valida y emite gateway.14
- gateway_op15: valida y emite gateway.15
- gateway_op16: valida y emite gateway.16
- gateway_op17: valida y emite gateway.17
## Dependencias
- config
- utils
- events
- auth
## Riesgos
- globals() frágil para validate
- sin manejo de excepciones
- duplicación masiva sin abstracción
