# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P4-Microservices: Utils
# Version: v1.0-fija

import hashlib
import time


def generate_id():
    return hashlib.md5(str(time.time()).encode()).hexdigest()[:12]


def format_currency(amount, currency="EUR"):
    symbols = {"EUR": "\u20ac", "USD": "$"}
    return f"{symbols.get(currency, currency)}{amount:.2f}"


def chunk_list(items, chunk_size):
    return [items[i:i + chunk_size] for i in range(0, len(items), chunk_size)]


def flatten_dict(d, parent_key="", sep="."):
    items = []
    for k, v in d.items():
        new_key = f"{parent_key}{sep}{k}" if parent_key else k
        if isinstance(v, dict):
            items.extend(flatten_dict(v, new_key, sep).items())
        else:
            items.append((new_key, v))
    return dict(items)


def retry(func, max_attempts=3, delay=1):
    last_error = None
    for attempt in range(max_attempts):
        try:
            return func()
        except Exception as e:
            last_error = e
            time.sleep(delay)
    raise last_error
