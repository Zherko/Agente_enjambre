# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Modulo: usuarios (v1.0-fija)

import re

EMAIL_RE = re.compile(r"^[^@]+@[^@]+\.[^@]+$")
ROLES = ("admin", "editor", "lector")


def validar_email(email):
    return bool(EMAIL_RE.match(email or ""))


def crear_usuario(nombre, email, rol="lector"):
    if not nombre or not validar_email(email):
        raise ValueError("nombre o email invalido")
    if rol not in ROLES:
        raise ValueError("rol desconocido")
    return {"nombre": nombre, "email": email, "rol": rol, "activo": True}


def desactivar(usuario):
    usuario["activo"] = False
    return usuario
