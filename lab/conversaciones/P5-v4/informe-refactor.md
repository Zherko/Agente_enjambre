# Plan de Refactoring: Legacy Monolith

## Resumen

Monolito de 10 archivos acoplado a listas globales (`DB_USERS`, `DB_ORDERS`, `DB_PRODUCTS`, `DB_AUDIT`) mezcla dominio, vista y persistencia. Plan propone extracción incremental a 7 módulos con patrón Repository/Ports, strangler-fig desde `main.py:21` y validación por contratos. Permite desplegar cada servicio aislado sin big-bang.

## Servicios Actuales

**1. Identidad y Autenticación** (`auth.py`, `utils.py:11`, `models.py:15`) — `login`, `check_session`, `require_admin`; `hash_password`, `validate_email`.

**2. Catálogo** (`models.py:22`, `views.py:25`, `reporting.py:24`) — `create_product`, `view_product_list`, `report_inventory` (low-stock, valoración).

**3. Pedidos** (`models.py:29`, `views.py:20`) — `create_order` (valida stock, descuenta, `log_audit`), `view_create_order`, `view_user_detail`.

**4. Pagos** (`services.py:9`) — `process_payment(order_id, method)`, valida `estado=="pendiente"`, `log_audit("payment")`.

**5. Notificaciones** (`notifications.py`, `services.py:21`) — `queue_notification`, `process_queue`, `notify_new_order`/`notify_payment`; `send_notification` stub.

**6. Reporting/Dashboard** (`reporting.py`, `services.py:29`, `views.py:29`) — `report_users`/`report_orders`/`report_inventory`/`report_audit`/`full_report`; `generate_report`/`_top_product`; `view_dashboard`.

**7. Persistencia/Auditoría** (`db.py`, `models.py:44`) — `save_db`/`load_db`/`backup`/`query` sobre `legacy_db.json`; `log_audit`, 4 listas globales.

**Transversal:** `config.py:5` (`APP_CONFIG`, `FEATURES`, `secret_key` hardcodeada), `utils.py:19` (`format_money`, `sanitize`, `paginate`), `main.py:21` (`run_app`, `handle_request` router).

## Extraccion Propuesta

**`services/auth/`** — `auth_service.py`, `session_store.py`, `schemas.py` — Mover `auth.py:10-35` + `utils.py:hash_password`/`validate_email` + `models.py:create_user` como `user_repository.create`. Reemplazar `SESSIONS` por `SessionStore`.

**`services/catalog/`** — `catalog_service.py`, `product_repository.py`, `api.py` — Mover `models.py:create_product` + `views.py:view_product_list` + `reporting.py:report_inventory`. Abstraer `DB_PRODUCTS` via `ProductRepository`.

**`services/ordering/`** — `ordering_service.py`, `order_repository.py`, `api.py` — Mover `models.py:create_order` + `views.py:view_create_order`. Consume `catalog` por evento/consulta stock, sin import directo.

**`services/payments/`** — `payment_service.py`, `payment_repository.py` — Mover `services.py:process_payment`. Introducir `PaymentProvider` port; mutación `DB_ORDERS` vía `order_repository.update_status`.

**`services/notifications/`** — `notification_service.py`, `queue.py`, `workers.py` — Mover `notifications.py:11-41` + `services.py:send_notification` como adapter. `queue_notification` a cola asíncrona, `process_queue` a worker.

**`services/reporting/`** — `reporting_service.py`, `read_models.py` — Mover `reporting.py:8-40` + `services.py:generate_report`/`_top_product` + `views.py:view_dashboard` como facade sobre réplica R/O.

**`shared/kernel/`** — `config/`, `utils/`, `persistence/` — Mover `config.py:5-22` (env para `secret_key`/`db_path`), `utils.py:11-29` y `db.py:10-38` como `persistence/json_store.py` + `audit/audit_log.py`. `main.py` queda como `app/gateway.py`.

Contrato por servicio: `schemas.py` + `repository` (port) + `service` + `api.py`. Eliminar `from models import DB_*`; inyección de dependencias.

## Orden de Extraccion

1. **Shared Kernel** — Sin dependencias de negocio; desbloquea rotación de `secret_key` y aislamiento de `log_audit` antes de tocar dominios.
2. **Persistencia** — Tras kernel, introduce `Repository` y dual-write JSON→Postgres; mitiga corrupción global de `legacy_db.json`.
3. **Auth** — Transversal, estabiliza `SESSIONS`/`require_admin` y autoriza pedidos/pagos/reportes.
4. **Catálogo** — Base sin dependencias; provee `ProductRepository` que necesita `ordering` para validar stock.
5. **Ordering** — Orquesta `catalog`+`audit`; tras catálogo permite testear `create_order` con stock mockeado sin ciclos.
6. **Payments** — Depende de `ordering` (`pendiente`→`pagada`); aislado después permite idempotencia/reintentos.
7. **Notifications** — Consumidor de eventos `order.created`/`payment.completed`; como escritor asíncrono va penúltimo para no acoplar transacciones.
8. **Reporting** — Solo lecturas agregadas; al final sobre réplica evita bloquear escrituras y valida con strangler comparando dashboards.

## Riesgos

1. **Estado global** — `models.py:9-12` 4 listas mutables importadas en 6 módulos; extracción parcial rompe atomicidad stock-pedido-pago sin saga/outbox.
2. **Transacciones distribuidas** — `create_order` descuenta stock y apendea orden sin rollback; separar `catalog`/`ordering` genera inconsistencia eventual.
3. **Ciclo de imports** — `notifications.py:5`→`services.send_notification` y `services.py:5`→`models`; requiere adapter/eventos para romper ciclo.
4. **Seguridad** — `config.py:9` secret hardcodeado + `auth.py:15` token `sha256(email:password)` sin expiración (`session_timeout`/`max_login_attempts` ignorados); extraer sin rotar propaga vulnerabilidad.
5. **Persistencia frágil** — `db.py:10` `save_db` sin lock; `query:30` stub; `load_db:26` silencia `FileNotFoundError`; migración exige backfill.
6. **Regresión reporting** — `reporting.py`/`views.py:29` agregan sobre listas vivas; desfase réplica o `paginate` roto altera `view_dashboard`/`full_report`.
7. **Fachada divergente** — `main.py:21` `handle_request` string-dispatch sin `sanitize`; strangler incompleto deja dos rutas con contratos divergentes.

## Criterios de Exito

1. **Extracción verificable** — Ningún servicio importa `models.DB_*`; 100% accesos vía `Repository` con tests de contrato; `block.json` actualizado.
2. **Paridad strangler** — `handle_request` delega; 500 casos (usuarios/pedidos/pagos/dashboard) comparados byte-a-byte legacy vs nuevo sin divergencia; rollback por `FEATURES` flags.
3. **Aislamiento desplegable** — Cada servicio con config env-driven y pipeline propio; tests <2 min; `save_db`/`load_db` solo en `persistence`.
4. **Seguridad/observabilidad** — `secret_key` externalizada, `hash_password` con bcrypt+salt, `session_timeout`/`max_login_attempts` aplicados, `log_audit` JSON con `report_audit` consultable.
5. **Performance/resiliencia** — Reporting R/O <100 ms p95, cola notificaciones con reintentos+DLQ, stock inconsistente 0 en test 50 hilos concurrentes `create_order`.
