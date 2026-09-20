# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P5-Legacy: views.py
# Version: v1.0-fija

from models import create_user, create_product, create_order, DB_USERS, DB_ORDERS, DB_PRODUCTS


def view_list_users():
    return [{"id": u["id"], "nombre": u["nombre"], "email": u["email"], "rol": u["rol"]} for u in DB_USERS if u["activo"]]


def view_user_detail(user_id):
    user = next((u for u in DB_USERS if u["id"] == user_id), None)
    if not user:
        return {"error": "usuario no encontrado"}
    orders = [o for o in DB_ORDERS if o["user_id"] == user_id]
    return {**user, "total_ordenes": len(orders), "total_gastado": sum(o["total"] for o in orders)}


def view_create_order(user_id, product_id, cantidad):
    order = create_order(user_id, product_id, cantidad)
    return {"order_id": order["id"], "total": order["total"], "estado": order["estado"]}


def view_product_list():
    return [{"id": p["id"], "nombre": p["nombre"], "precio": p["precio"], "stock": p["stock"]} for p in DB_PRODUCTS]


def view_dashboard():
    return {
        "usuarios_activos": len([u for u in DB_USERS if u["activo"]]),
        "ordenes_pendientes": len([o for o in DB_ORDERS if o["estado"] == "pendiente"]),
        "productos_bajo_stock": len([p for p in DB_PRODUCTS if p["stock"] < 10]),
        "ingresos_totales": sum(o["total"] for o in DB_ORDERS),
    }
