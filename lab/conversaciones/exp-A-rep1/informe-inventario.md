# Informe: inventario
## Resumen
Módulo de gestión de stock que verifica disponibilidad, reserva unidades descontando inventario y repone existencias con validación de cantidad positiva.
## Funciones
- hay_stock: verifica si el stock del artículo cubre la cantidad pedida.
- reservar: valida cantidad, verifica stock y descuenta si es posible.
- reponer: valida cantidad e incrementa el stock del artículo.
## Dependencias
- ninguna
## Riesgos
- mutación directa del diccionario artículo sin copia defensiva.
- ausencia de control de concurrencia para reservas simultáneas.
- validación limitada a cantidad positiva sin control de tipo.
