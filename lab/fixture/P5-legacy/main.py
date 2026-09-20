# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P5-Legacy: main.py
# Version: v1.0-fija

from config import APP_CONFIG, FEATURES
from db import load_db, save_db
from auth import login, check_session
from views import view_list_users, view_dashboard, view_create_order
from services import process_payment, generate_report
from notifications import process_queue
from reporting import full_report


def run_app():
    load_db()
    print(f"Starting {APP_CONFIG['name']} v{APP_CONFIG['version']}")
    if APP_CONFIG["debug"]:
        print("DEBUG MODE ON")


def handle_request(action, data, token=None):
    if action == "login":
        return login(data["email"], data["password"])
    if action == "dashboard":
        return view_dashboard()
    if action == "list_users":
        return view_list_users()
    if action == "create_order":
        return view_create_order(data["user_id"], data["product_id"], data["cantidad"])
    if action == "pay":
        return process_payment(data["order_id"], data.get("method", "card"))
    if action == "report":
        return generate_report()
    if action == "full_report":
        return full_report()
    if action == "process_notifications":
        return {"processed": process_queue()}
    return {"error": "accion desconocida"}


if __name__ == "__main__":
    run_app()
