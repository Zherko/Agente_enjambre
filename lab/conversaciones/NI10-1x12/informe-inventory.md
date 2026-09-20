# Informe: inventory
## Resumen
Modulo inventory con 17 operaciones (inventory_op1..17). Mock de gestion de stock sin logica de inventario.
## Funciones
17 funciones inventory_op1..17 (Dict->Dict). Todas iguales, solo cambia nombre y topico de evento.
## Dependencias
Importa config, utils, events, auth y typing Dict/List. Usa utils.validate y events.emit.
## Riesgos
Sin control concurrencia/stock. Duplicacion. Validacion fragil via globals(). Trivial para suplantar datos.
