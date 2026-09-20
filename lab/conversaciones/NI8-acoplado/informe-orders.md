# Informe: orders

## Resumen
Servicio de pedidos del fixture. 17 operaciones (`orders_op1`–`orders_op17`) con implementación plantilla, sin flujo de pedido, pago ni estado.

## Funciones
17 funciones: `orders_op1`–`orders_op17`. Firma `(data: Dict) -> Dict`. Mismo flujo: chequeo vacío, `utils.validate`, `events.emit("orders.N")`.

## Dependencias
`config`, `utils`, `events`, `auth`, `typing (Dict, List)`. Núcleo de dominio pero sin dependencia explícita a `payments`/`inventory`.

## Riesgos
Lógica de dominio vacía, duplicación, desacoplo excesivo de `inventory`/`payments` (inconsistencia eventual), `import auth` superfluo, sin idempotencia ni validación de negocio.
