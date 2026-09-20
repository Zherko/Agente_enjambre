# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Cualquier cambio invalida las repeticiones ya registradas.
# Modulo: pagos (v1.0-fija)

TASA_IVA = 0.21
MONEDAS = ("EUR", "USD")


def calcular_total(base, moneda="EUR"):
    if moneda not in MONEDAS:
        raise ValueError("moneda no soportada")
    return round(base * (1 + TASA_IVA), 2)


def validar_tarjeta(numero):
    digitos = [int(d) for d in str(numero) if d.isdigit()]
    if len(digitos) != 16:
        return False
    return sum(digitos) % 10 == 0


def reembolsar(pago_id, importe):
    if importe <= 0:
        raise ValueError("importe debe ser positivo")
    return {"pago_id": pago_id, "reembolsado": importe, "estado": "pendiente"}
