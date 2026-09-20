# RUNLOG exp-<RAMA>-rep<N> — plantilla

- fecha: YYYY-MM-DD HH:mm
- ejecutor: lab/correr-rep.ps1 / modelo ejecutor: opencode-go/muse-spark-1.2-contributor
- session_id: <ids>
- fixture_hash_ok: OK | FALLO
- validador: OK: ... | SOLAPE DETECTADO
- t_inicio: HH:mm:ss / t_fin: HH:mm:ss / tiempo_s: <float>
- tokens_in: <int> / tokens_out: <int> (coste aprox: <float>)
- informes:
  - informe-pagos.md: <n> palabras, esquema_ok True/False
  - informe-usuarios.md: ...
  - informe-inventario.md: ...
  - informe-notificaciones.md: ...
- incidencias: ninguna
- veredicto_rep: valida | INVALIDA: <motivo>
