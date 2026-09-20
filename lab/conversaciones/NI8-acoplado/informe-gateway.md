# Informe: gateway

## Resumen
Gateway/API del fixture P6-complex. Simula punto de entrada con 17 operaciones (`gateway_op1`–`gateway_op17`) idénticas, sin routing, rate-limit ni autenticación real.

## Funciones
17 funciones: `gateway_op1`–`gateway_op17`. Firma `(data: Dict) -> Dict`. Validan vacío, delegan a `utils.validate` y emiten `gateway.N`.

## Dependencias
`config`, `utils`, `events`, `auth`, `typing (Dict, List)`. Debería ser fachada sobre servicios pero replica misma implementación que servicios internos.

## Riesgos
No actúa como gateway (sin proxy ni agregación), duplicación, acoplamiento directo a `utils`/`events`, `import auth` sin uso, frágil ante cambio de contrato de `events`.
