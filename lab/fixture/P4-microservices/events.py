# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P4-Microservices: Events
# Version: v1.0-fija

EVENT_BUS = []


def publish_event(event_type, payload):
    event = {"type": event_type, "payload": payload, "processed": False}
    EVENT_BUS.append(event)
    return event


def consume_events(filter_type=None):
    if filter_type:
        return [e for e in EVENT_BUS if e["type"] == filter_type and not e["processed"]]
    return [e for e in EVENT_BUS if not e["processed"]]


def mark_processed(event_index):
    if 0 <= event_index < len(EVENT_BUS):
        EVENT_BUS[event_index]["processed"] = True
        return True
    return False


def clear_processed():
    global EVENT_BUS
    EVENT_BUS = [e for e in EVENT_BUS if not e["processed"]]
    return len(EVENT_BUS)


EVENT_TYPES = {
    "user.created": "payload debe tener user_id",
    "order.created": "payload debe tener order_id y total",
    "order.confirmed": "payload debe tener order_id",
    "inventory.low": "payload debe tener producto y cantidad",
}
