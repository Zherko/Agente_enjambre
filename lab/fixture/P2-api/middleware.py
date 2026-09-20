# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P2-API: Middleware
# Version: v1.0-fija

import time

REQUEST_LOG = []


def logging_middleware(request):
    entry = {"method": request.method, "path": request.path, "ts": time.time()}
    REQUEST_LOG.append(entry)
    return request


def auth_middleware(request, secret="secret123"):
    token = request.headers.get("Authorization", "")
    if not token.startswith("Bearer "):
        return {"error": "token requerido"}, 401
    if token[7:] != secret:
        return {"error": "token invalido"}, 401
    return None


def cors_middleware(response, origins=None):
    if origins is None:
        origins = ["*"]
    response.headers["Access-Control-Allow-Origin"] = ", ".join(origins)
    response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE"
    return response


def rate_limit_middleware(request, max_requests=100, window=60):
    now = time.time()
    recent = [r for r in REQUEST_LOG if now - r["ts"] < window and r["path"] == request.path]
    if len(recent) >= max_requests:
        return {"error": "rate limit excedido"}, 429
    return None
