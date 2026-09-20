# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P4-Microservices: Gateway
# Version: v1.0-fija

from auth import validate_token
from users import create_user, get_user, list_active
from orders import create_order, confirm_order, get_order
from inventory import add_stock, check_availability


class Gateway:
    def __init__(self):
        self.routes = {}

    def register(self, path, handler, auth_required=False):
        self.routes[path] = {"handler": handler, "auth_required": auth_required}

    def handle(self, path, data=None, token=None):
        route = self.routes.get(path)
        if not route:
            return {"error": "route not found"}, 404
        if route["auth_required"]:
            user, err = validate_token(token)
            if err:
                return {"error": err}, 401
        try:
            result = route["handler"](data or {})
            return result, 200
        except ValueError as e:
            return {"error": str(e)}, 400
        except Exception:
            return {"error": "internal error"}, 500


def setup_gateway():
    gw = Gateway()
    gw.register("POST /users", lambda d: create_user(d["nombre"], d["email"], d.get("rol")), auth_required=False)
    gw.register("GET /users/<id>", lambda d: get_user(d["id"]), auth_required=True)
    gw.register("POST /orders", lambda d: create_order(d["user_id"], d["items"], d["total"]), auth_required=True)
    gw.register("POST /orders/confirm", lambda d: confirm_order(d["order_id"]), auth_required=True)
    return gw
