# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P4-Microservices: Orders Service
# Version: v1.0-fija

from datetime import datetime

ORDERS_DB = []


def create_order(user_id, items, total):
    if not items:
        raise ValueError("orden sin items")
    if total <= 0:
        raise ValueError("total debe ser positivo")
    order = {
        "id": len(ORDERS_DB) + 1,
        "user_id": user_id,
        "items": items,
        "total": round(total, 2),
        "estado": "pendiente",
        "created_at": datetime.now().isoformat(),
    }
    ORDERS_DB.append(order)
    return order


def get_order(order_id):
    for o in ORDERS_DB:
        if o["id"] == order_id:
            return o
    return None


def confirm_order(order_id):
    order = get_order(order_id)
    if not order:
        return None
    if order["estado"] != "pendiente":
        return None
    order["estado"] = "confirmada"
    return order


def cancel_order(order_id):
    order = get_order(order_id)
    if not order:
        return None
    if order["estado"] == "entregada":
        return None
    order["estado"] = "cancelada"
    return order


def orders_by_user(user_id):
    return [o for o in ORDERS_DB if o["user_id"] == user_id]
