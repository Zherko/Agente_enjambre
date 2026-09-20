# Informe: inventario

## Resumen
Módulo de control de stock con consulta, reserva y reposición. Opera directamente sobre diccionario `articulo` con clave `stock`.

## Funciones
- `hay_stock(articulo, cantidad)`: compara stock disponible.
- `reservar(articulo, cantidad)`: descuenta stock si hay disponibilidad.
- `reponer(articulo, cantidad)`: incrementa stock.

## Dependencias
Sin dependencias externas ni imports. Opera sobre estructura dict con clave `stock`.

## Riesgos
Mutación directa sin bloqueo concurrente. Sin validación de tipo de `articulo` ni stock negativo. No hay histórico de movimientos ni control de stock mínimo.
