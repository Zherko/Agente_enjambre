# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P4-Microservices: Users Service
# Version: v1.0-fija

import re

EMAIL_RE = re.compile(r"^[^@]+@[^@]+\.[^@]+$")
ROLES = ("admin", "editor", "lector")
USERS_DB = []


def create_user(nombre, email, rol="lector"):
    if not nombre or not email:
        raise ValueError("nombre y email requeridos")
    if not EMAIL_RE.match(email):
        raise ValueError("email invalido")
    if rol not in ROLES:
        raise ValueError(f"rol debe ser uno de {ROLES}")
    user = {"id": len(USERS_DB) + 1, "nombre": nombre, "email": email, "rol": rol, "activo": True}
    USERS_DB.append(user)
    return user


def get_user(user_id):
    for u in USERS_DB:
        if u["id"] == user_id:
            return u
    return None


def update_user(user_id, **kwargs):
    user = get_user(user_id)
    if not user:
        return None
    for k, v in kwargs.items():
        if k in ("nombre", "email", "rol"):
            user[k] = v
    return user


def deactivate_user(user_id):
    user = get_user(user_id)
    if user:
        user["activo"] = False
    return user


def list_active():
    return [u for u in USERS_DB if u["activo"]]
