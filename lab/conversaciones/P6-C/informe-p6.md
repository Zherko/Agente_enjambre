# Review P6: 12 servicios

## Resumen

12 módulos Python (1.461 líneas, ~122 por servicio) con patrón idéntico: 17 funciones `*_opN` que validan con `utils.validate`, emiten `events.emit` y retornan dict. Todos importan `config`, `utils`, `events` y 10/12 importan `auth`, generando acoplamiento total y ciclos. Sin lógica de dominio real, persistencia ni contratos. Riesgos críticos: imports circulares/auto-imports, `Dict` sin importar en config/utils y bus en memoria sin garantías.

## Servicios

- **auth.py** (122 líneas, 17 ops): Autenticación central. Expone `auth_op1..17` que validan y emiten `auth.N`.
  Importado por 10 módulos; SPOF transversal que acopla todo el sistema.

- **users.py** (122 líneas, 17 ops): Gestión de usuarios/perfiles. `users_op1..17` simulan CRUD.
  Depende de `auth` para autorización y del trío `config`/`utils`/`events`.

- **orders.py** (122 líneas, 17 ops): Orquestación de pedidos. `orders_op1..17` simulan creación/estado.
  Debería coordinar `inventory` y `payments`; hoy solo valida y emite.

- **inventory.py** (122 líneas, 17 ops): Control de stock. `inventory_op1..17` sin reserva real ni bloqueo.
  Sin transacción; riesgo de sobreventa al escalar.

- **payments.py** (122 líneas, 17 ops): Pagos. `payments_op1..17` sin pasarela ni idempotencia.
  Emite `payments.N` sin atomicidad con `orders`.

- **shipping.py** (122 líneas, 17 ops): Envíos. `shipping_op1..17` sin proveedor ni tracking.
  Consumidor downstream de `orders`/`inventory`, hoy aislado.

- **notifications.py** (122 líneas, 17 ops): Notificaciones. `notifications_op1..17` sin cola ni reintentos.
  Debería consumir eventos de todos los dominios; solo produce.

- **analytics.py** (122 líneas, 17 ops): Métricas. `analytics_op1..17` sin pipeline ni storage.
  Debe ser consumidor read-only; hoy también emite.

- **config.py** (120 líneas, 17 ops): Configuración. `config_op1..17` sin lectura de env/YAML.
  Importado por 11 módulos; cambio rompe todo.

- **events.py** (122 líneas, 17 ops): Bus de eventos. Expone `events.emit` usado por todos.
  Sin broker, persistencia ni versionado.

- **gateway.py** (122 líneas, 17 ops): API Gateway. `gateway_op1..17` deberían rutear pero replican patrón base.
  Punto ideal para auth/rate-limit; hoy sin routing.

- **utils.py** (121 líneas, 17 ops): Utilidades (`validate` transversal). `utils_op1..17` + `validate`.
  Auto-import `import utils` y sin `from typing import Dict`.

## Dependencias

```
config.py        -> config(self), utils, events
utils.py         -> config, utils(self), events, auth
auth.py          -> config, utils, events, auth(self)
events.py        -> config, utils, events(self), auth
users/orders/inventory/payments/shipping/notifications/analytics/gateway
                 -> config, utils, events, auth (cada uno)
```

Fan-in: `config` 11, `utils` 11, `events` 11, `auth` 10. Ciclos: `config<->utils`, `auth<->events<->utils` y 3 auto-imports. `from typing import Dict,List` falta en `config.py`/`utils.py` -> `NameError`. Sin bounded contexts aislados.

## Riesgos

1. **Imports circulares/auto-imports**: `config<->utils` mutuo y `import auth` en `auth.py` causan módulos a medio inicializar e `ImportError` según orden de carga.
2. **Tipado roto**: `config.py`/`utils.py` usan `Dict` sin importar `typing`; cualquier `*_opN` falla con `NameError`.
3. **Bus en memoria sin garantías**: `events.emit` sin try/except, persistencia ni DLQ. Pérdida silenciosa, sin replay ni orden.
4. **Validación frágil**: `utils.validate` vía `if "utils" in globals()` falla silenciosamente; sin esquema ni sanitización, vulnerable a payloads malformados.
5. **Auth acoplada**: 10 módulos importan `auth` sin usarlo directamente. Viola mínimo privilegio, bloquea tests aislados y hace de `auth` un SPOF.
6. **Duplicación e inconsistencia**: 204 funciones idénticas sin persistencia ni idempotencia. Sin saga/transacción entre `orders`/`payments`/`inventory` -> estados inconsistentes.
7. **Sin contratos**: Retornos `{"module","op","data"}` sin versionado ni OpenAPI. Gateway no expone interfaz estable.
8. **Observabilidad nula**: Sin logging, métricas ni tracing; sin `request-id` correlacionado en eventos.

## Plan de escalado

1. **Romper ciclos con DI**: Eliminar auto-imports y `import auth` global. `config` sin dependencias, `utils` sin importar `config`/`events`; inyectar `validator` y `event_bus` por parámetro. Grafo objetivo acíclico `config <- utils <- dominio <- gateway`.
2. **Contratos y broker real**: Abstraer `events` como interfaz; memoria en dev y Kafka/RabbitMQ en prod. Esquemas con pydantic, outbox pattern para atomicidad `orders`/`inventory`/`payments` y versionado de eventos.
3. **Aislar contextos con storage propio**: DB/schema por servicio (`users`, `orders`, `inventory`, `payments`), saga con compensaciones en `orders` y `analytics` como consumidor asíncrono read-only.
4. **Endurecer transversal**: Mover `auth` a middleware de `gateway` (JWT/OAuth2), añadir validación estricta, idempotency-keys en `payments` y rate-limit. Instrumentar logging JSON, Prometheus y OpenTelemetry.

## Tests

1. **Contrato vacío**: `auth_op1({})` debe retornar `{"error":"empty"}`; `*_opN({"k":1})` con mock de `utils.validate` retorna `{"module":"<svc>","op":N,"data":...}` y `events.emit("<svc>.N", ...)` llamado una vez.
2. **Carga y tipado**: `import config; import utils` debe fallar antes del fix y pasar tras añadir `from typing import Dict`; `import-linter` sin ciclos y `py_compile` limpio en 12 archivos.
3. **Desacople de auth**: Con `auth` mockeado, `users_op1`/`orders_op1` operan sin `auth` real; gateway rechaza sin JWT y acepta con JWT válido sin que dominios importen `auth`.
4. **Saga idempotente**: Doble envío `orders_op1` con mismo `order_id` es idempotente; fallo en `payments_op1` dispara compensación que libera stock en `inventory` verificada por eventos persistidos.
5. **Persistencia de eventos**: 100 `emit` concurrentes sobreviven a reinicio con broker persistido (fallan en memoria) y orden se preserva; `validate` que lanza excepción va a DLQ.
6. **Fuzz de esquema**: Payload malicioso `{"__proto__":1}` rechazado por `validate`; hypothesis fuzzea las 204 ops y ninguna retorna `data` crudo sin validar.
