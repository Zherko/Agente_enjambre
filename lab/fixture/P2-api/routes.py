# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P2-API: Routes
# Version: v1.0-fija

from usuarios import validar_email
from pagos import calcular_total

ENDPOINTS = {
    "GET /api/users": "listar usuarios",
    "POST /api/users": "crear usuario",
    "GET /api/users/<id>": "obtener usuario",
    "POST /api/payments": "procesar pago",
    "GET /api/payments/<id>": "obtener pago",
}


def route_get_users(db):
    return db.query("SELECT * FROM users")


def route_create_user(db, data):
    if not validar_email(data.get("email")):
        return {"error": "email invalido"}, 400
    user = {"nombre": data["nombre"], "email": data["email"], "rol": data.get("rol", "lector")}
    db.insert("users", user)
    return user, 201


def route_create_payment(db, data):
    total = calcular_total(data["base"], data.get("moneda", "EUR"))
    payment = {"base": data["base"], "total": total, "estado": "pendiente"}
    db.insert("payments", payment)
    return payment, 201
