# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P5-Legacy: models.py (monolito)
# Version: v1.0-fija

import hashlib
import time
from datetime import datetime

DB_USERS = []
DB_ORDERS = []
DB_PRODUCTS = []
DB_AUDIT = []


def create_user(nombre, email, rol="lector"):
    user = {"id": len(DB_USERS) + 1, "nombre": nombre, "email": email, "rol": rol, "activo": True, "created": datetime.now().isoformat()}
    DB_USERS.append(user)
    log_audit("user", "create", user["id"])
    return user


def create_product(nombre, precio, stock=0):
    product = {"id": len(DB_PRODUCTS) + 1, "nombre": nombre, "precio": round(precio, 2), "stock": stock}
    DB_PRODUCTS.append(product)
    log_audit("product", "create", product["id"])
    return product


def create_order(user_id, product_id, cantidad):
    user = next((u for u in DB_USERS if u["id"] == user_id), None)
    product = next((p for p in DB_PRODUCTS if p["id"] == product_id), None)
    if not user or not product:
        raise ValueError("user o product no existe")
    if product["stock"] < cantidad:
        raise ValueError("stock insuficiente")
    total = round(product["precio"] * cantidad, 2)
    order = {"id": len(DB_ORDERS) + 1, "user_id": user_id, "product_id": product_id, "cantidad": cantidad, "total": total, "estado": "pendiente", "created": datetime.now().isoformat()}
    DB_ORDERS.append(order)
    product["stock"] -= cantidad
    log_audit("order", "create", order["id"])
    return order


def log_audit(entity, action, entity_id):
    DB_AUDIT.append({"entity": entity, "action": action, "id": entity_id, "ts": datetime.now().isoformat()})
