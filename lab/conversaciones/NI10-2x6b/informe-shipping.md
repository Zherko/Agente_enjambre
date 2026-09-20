# Informe: shipping

## Resumen
Módulo shipping en P6-complex. 122 líneas, 17 funciones repetidas con flujo valida-emite-retorna. Sin cálculo de costes, rutas o tracking; plantilla simétrica al resto del fixture.

## Funciones
17 funciones `shipping_op1`..`op17(data: Dict)->Dict`: comprueba `not data`, valida con `utils.validate`, emite `shipping.N`, retorna `{"module":"shipping","op":N,"data":result}`.

## Dependencias
Imports: `config`, `utils`, `events`, `auth`, `typing`. Depende de `utils.validate` y `events.emit`. No integra transportistas externos.

## Riesgos
Lógica de transporte ausente, guard redundante `globals()`, sin validación de direcciones, eventos sin retry ni orden, mantenimiento costoso por repetición 17x.
