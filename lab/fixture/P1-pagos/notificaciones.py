# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Modulo: notificaciones (v1.0-fija)

CANALES = ("email", "sms")
MAX_REINTENTOS = 3


def puede_enviar(usuario, canal):
    return bool(usuario.get("activo")) and canal in CANALES


def enviar(usuario, canal, mensaje):
    if not puede_enviar(usuario, canal):
        return {"ok": False, "motivo": "destinatario o canal invalido"}
    if not mensaje:
        raise ValueError("mensaje vacio")
    return {"ok": True, "canal": canal, "intentos": 1}


def reintentar(envio_previo):
    intentos = envio_previo.get("intentos", 0) + 1
    if intentos > MAX_REINTENTOS:
        return {"ok": False, "motivo": "reintentos agotados"}
    return {"ok": True, "intentos": intentos}
