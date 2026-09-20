# Informe: shipping

## Resumen
Modulo shipping de P6 complex con 17 operaciones genericas de envio. Sin logistica real: cada op valida, emite evento y devuelve dict nominal, sin calculo de costos ni seguimiento.

## Funciones
- shipping_op1 a shipping_op17: 17 funciones identicas; retornan `{"error": "empty"}` si data vacio, validan via utils, emiten `shipping.N` y devuelven `{"module": "shipping", "op": N, "data": result}`.

## Dependencias
- config (sin uso)
- utils (utils.validate, no definido)
- events (events.emit)
- auth (sin uso)

## Riesgos
- utils.validate inexistente: AttributeError al llamar (fallback nunca activo).
- events.emit no definido: falla en runtime.
- Sin calculo de envio, carrier ni estado de entrega.
- imports sin uso y codigo repetido 17 veces.