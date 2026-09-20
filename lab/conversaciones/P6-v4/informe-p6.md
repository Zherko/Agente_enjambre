# Review P6: 12 servicios

## Resumen

Fixture P6-complex (1461 líneas, 12×~122: 10×122 + config.py:120 + utils.py:121) simula e-commerce con 17 ops stub por módulo. Todos replican `validate -> emit -> return` sin lógica real. Grafo totalmente acoplado: 12/12 dependen de `config/utils/events`, 11/12 de `auth`, con auto-imports circulares. Principal riesgo es monolito distribuido y ausencia de contratos. Escalado exige romper dependencias, introducir bus asíncrono y aislar estado.

## Servicios

- **auth.py** — Autenticación/autorización. Stub `auth_op1..17` valida y emite `auth.N`; sin JWT/hash/RBAC.
  Implementación sintética idéntica a los otros 11; sin persistencia ni middleware.
- **users.py** — Gestión de usuarios y perfiles CRUD. Stub `users_opN` con mismo patrón.
  Sin esquema, sin DB, sin validación de email/username.
- **orders.py** — Orquestación de pedidos/checkout. Stub `orders_opN`.
  Sin máquina de estados, sin saga, sin cálculo de total.
- **inventory.py** — Catálogo y stock. Stub `inventory_opN`.
  Sin reservas, sin concurrencia ni control de inventario.
- **payments.py** — Cobros y reembolsos. Stub `payments_opN`.
  Sin PSP, sin idempotencia ni ledger.
- **shipping.py** — Envíos y tracking. Stub `shipping_opN`.
  Sin integración con carriers ni tarificador.
- **notifications.py** — Notificaciones email/push/SMS. Stub `notifications_opN`.
  Sin plantillas, sin cola, sin preferencias de usuario.
- **analytics.py** — Métricas y reporting. Stub `analytics_opN`.
  Sin agregación, sin warehouse, sin consumo real de eventos.
- **config.py** — Configuración centralizada (120 líneas). Stub `config_opN`.
  Paradójicamente importa `config` a sí mismo + `utils/events`.
- **events.py** — Bus pub/sub transversal. Stub `events_opN` que emite `events.N`.
  Sin broker, sin persistencia, acopla a 12 servicios.
- **gateway.py** — API Gateway y enrutado. Stub `gateway_opN`.
  Sin routing, sin auth-middleware, sin rate-limit.
- **utils.py** — Helpers de validación compartidos (121 líneas). Expone `validate`.
  Importa `auth` y a sí mismo; 204 call-sites dependen de él.

## Dependencias

Grafo estático (`P6-complex/*.py:1-2`):

```
config.py -> [config*, utils, events]
utils.py  -> [config, utils*, events, auth]
auth.py   -> [config, utils, events, auth*]
users, orders, inventory, payments, shipping,
notifications, analytics, events, gateway -> [config, utils, events, auth]
```

- Universal: `config/utils/events` en 12/12 (100%). `auth` en 11/12 (todos menos `config.py`).
- Auto-imports: `auth->auth`, `config->config`, `utils->utils`, `events->events` (`auth.py:2`, `config.py:1`, `utils.py:1`, `events.py:2`).
- Ciclo `utils↔auth↔events` (3 nodos) y diámetro 1: cualquier módulo alcanza a otro vía `utils/events`. Ejecución: cada op hace `utils.validate(data)` + `events.emit(topic, result)` (`auth.py:6-7`). Fallo en `utils` o `events` tumba los 12.

## Riesgos

1. **Monolito distribuido:** 12 servicios con código idéntico y dependencias totales; despliegue separado sin aislamiento. Cambio en `utils.validate` obliga redeploy de 12.
2. **Ciclos y auto-imports:** `import auth` en `auth.py:2` y ciclos `utils↔auth↔events` provocan orden de carga no determinista y `ImportError` parcial.
3. **`utils` god-module/SPOF:** 204 llamadas a `utils.validate` sin contrato tipado; si lanza, caen 12 servicios. Validación real inexistente (`if not data`).
4. **Bus síncrono sin garantías:** `events.emit` directo sin broker, sin retry/DLQ ni orden. Pérdida de eventos entre `orders->payments->shipping`.
5. **Auth acoplada:** 11 servicios importan `auth` directo en vez de validar en `gateway.py`; amplia superficie de ataque y bloquea rotación de secretos.
6. **Sin persistencia ni saga:** Ningún import a DB/ORM; inconsistencia entre reserva de stock y cobro no detectable ni compensable.
7. **Sin observabilidad:** Sin logs/metrics/traces; `analytics.py` stub no consume eventos reales. Imposible medir latencia o error rate.

## Plan de escalado

1. **Romper grafo y capas (S1):** Eliminar auto-imports; extraer `contracts` (Pydantic DTO) y `ports` (interfaces). Inversión de dependencias: servicios dependen de puertos, solo `gateway.py` autentica. Validar con `lab/validar-block.ps1`.
2. **Bus asíncrono + outbox (S2):** Reemplazar `events.emit` por NATS/Kafka con transactional outbox en `orders/payments`; idempotencia por `event_id`, retry y DLQ. `notifications` y `analytics` como consumidores.
3. **Estado por servicio y saga (S3):** DB por servicio (`users`/`orders` Postgres, `inventory` Postgres+Redis, `payments` ledger). Saga orquestada `orders->inventory.reserve->payments.capture->shipping.create` con compensación.
4. **Gateway y resiliencia (S4):** `gateway.py` con OpenAPI, validación en borde, rate-limit y circuit-breaker hacia `users/orders`. `config.py` a config inmutable 12-factor (Vault); añadir health checks, Prometheus y OpenTelemetry.

## Tests

1. **T1 Validación (unit):** `test_validate_empty` con `None/{}` espera `{"error":"empty"}` y `test_validate_passthrough` con `{"id":1}` verifica no mutación. Cubre 204 paths.
2. **T2 Eventos (mock):** Mock `events.emit`; `orders_op1({"order_id":1})` debe emitir `orders.1` y `payments_op1` → `payments.1`; assert payload validado.
3. **T3 Ciclos de import (estático):** Importar cada módulo en subprocess aislado; falla si `ImportWarning` o auto-import detectado. Previene regresión del grafo.
4. **T4 Auth en gateway (integration):** `test_gateway_auth_required` sin token → 401, con token válido enruta a `users/orders`; verifica que downstream no importe `auth`.
5. **T5 Saga e2e (testcontainers):** `test_checkout_success` y `test_checkout_rollback_on_payment_fail` con broker embebido; assert compensación `inventory.release` tras fallo de pago.
6. **T6 Carga (k6/locust):** 500 rps a `gateway` sobre `orders/inventory`; p95 <200ms, sin pérdida de eventos y breaker abierto con latencia inyectada en `utils.validate`.
