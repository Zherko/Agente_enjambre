# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P5-Legacy: config.py
# Version: v1.0-fija

APP_CONFIG = {
    "name": "LegacyApp",
    "version": "1.0.0",
    "debug": True,
    "secret_key": "hardcoded-secret-change-me",
    "db_path": "legacy_db.json",
    "session_timeout": 3600,
    "max_login_attempts": 5,
}

FEATURES = {
    "users": True,
    "orders": True,
    "payments": True,
    "notifications": True,
    "reporting": True,
    "api": False,
}
