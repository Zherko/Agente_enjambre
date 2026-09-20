# Informe: inventory
## Resumen
Gestion de inventario. 30 ops de stock con mismo patron. Critico para consistencia con orders. 186 lineas, 30 funciones (inventory_op1..inventory_op30), patron homogeneo y sin estado.
## Funciones
30 funciones: inventory_op1, inventory_op2, inventory_op3 ... inventory_op29, inventory_op30. Firma Dict->Dict, primer bloque con utils.validate+events.emit, bloque final retorno directo.
## Dependencias
config, utils, events, auth. Internas del fixture P6; typing solo hints.
## Riesgos
Sin lock pesimista; race condition con orders. Ops sin validacion final. Riesgo medio.
