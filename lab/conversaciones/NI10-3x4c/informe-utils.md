# Informe: utils
## Resumen
Módulo transversal utils: 121 líneas, 17 operaciones (`utils_op1`–`op17`) idénticas al resto del fixture. Debería proveer `validate` pero solo replica el patrón plantilla sin implementar utilidad real.
## Funciones
17 funciones `utils_opN(data: Dict)->Dict` con misma lógica: guarda `empty`, intento `utils.validate` y `events.emit("utils.N")`. Sin `validate` definido.
## Dependencias
Se autoimporta (`import utils`), además `config`, `events`, `auth`. Usa `Dict` sin importar `typing`, referencia circular.
## Riesgos
Import circular, `NameError` por `Dict` no importado, `utils.validate` inexistente genera recursión potencial, sin utilidades reales, bloquea a `payments/shipping/users`.
