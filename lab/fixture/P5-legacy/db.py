# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P5-Legacy: db.py
# Version: v1.0-fija

import json

DB_FILE = "legacy_db.json"


def save_db():
    from models import DB_USERS, DB_ORDERS, DB_PRODUCTS, DB_AUDIT
    data = {"users": DB_USERS, "orders": DB_ORDERS, "products": DB_PRODUCTS, "audit": DB_AUDIT}
    with open(DB_FILE, "w") as f:
        json.dump(data, f)


def load_db():
    from models import DB_USERS, DB_ORDERS, DB_PRODUCTS, DB_AUDIT
    try:
        with open(DB_FILE, "r") as f:
            data = json.load(f)
        DB_USERS.extend(data.get("users", []))
        DB_ORDERS.extend(data.get("orders", []))
        DB_PRODUCTS.extend(data.get("products", []))
        DB_AUDIT.extend(data.get("audit", []))
    except FileNotFoundError:
        pass


def query(sql):
    return {"error": "SQL no soportado en modo legacy"}


def backup(path):
    save_db()
    import shutil
    shutil.copy(DB_FILE, path)
    return path
