# Review: Microservicios

## Resumen General

Arquitectura presentada como microservicios pero implementada como monolito modular en memoria. Estados volátiles (dict/list globales), sin persistencia ni comunicación por red. Gateway importa funciones directamente, anulando aislamiento. Autenticación débil con tokens truncados sin firma, sin validación cruzada entre servicios y sin uso de la capa de eventos. Requiere desacoplamiento, persistencia y seguridad antes de producción.

## Por Servicio

**auth:** Tokens SHA256 truncados a 32 chars sobre `time.time()`, predecibles y sin firma. Almacen en `TOKENS` volátil, expiración lazy y bypass admin en `require_role`. Sin refresh ni rotación.

**users:** CRUD en `USERS_DB` con ID `len+1` (colisión en concurrencia). Valida email/rol en `create_user` pero `update_user` no revalida. `deactivate_user` sin auditoría.

**orders:** Ciclo pendiente→confirmada/cancelada sin validar `user_id` ni stock. `total` confiado al cliente, sin cálculo servidor ni idempotencia.

**inventory:** Dict `producto→cantidad` no atómico. `remove_stock` retorna tupla y `add_stock` int (API inconsistente). Sin reservas ni bloqueo.

## Problemas Encontrados

- [GATEWAY] Importa `auth`, `users`, `orders`, `inventory` como funciones locales; sin HTTP/gRPC ni `timeout/retries` de `config.py`. Monolito disfrazado.
- [AUTH] `hashlib.sha256(f"{user_id}:{role}:{time.time()}")[:32]` predecible, sin HMAC; no distribuible ni revocable entre instancias.
- [AUTH/USERS] Roles incoherentes: `auth.py` default `role="user"` vs `users.py` `ROLES=("admin","editor","lector")`; `require_role` nunca coincide con usuarios reales.
- [USERS] `update_user` acepta `kwargs` sin validar email/rol, corrompe invariantes de `create_user`.
- [ORDERS] `create_order` no verifica `get_user` ni `check_availability`; crea órdenes para usuarios inexistentes y sin stock.
- [INVENTORY] `check_availability` + `remove_stock` no atómicos; carrera que permite sobrevender.
- [EVENTS] `EVENT_BUS` volátil, `mark_processed` por índice frágil; ningún servicio publica/consume pese a `EVENT_TYPES`.
- [CONFIG] `SERVICE_CONFIG`, `RATE_LIMITS`, `HEALTH_CHECK_INTERVAL` y `utils.retry`/`generate_id` sin uso; código muerto.

## Acoplamiento

- **gateway → auth, users, orders, inventory:** dependencia directa por import; rompe aislamiento. Importa `add_stock/check_availability` sin exponer rutas (acoplamiento muerto).
- **orders → (debería → users, inventory):** acoplamiento ausente; no consulta `get_user` ni `check_availability`.
- **users → ninguno:** aislado, debería validar rol vía `auth`.
- **inventory → ninguno:** aislado, sin suscripción a `order.created`.
- **events → ninguno:** bus huérfano; nadie hace `publish_event`/`consume_events`.
- **config/utils → ninguno:** desconectados del runtime.

## Recomendaciones

1. **Gateway como proxy HTTP:** reemplazar imports por llamadas con `timeout/retries` y `RATE_LIMITS` de `config.py`; añadir middleware `validate_token`/`require_role` en rutas protegidas.
2. **Unificar identidad y asegurar tokens:** alinear `ROLES`, migrar a JWT firmado (HS256/RS256) con `jti` en Redis/BD y `revoke_token` distribuido.
3. **Orders transaccional:** validar `user_id`, reservar stock atómico o saga compensable, calcular `total` en servidor y publicar `order.created`/`order.confirmed` en `events.py`.
4. **Persistir y activar eventos:** sustituir DBs en memoria por Postgres y cola (Redis/RabbitMQ); cambiar `mark_processed` a ID y consumir `inventory.low` para alertas.
5. **Estandarizar y resistir concurrencia:** unificar retornos `inventory` a `{ok, data}`, usar UUID4 en `generate_id`, aplicar `retry` con backoff exponencial y tests de concurrencia en `remove_stock`.
