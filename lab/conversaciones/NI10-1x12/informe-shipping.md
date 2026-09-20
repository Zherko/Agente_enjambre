# Informe: shipping
## Resumen
Modulo shipping con 17 operaciones (shipping_op1..17). Mock de logistica sin calculo envio.
## Funciones
17 funciones shipping_op1..17 identicas. Solo varia topico events.emit shipping.N.
## Dependencias
Importa config, utils, events, auth y typing. Depende de utils.validate y events.emit.
## Riesgos
Sin calculo tarifas/tracking. Duplicacion. Fragilidad por globals() check y falta de manejo errores.
