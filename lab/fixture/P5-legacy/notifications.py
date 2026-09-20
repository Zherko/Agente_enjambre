# FIXTURE CONGELADO — NO MODIFICAR durante el experimento.
# Proyecto P5-Legacy: notifications.py
# Version: v1.0-fija

from services import send_notification
from models import DB_USERS, log_audit

NOTIFICATION_QUEUE = []


def queue_notification(user_id, subject, body):
    notif = {"user_id": user_id, "subject": subject, "body": body, "sent": False}
    NOTIFICATION_QUEUE.append(notif)
    return notif


def process_queue():
    sent = 0
    for notif in NOTIFICATION_QUEUE:
        if not notif["sent"]:
            result = send_notification(notif["user_id"], notif["body"])
            if result:
                notif["sent"] = True
                sent += 1
    return sent


def notify_new_order(order):
    return queue_notification(order["user_id"], "Nueva orden", f"Tu orden #{order['id']} por ${order['total']} ha sido creada")


def notify_payment(order):
    return queue_notification(order["user_id"], "Pago recibido", f"Tu orden #{order['id']} ha sido pagada")


def notification_stats():
    return {
        "total": len(NOTIFICATION_QUEUE),
        "sent": len([n for n in NOTIFICATION_QUEUE if n["sent"]]),
        "pending": len([n for n in NOTIFICATION_QUEUE if not n["sent"]]),
    }
