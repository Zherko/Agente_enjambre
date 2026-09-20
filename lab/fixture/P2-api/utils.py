# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P2-API: Utils
# Version: v1.0-fija

import re
import hashlib

EMAIL_REGEX = re.compile(r"^[^@]+@[^@]+\.[^@]+$")


def sanitize_string(s):
    return s.strip().replace("<", "&lt;").replace(">", "&gt;")


def hash_password(password):
    return hashlib.sha256(password.encode()).hexdigest()


def paginate(items, page=1, per_page=20):
    start = (page - 1) * per_page
    end = start + per_page
    return {
        "items": items[start:end],
        "page": page,
        "per_page": per_page,
        "total": len(items),
        "pages": (len(items) + per_page - 1) // per_page,
    }


def format_response(data, status=200):
    return {"status": status, "data": data, "ok": status < 400}
