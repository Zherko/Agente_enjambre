# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P5-Legacy: services.py
# Version: v1.0-fija

from models import DB_USERS, DB_ORDERS, DB_PRODUCTS, log_audit
from datetime import datetime, timedelta


def process_payment(order_id, method="card"):
    order = next((o for o in DB_ORDERS if o["id"] == order_id), None)
    if not order:
        return {"error": "orden no existe"}
    if order["estado"] != "pendiente":
        return {"error": "orden no esta pendiente"}
    payment = {"order_id": order_id, "amount": order["total"], "method": method, "status": "completed", "ts": datetime.now().isoformat()}
    order["estado"] = "pagada"
    log_audit("payment", "process", order_id)
    return payment


def send_notification(user_id, message):
    user = next((u for u in DB_USERS if u["id"] == user_id), None)
    if not user:
        return False
    log_audit("notification", "send", user_id)
    return True


def generate_report(start_date=None):
    if start_date is None:
        start_date = datetime.now() - timedelta(days=30)
    orders = [o for o in DB_ORDERS if o["estado"] == "pagada"]
    users_with_orders = set(o["user_id"] for o in orders)
    return {
        "periodo": f"desde {start_date.isoformat()}",
        "total_ordenes": len(orders),
        "ingresos": round(sum(o["total"] for o in orders), 2),
        "usuarios_compradores": len(users_with_orders),
        "producto_mas_vendido": _top_product(orders),
    }


def _top_product(orders):
    counts = {}
    for o in orders:
        counts[o["product_id"]] = counts.get(o["product_id"], 0) + o["cantidad"]
    if not counts:
        return None
    top_id = max(counts, key=counts.get)
    product = next((p for p in DB_PRODUCTS if p["id"] == top_id), None)
    return product["nombre"] if product else None
