# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P4-Microservices: Auth Service
# Version: v1.0-fija

import hashlib
import time

TOKENS = {}


def create_token(user_id, role="user", ttl=3600):
    raw = f"{user_id}:{role}:{time.time()}"
    token = hashlib.sha256(raw.encode()).hexdigest()[:32]
    TOKENS[token] = {"user_id": user_id, "role": role, "expires": time.time() + ttl}
    return token


def validate_token(token):
    data = TOKENS.get(token)
    if not data:
        return None, "token no existe"
    if time.time() > data["expires"]:
        del TOKENS[token]
        return None, "token expirado"
    return data, None


def revoke_token(token):
    if token in TOKENS:
        del TOKENS[token]
        return True
    return False


def require_role(token, required_role):
    data, err = validate_token(token)
    if err:
        return None, err
    if data["role"] != required_role and data["role"] != "admin":
        return None, "permisos insuficientes"
    return data, None
