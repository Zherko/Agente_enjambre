# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P2-API: Main
# Version: v1.0-fija

from routes import route_get_users, route_create_user, route_create_payment
from schemas import USER_SCHEMA, PAYMENT_SCHEMA, validate_schema
from middleware import logging_middleware, auth_middleware, cors_middleware
from utils import format_response


class API:
    def __init__(self, db):
        self.db = db
        self.routes = {}

    def register(self, method, path, handler):
        self.routes[f"{method} {path}"] = handler

    def handle(self, request):
        request = logging_middleware(request)
        auth_error = auth_middleware(request)
        if auth_error:
            return auth_error
        key = f"{request.method} {request.path}"
        handler = self.routes.get(key)
        if not handler:
            return format_response({"error": "not found"}, 404)
        return handler(self.db, request.data)


def setup_api(db):
    api = API(db)
    api.register("GET", "/api/users", lambda db, data: format_response(route_get_users(db)))
    api.register("POST", "/api/users", lambda db, data: format_response(*route_create_user(db, data)))
    api.register("POST", "/api/payments", lambda db, data: format_response(*route_create_payment(db, data)))
    return api
