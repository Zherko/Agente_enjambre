# Proyecto P1-EXTRAER-FUNCIONES
# Tipo: TRIVIAL (Regla 0 nivel 1)
# Fixture: P1-pagos/ (4 archivos, ~25 lineas c/u)
# Objetivo: medir si Enjambre responde directo o lanza subagentes innecesariamente

## Prompt verbatim (copiar tal cual)

Lee los 4 archivos de lab/fixture/P1-pagos/ (pagos.py, usuarios.py, inventario.py, notificaciones.py). Para cada uno, extrae los nombres de las funciones definidas y retorna una lista JSON con este formato exacto:

{"pagos": ["calcular_total", "validar_tarjeta", "reembolsar"], "usuarios": ["validar_email", "crear_usuario", "desactivar"], "inventario": ["hay_stock", "reservar", "reponer"], "notificaciones": ["puede_enviar", "enviar", "reintentar"]}

Responde SOLO con el JSON, sin explicaciones.

## Archivos de entrada
- lab/fixture/P1-pagos/pagos.py
- lab/fixture/P1-pagos/usuarios.py
- lab/fixture/P1-pagos/inventario.py
- lab/fixture/P1-pagos/notificaciones.py

## Archivo de salida
- lab/conversaciones/P1-<RAMA>-rep<N>/resultado.json

## Criterio de éxito (automatizable)
1. El archivo resultado.json existe y es JSON válido
2. Contiene las 4 keys: pagos, usuarios, inventario, notificaciones
3. Cada key tiene exactamente 3 valores
4. Los valores coinciden con los nombres reales de funciones en el fixture

## Scoring
- pass = JSON válido + 4 keys + 12 funciones correctas = 12 puntos
- fail = qualquer erreur = 0 puntos (invalida la repetición)

## Tokens estimados
- Trabajo real: ~200 tokens (lectura + output JSON)
- Debe resolverse en 1 sesión (clasificador nivel 1)
