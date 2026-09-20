# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P5-Legacy: reporting.py
# Version: v1.0-fija

from models import DB_USERS, DB_ORDERS, DB_PRODUCTS, DB_AUDIT


def report_users():
    active = [u for u in DB_USERS if u["activo"]]
    by_rol = {}
    for u in active:
        by_rol[u["rol"]] = by_rol.get(u["rol"], 0) + 1
    return {"total": len(active), "by_rol": by_rol}


def report_orders():
    by_estado = {}
    for o in DB_ORDERS:
        by_estado[o["estado"]] = by_estado.get(o["estado"], 0) + 1
    revenue = sum(o["total"] for o in DB_ORDERS if o["estado"] == "pagada")
    return {"total": len(DB_ORDERS), "by_estado": by_estado, "revenue": round(revenue, 2)}


def report_inventory():
    low = [p for p in DB_PRODUCTS if p["stock"] < 10]
    total_value = sum(p["precio"] * p["stock"] for p in DB_PRODUCTS)
    return {"total_products": len(DB_PRODUCTS), "low_stock": len(low), "total_value": round(total_value, 2)}


def report_audit(limit=50):
    return DB_AUDIT[-limit:]


def full_report():
    return {
        "users": report_users(),
        "orders": report_orders(),
        "inventory": report_inventory(),
        "recent_audit": report_audit(10),
    }
