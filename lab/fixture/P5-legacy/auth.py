# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P5-Legacy: auth.py
# Version: v1.0-fija

import hashlib

SESSIONS = {}


def login(email, password):
    from models import DB_USERS
    user = next((u for u in DB_USERS if u["email"] == email and u["activo"]), None)
    if not user:
        return None, "usuario no encontrado"
    token = hashlib.sha256(f"{email}:{password}".encode()).hexdigest()[:16]
    SESSIONS[token] = {"user_id": user["id"], "rol": user["rol"]}
    return token, None


def check_session(token):
    return SESSIONS.get(token)


def logout(token):
    if token in SESSIONS:
        del SESSIONS[token]
        return True
    return False


def require_admin(token):
    session = check_session(token)
    if not session:
        return False
    return session["rol"] == "admin"
