# Informe: gateway

## Resumen
Módulo `gateway` de P6-complex. Puerta de entrada API con 17 operaciones genéricas. Centraliza validación y emisión antes de enrutar a servicios internos.

## Funciones
17 funciones `gateway_op1`..`gateway_op17` con firma `(data: Dict) -> Dict`. Flujo uniforme: error si vacío, `utils.validate`, `events.emit("gateway.N", result)` y retorno `{"module":"gateway","op":N,"data":result}`.

## Dependencias
`config`, `utils`, `events`, `auth`, `typing.Dict/List`. Punto crítico dependiente del bus y validador compartidos.

## Riesgos
Auto-import `auth` superfluo; sin autenticación real ni rate-limit en gateway; `events.emit` sin manejo de fallos bloquea entrada; guardia `globals()` frágil; sin validación de esquema ni timeout; duplicación eleva deuda técnica.
