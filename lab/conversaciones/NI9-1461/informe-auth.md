# Informe: auth

## Resumen
Módulo `auth` del fixture P6-complex (106 líneas). Gestiona autenticación con 17 operaciones homogéneas que validan y emiten eventos.

## Funciones
17 funciones `auth_op1` a `auth_op17`. Firma `def auth_opN(data: Dict) -> Dict` y retorno idéntico con `module`/`op`/`data` o error.

## Dependencias
`import config, utils, events`, `import auth` (auto-import), `from typing import Dict, List`. Acoplado a `utils.validate` y `events.emit`.

## Riesgos
Auto-import circular `auth`→`auth`, dependencia mutua con `config`/`events`/`utils`, chequeo `globals()` inestable, sin manejo de excepciones, código duplicado difícil de mantener.
