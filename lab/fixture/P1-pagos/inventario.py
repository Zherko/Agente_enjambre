# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Modulo: inventario (v1.0-fija)


def hay_stock(articulo, cantidad):
    return articulo.get("stock", 0) >= cantidad


def reservar(articulo, cantidad):
    if cantidad <= 0:
        raise ValueError("cantidad debe ser positiva")
    if not hay_stock(articulo, cantidad):
        return {"ok": False, "motivo": "sin stock"}
    articulo["stock"] -= cantidad
    return {"ok": True, "restante": articulo["stock"]}


def reponer(articulo, cantidad):
    if cantidad <= 0:
        raise ValueError("cantidad debe ser positiva")
    articulo["stock"] = articulo.get("stock", 0) + cantidad
    return articulo["stock"]
