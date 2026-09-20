# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P4-Microservices: Inventory Service
# Version: v1.0-fija

INVENTORY_DB = {}


def add_stock(producto, cantidad):
    if cantidad <= 0:
        raise ValueError("cantidad debe ser positiva")
    INVENTORY_DB[producto] = INVENTORY_DB.get(producto, 0) + cantidad
    return INVENTORY_DB[producto]


def remove_stock(producto, cantidad):
    if cantidad <= 0:
        raise ValueError("cantidad debe ser positiva")
    current = INVENTORY_DB.get(producto, 0)
    if current < cantidad:
        return False, f"stock insuficiente: {current}"
    INVENTORY_DB[producto] = current - cantidad
    return True, INVENTORY_DB[producto]


def get_stock(producto):
    return INVENTORY_DB.get(producto, 0)


def check_availability(producto, required):
    return get_stock(producto) >= required


def list_low_stock(threshold=10):
    return {k: v for k, v in INVENTORY_DB.items() if v <= threshold}
