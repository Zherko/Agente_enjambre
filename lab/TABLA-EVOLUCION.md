# TABLA DE EVOLUCION — Basal vs Enjambre (P1-P6 completas)

> Router v1.1 N={1,3,5}+SP — 1 rep/proyecto --pure — fuente RUNLOG.md + raw*.jsonl — penultima = v1.0 (10k fijo), ultima = v1.1 (lineas/40)

| Version | Coste ($) | Tokens | Tiempo (s) | Intentos | Exito | vs Basal | vs Penultima |
|---|---|---|---|---|---|---|---|
| **Basal sin Enjambre (C) P1-P6** | 0.133833 | 1096190 | 454.5 | 6 | 6/6 | — | — |
| **Penultima Enjambre (v1.0 10k fijo) P1-P6** | 0.118700 | 934637 | 463.3 | 6 | 6/6 | -14.7% tok -11.3% $ | — |
| **Ultima Enjambre (v1.1 N={1,3,5} P1-P6)** | 0.116473 | 926268 | 433.0 | 6 | 6/6 | -15.5% tok -13.0% $ | -0.9% tok -1.9% $ -6.5% tiempo |

| Proyecto | Basal C | Penultima v1.0 | Ultima v1.1 | Ganador |
|---|---|---|---|---|
| P1 95 lin | 143233/39.3 DIRECTO | 143233/39.3 DIRECTO | 143233/39.3 DIRECTO N=1 | Basal |
| P2 169 lin | 144394/73.6 | 144394/73.6 DIRECTO | 147462/70.7 ENJAMBRE N=3 | Ultima -3.9% tiempo |
| P3 221 lin | 153536/74.8 | 153536/74.8 DIRECTO | 153536/74.8 DIRECTO N=1 | Basal |
| P4 318 lin | 158359/84.6 | 158359/84.6 DIRECTO | 151922/68.2 ENJAMBRE N=5 | Ultima -19.4% |
| P5 378 lin | 161614/87.5 | 161614/87.5 DIRECTO | 156614/76.5 ENJAMBRE N=5 | Ultima -12.6% |
| P6 1461 lin | 335054/94.7 | 173501/103.5 ENJAMBRE | 173501/103.5 ENJAMBRE N=5+SP | Enjambre -48% tok |

> Penultima = v1.0 (umbral 10k, volumen tokensEst/1000) — fallaba P2/P4/P5 dejandolos DIRECTO. Ultima = v1.1 (lineas/40, pesos par 0.30) corrige holdout P5/P6. Mejora vs penultima +6.5% tiempo por P2/P4/P5. Mejora vs basal -15.5% tok.
