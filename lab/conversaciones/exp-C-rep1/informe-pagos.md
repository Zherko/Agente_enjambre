# Informe: pagos

## Resumen
Módulo de cálculo y gestión de pagos con IVA del 21%, validación de tarjetas y reembolsos. Soporta monedas EUR y USD con control básico.

## Funciones
- `calcular_total(base, moneda)`: aplica IVA y valida moneda soportada.
- `validar_tarjeta(numero)`: verifica 16 dígitos y checksum suma %10.
- `reembolsar(pago_id, importe)`: genera reembolso pendiente si importe positivo.

## Dependencias
Sin dependencias externas ni imports. Usa constantes `TASA_IVA` y `MONEDAS`.

## Riesgos
Validación de tarjeta no implementa Luhn real. Sin control de reembolsos duplicados ni límite acumulado. Redondeo fijo a 2 decimales ignora reglas por moneda.
