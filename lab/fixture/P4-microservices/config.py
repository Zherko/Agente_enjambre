# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P4-Microservices: Config
# Version: v1.0-fija

SERVICE_CONFIG = {
    "auth": {"port": 8001, "timeout": 5, "retries": 3},
    "users": {"port": 8002, "timeout": 10, "retries": 2},
    "orders": {"port": 8003, "timeout": 15, "retries": 2},
    "inventory": {"port": 8004, "timeout": 5, "retries": 3},
}

RATE_LIMITS = {
    "auth": {"max_requests": 50, "window_seconds": 60},
    "users": {"max_requests": 100, "window_seconds": 60},
    "orders": {"max_requests": 30, "window_seconds": 60},
    "inventory": {"max_requests": 200, "window_seconds": 60},
}

HEALTH_CHECK_INTERVAL = 30
