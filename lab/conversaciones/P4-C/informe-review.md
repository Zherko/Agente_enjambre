# Review: Microservicios

## Resumen General
Arquitectura de 4 microservicios + gateway en memoria (~240 líneas) sin persistencia ni comunicación distribuida real. Código funcional para prototipo pero no apto para producción: estado global volátil, sin validación cruzada entre servicios, sin uso de config/eventos, y gateway con acoplamiento síncrono por import directo. Requiere desacoplamiento, persistencia y seguridad antes de escalar.

## Por Servicio

**auth (auth.py:11-41):** Tokens SHA256 truncados en dict con TTL. API simple, pero sin passwords, sin JWT y sin persistencia.

**users (users.py:12-49):** CRUD en lista con validación email/roles (`admin/editor/lector`). Sin unicidad de email ni validación en `update_user`.

**orders (orders.py:10-55):** Estados pendiente→confirmada/cancelada. Sin verificar `user_id` ni stock; errores retornan `None` silencioso.

**inventory (inventory.py:8-34):** Stock en dict con `add/remove/check_availability` y `list_low_stock`. Sin lock ni integración con orders.

## Problemas Encontrados
- [AUTH] Token SHA256 de `time.time()` predecible, truncado a 32 chars, sin secreto ni JWT (`auth.py:12`).
- [AUTH] `TOKENS = {}` volátil en memoria, sin persistencia ni thread-safety (`auth.py:8`).
- [USERS] `id = len(USERS_DB)+1` permite colisión; sin unicidad de email (`users.py:19`).
- [USERS] Roles `admin/editor/lector` desalineados con `auth` que usa `user/admin` (`users.py:8`, `auth.py:11`).
- [USERS] `update_user` no valida `rol` ni `email` (`users.py:31`).
- [ORDERS] `create_order` no valida `user_id` ni descuenta stock (`orders.py:10`).
- [GATEWAY] Imports síncronos `from auth import ...` rompen distribución; debería ser HTTP (`gateway.py:5-8`).
- [GATEWAY] `RATE_LIMITS`/`SERVICE_CONFIG` (`config.py:5-17`) nunca se consumen; 4 rutas sin inventory/health.
- [EVENTS] `EVENT_BUS` en memoria sin broker; `mark_processed` por índice frágil y sin validación de `EVENT_TYPES` (`events.py:5-21`).
- [UTILS] `generate_id()` con `md5(time.time())` colisiona y `retry` sin backoff (`utils.py:9`).

## Acoplamiento
- `gateway.py:5-8` → `auth`, `users`, `orders`, `inventory` (imports síncronos; dependencia fuerte centralizada).
- `orders` → `users` (lógica por `user_id` sin validación).
- `orders` → `inventory` (esperada pero no implementada; sin `check_availability`).
- `auth` → aislado; `gateway` depende de él para `validate_token`.
- `config.py`/`events.py` → desacoplamiento no usado; nadie los importa.
- `utils.py` → código muerto sin importadores.

## Recomendaciones
1. **Persistencia:** Migrar dicts/listas a Postgres/Redis y tokens a JWT con `SECRET_KEY` + refresh; testear expiración/revocación.
2. **Desacoplar gateway:** Cambiar imports por clientes HTTP usando `SERVICE_CONFIG`/`RATE_LIMITS` (`config.py:5-17`) y añadir rutas inventory/health.
3. **Validación y eventos:** En `create_order` validar `get_user()` y `check_availability()`, publicar `order.created` y suscribir inventory con `remove_stock` transaccional.
4. **Consistencia:** Unificar roles, unicidad de email, validar `rol` en `update_user`, propagar `deactivate_user`→`revoke_token` y usar `uuid4` en vez de `md5(time)`.
