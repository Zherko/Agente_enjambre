# Informe: pagos
## Resumen
Módulo de pagos con IVA del 21% para EUR y USD. Calcula totales, valida tarjetas de 16 dígitos y gestiona reembolsos pendientes con validación básica.
## Funciones
- calcular_total: calcula total con IVA si la moneda es soportada.
- validar_tarjeta: valida tarjeta de 16 dígitos por suma módulo 10.
- reembolsar: crea reembolso pendiente si el importe es positivo.
## Dependencias
- ninguna
## Riesgos
- Validación de tarjeta simplificada, no implementa Luhn real.
- calcular_total no valida base negativa o nula.
- reembolsar no comprueba existencia del pago original.
