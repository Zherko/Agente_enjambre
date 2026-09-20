# Informe: pagos
## Resumen
Módulo pagos gestiona cálculo con IVA, validación básica de tarjeta y reembolsos pendientes. Sin dependencias externas. Lógica simple y constantes locales.
## Funciones
- calcular_total: calcula total con IVA 21% validando moneda EUR/USD.
- validar_tarjeta: valida 16 dígitos y checksum suma % 10.
- reembolsar: registra reembolso pendiente si importe positivo.
## Dependencias
- ninguna
## Riesgos
- validar_tarjeta no implementa Luhn real, falsos positivos posibles.
- TASA_IVA fija sin soporte multi-país o exenciones.
- reembolsar no valida existencia de pago ni evita reembolsos duplicados.
