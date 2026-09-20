# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P5-Legacy: utils.py
# Version: v1.0-fija

import re
import hashlib

EMAIL_RE = re.compile(r"^[^@]+@[^@]+\.[^@]+$")


def validate_email(email):
    return bool(EMAIL_RE.match(email))


def hash_password(pw):
    return hashlib.sha256(pw.encode()).hexdigest()


def format_money(amount):
    return f"${amount:,.2f}"


def sanitize(s):
    return s.replace("<", "").replace(">", "").strip()


def paginate(items, page, per_page=20):
    start = (page - 1) * per_page
    return items[start:start + per_page]
