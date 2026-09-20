# Informe: inventario
## Resumen
Módulo inventario gestiona stock de artículos con verificación, reserva y reposición. Opera sobre diccionarios con clave stock, validando cantidades positivas y disponibilidad.
## Funciones
- hay_stock: verifica si el stock disponible alcanza la cantidad solicitada.
- reservar: descuenta stock si hay disponibilidad, valida cantidad positiva.
- reponer: incrementa stock en la cantidad indicada, validando cantidad positiva.
## Dependencias
- ninguna
## Riesgos
- Mutación directa del diccionario sin control de concurrencia.
- Sin validación de tipos ni límites máximos de stock.
- Retorno inconsistente entre excepciones y dict de error por falta de stock.
