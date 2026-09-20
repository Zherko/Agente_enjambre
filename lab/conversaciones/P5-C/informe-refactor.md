# Plan de Refactoring: Legacy Monolith

## Resumen
Monolito de 10 archivos (~280 líneas) con estado global compartido (`DB_USERS`, `DB_ORDERS`, `DB_PRODUCTS`, `DB_AUDIT` en `models.py:9`) y acoplamiento cruzado entre modelos, vistas y servicios. Lógica de negocio en `models.py:15` y `services.py:9` sin capas. Plan propone extracción incremental por dominio con repositorios, interfaces y eventos, priorizando dependencias acíclicas para despliegue y testeo independiente.

## Servicios Actuales
7 dominios extraídos de `lab/fixture/P5-legacy/*.py`:

1. **Usuarios** — `models.py:15` `create_user()`, `views.py:8` `view_list_users()`, `views.py:12` `view_user_detail()`.
2. **Productos / Inventario** — `models.py:22` `create_product()`, `views.py:25` `view_product_list()`, `reporting.py:24` `report_inventory()`.
3. **Pedidos** — `models.py:29` `create_order()`, `views.py:20` `view_create_order()`, `reporting.py:17` `report_orders()`.
4. **Pagos** — `services.py:9` `process_payment()`, `services.py:43` `_top_product()` en `generate_report()`.
5. **Auth / Sesiones** — `auth.py:10` `login()`, `auth.py:20` `check_session()`, `auth.py:31` `require_admin()` (`SESSIONS` en `auth.py:7`).
6. **Notificaciones** — `services.py:21` `send_notification()`, `notifications.py:11` `queue_notification()`, `notifications.py:17` `process_queue()`.
7. **Reporting / Auditoría** — `services.py:29` `generate_report()`, `reporting.py:34` `full_report()`, `models.py:44` `log_audit()`, `views.py:29` `view_dashboard()`.

Transversales: **Persistencia** (`db.py:10` `save_db/load_db/backup`) y **Config/Utils** (`config.py:5` `APP_CONFIG`, `utils.py:11` `validate_email/hash_password/paginate`).

## Extraccion Propuesta
Romper `from models import DB_*` sustituyendo listas globales por `Repository` inyectado.

- **Persistencia** → `infra/repository.py`, `infra/audit.py`: mover `DB_*` y `save_db/load_db/backup` (`db.py:10`) + `log_audit` (`models.py:44`). Rompe import circular `db.py:11`.
- **Usuarios** → `services/users/service.py`, `schemas.py`: mover `create_user` (`models.py:15`) y vistas `view_list_users/detail` (`views.py:8`). Usa `UserRepository` + `utils.validate_email`.
- **Productos** → `services/catalog/service.py`: mover `create_product` (`models.py:22`), `view_product_list` (`views.py:25`), `report_inventory` (`reporting.py:24`). Extrae `stock -= cantidad` de `models.py:39` a `StockService`.
- **Pedidos** → `services/orders/service.py`: mover `create_order` (`models.py:29`), `view_create_order` (`views.py:20`). Reemplaza transacción implícita por `OrderCreated` evento.
- **Pagos** → `services/payments/service.py`, `gateway.py`: mover `process_payment` (`services.py:9`). Inyecta `OrderRepository` y `PaymentGateway`, desacopla de `DB_ORDERS`.
- **Auth** → `services/auth/service.py`, `session_store.py`: mover `login/check_session/require_admin` (`auth.py:10`). Elimina `from models import DB_USERS` (`auth.py:11`), usa `UserRepository`; externaliza `secret_key` de `config.py:9`.
- **Notificaciones** → `services/notifications/queue.py`, `dispatcher.py`: mover `send_notification` (`services.py:21`) y `queue_notification/process_queue/notify_*` (`notifications.py:11`). Invierte `notifications.py:5` → interfaz `NotificationSender`, cola async.
- **Reporting** → `services/reporting/service.py`: mover `generate_report/_top_product` (`services.py:29`) y `report_users/orders/audit/full_report` (`reporting.py:8`). Lee vía repositorios, no `DB_*` directo. `view_dashboard` (`views.py:29`) consume `ReportingService`.

Común: `core/utils` con `utils.py:11` y `core/config.py` tipado de `config.py:5`.

## Orden de Extraccion
1. **Config/Utils** — Sin dependencias, habilita inyección y tests puros.
2. **Persistencia/Auditoría** — Todo depende de `DB_*`; extraer `Repository` primero rompe acoplamiento global.
3. **Auth** — Solo depende de Users+Persistencia; estabiliza `handle_request` (`main.py:21`) antes que Orders.
4. **Usuarios y Productos** — Hojas sin dependencia mutua; migran sin tocar Orders.
5. **Pedidos** — Depende de Users+Productos y valida stock; requiere contratos previos.
6. **Pagos** — Muta `order.estado` (`services.py:16`); necesita `OrderService` extraído.
7. **Notificaciones** — Consumidor de eventos `OrderCreated/PaymentCompleted`; al final evita mocks circulares.
8. **Reporting** — Agregador de lectura; se beneficia de todos los repositorios.

Lógica bottom-up: infra → hojas → transaccional → async → agregador. Minimiza cambios de interfaz y permite flags (`config.py:15` `FEATURES`) por servicio.

## Riesgos
1. **Estado global mutable** — `DB_*` importado por referencia (`models.py:9`, `services.py:5`); sin repositorio hay carreras y pérdida de atomicidad `create_order`+`stock` (`models.py:39`).
2. **Lógica en modelos** — `models.py:29` mezcla validación/cálculo/auditoría; sin tests de caracterización se rompen invariantes (stock negativo).
3. **Secret hardcodeado** — `config.py:9` `secret_key` y `debug=True`; rotar sin invalidar `SESSIONS` (`auth.py:7`) deja tokens `sha256(email:password)[:16]` (`auth.py:15`) huérfanos/expuestos.
4. **Ciclo notificaciones→servicios→modelos** — `notifications.py:5` importa `send_notification` de `services.py:21`; extracción ingenua mantiene ciclo, exige inversión de dependencia.
5. **Persistencia frágil** — `db.py:10` sin locking; `load_db:22` hace `extend` duplicando datos; `query:30` siempre error oculta deuda.
6. **Acoplo vistas→modelos** — `views.py:5` y `main.py:21` despachan sin validación/auth; extraer sin fachada rompe API.
7. **Cola sincrónica sin retry** — `notifications.py:17` `process_queue` secuencial marca `sent=True` sin idempotencia; al asincronizar se pierde garantía.

## Criterios de Exito
1. **Paridad con tests golden** — 100% casos `create_user/order`, `process_payment`, `view_dashboard`, `full_report` pasan; cobertura ≥80% en servicios extraídos.
2. **Cero imports globales** — `grep "from models import DB_"` = 0; todo acceso vía `Repository`; `load_db` idempotente y `backup` atómico.
3. **Módulos aislables** — Cada servicio con interfaz tipada despliega/testea solo; ciclo `notifications↔services` eliminado; `handle_request` (`main.py:21`) vía router inyectado.
4. **Config y seguridad externalizadas** — `secret_key/session_timeout` (`config.py:5`) por env/vault, `debug=False` por defecto; `hash_password` con `bcrypt` y expiración de sesión.
5. **Observabilidad y rollback** — Métricas por servicio y auditoría preservada (`report_audit`); flags permiten rollback por servicio sin re-deploy monolito.
