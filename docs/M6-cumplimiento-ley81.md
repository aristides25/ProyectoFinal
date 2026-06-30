# Módulo 6 — Cumplimiento Regulatorio (Ley 81 de Protección de Datos, Panamá)

> **Peso en la rúbrica: 15%** (junto con M1). Marco: **Ley 81 de 26 de marzo de 2019** sobre
> Protección de Datos Personales (Panamá), reglamentada por el **Decreto Ejecutivo 285 de 2021**
> y supervisada por la **ANTAI** (Autoridad Nacional de Transparencia y Acceso a la Información).
> En vigor pleno desde el **29 de marzo de 2021**.

> **⚠️ NOTA SOBRE EL ARTÍCULO 13 (leer).** El enunciado del profesor pide justificar el MFA contra
> "el principio de seguridad técnica del **Artículo 13**". Sin embargo, en el **texto vigente** de
> la Ley 81: el **Art. 13** regula la **transferencia de datos sensibles** (no la seguridad); el
> **deber de medidas de seguridad** está en el **Art. 31**; el **principio de seguridad** se enumera
> en el **Art. 2**; y la **diligencia del responsable/custodio** en el **Art. 14**. Este documento
> **cita los artículos reales** y, donde el enunciado lo pide, referencia el Art. 13 con esta
> aclaración. *Se recomienda confirmar el número con el profesor por si usa otra edición/numeración.*

---

## 1. Por qué CREATIC está obligada

CREATIC trata **datos personales** (estudiantes, docentes) y **datos sensibles/financieros**
(calificaciones, finanzas). La Ley 81 le impone principios de tratamiento (Art. 2), garantía de los
**derechos del titular** (Art. 15, ARCO+), un **deber de seguridad** (Art. 31) y de **diligencia**
(Art. 14). El incumplimiento habilita **sanciones de la ANTAI** (Arts. 42–43), entre **$1,000 y
$10,000** y hasta clausura de registros.

---

## 2. Tabla de mapeo: Artículo Ley 81 → Control técnico → Entregable

| Artículo / Norma | Exigencia | Control técnico propuesto | Entregable que lo implementa |
|---|---|---|---|
| **Art. 2 — Principios** (incl. *seguridad*, *confidencialidad*, *finalidad*) | Tratar los datos con seguridad, confidencialidad y para fines legítimos | MFA, mínimo privilegio, microsegmentación | `docs/M2-arquitectura.md` |
| **Art. 31 — Medidas de seguridad** | Adoptar medidas técnicas y organizativas apropiadas | **MFA** (Keycloak) + **cifrado at-rest** + hardening | `diagramas/flujo-auth-mfa.mmd`, `ansible/tasks/remediacion.yml`, `powershell/Harden-Windows.ps1` |
| **Art. 14 — Diligencia del responsable/custodio** | Cuidar los datos con la debida diligencia (responde por daños) | Hardening automatizado + SOC + control de accesos | `ansible/`, `powershell/`, `siem/` |
| **Art. 15 — Derechos del titular (ARCO+)** | Acceso, rectificación, cancelación, oposición y portabilidad | Procedimiento ARCO + integridad/disponibilidad de datos para localizarlos | Política ARCO (anexo) + cifrado/respaldo |
| **Art. 21 — Irrenunciabilidad de derechos** | Los derechos ARCO no se limitan por convenio | Diseño que garantiza el ejercicio efectivo de derechos | Política ARCO (anexo) |
| **Art. 13 — Transferencia de datos sensibles** *(ref. del enunciado)* | Controlar la transferencia de datos sensibles | Cifrado en tránsito (TLS/WireguArd) + reglas de flujo NGFW | `docs/M2-arquitectura.md` (matriz de flujos) |
| **Decreto 285/2021 — Notificación de brechas (72 h)** | Notificar el incidente (≈72 h) a la autoridad/titulares | **IRP** con flujo de notificación a la ANTAI | `docs/M7-riesgos-irp.md` |
| **Retención y trazabilidad de logs** | Poder auditar accesos y conservar evidencia | **Retención de logs** e integridad en Wazuh | `siem/`, §4 de este documento |
| **Arts. 42–43 — Régimen sancionatorio (ANTAI)** | Evitar multas ($1,000–$10,000) y clausura | Conjunto completo de controles (defensa de diligencia) | Todo el repositorio |

---

## 3. Justificación: cómo el MFA cumple el deber de seguridad (Art. 31; principio del Art. 2)

> *Nota: el enunciado lo enmarca como "Artículo 13". Conforme al texto vigente, el deber técnico de
> seguridad corresponde al **Art. 31** y el principio de seguridad al **Art. 2**; la justificación
> aplica igual.*

El deber de seguridad exige medidas **proporcionales al riesgo** de los datos. Como CREATIC maneja
datos sensibles y financieros, el riesgo es alto y exige autenticación fuerte:

1. **Mitiga el vector real del caso:** las credenciales administrativas de CREATIC ya estuvieron en
   la Dark Web. El **MFA** (Keycloak con TOTP/WebAuthn) impide que una contraseña robada baste para
   acceder — exige un segundo factor en posesión del titular legítimo.
2. **Resistencia a phishing:** con **WebAuthn/passkeys**, el segundo factor se liga al dominio,
   neutralizando el spear-phishing/vishing a docentes (vector inicial del caso y de M-Trends 2026).
3. **Proporcionalidad:** el MFA se exige especialmente para acceder a la VLAN 10 (datos sensibles) y
   a la gestión, alineando la intensidad del control con la sensibilidad del dato.
4. **Verificación continua (Zero Trust):** el acceso se reevalúa con la postura del dispositivo,
   sosteniendo el deber de seguridad en el tiempo, no como un control de una sola vez.

---

## 4. Política de retención de logs conforme a la Ley 81 (implementación en el SIEM)

| Aspecto | Definición | Implementación técnica en Wazuh |
|---|---|---|
| **Qué se retiene** | Logs de autenticación, acceso a datos, alertas y auditoría de los 4 servidores | Ingesta vía Wazuh Agent (Syslog + Windows Event) |
| **Plazo de retención** | Conforme a la Ley 81 / lineamientos ANTAI; se propone **≥ 12 meses** en caliente + archivado para el plazo legal completo *(confirmar plazo en el Decreto 285/2021)* | *Index State Management* del Wazuh Indexer (hot → warm → cold/archive) |
| **Integridad** | Los registros no deben poder alterarse (valor probatorio ante la ANTAI) | Acceso estricto (VLAN 99) + *hashing*/firma de los índices de archivo |
| **Confidencialidad** | Los logs pueden contener datos personales | Cifrado del almacenamiento del Indexer + acceso solo con MFA |
| **Disponibilidad para auditoría** | La ANTAI o una investigación pueden requerirlos | Exportación desde el Wazuh Dashboard |
| **Supresión al vencer** | Borrado seguro tras el plazo (minimización) | Política automática de borrado del índice al expirar |

> El SIEM **sostiene el cumplimiento legal** (trazabilidad, integridad y plazos), no solo la detección.

---

## 5. Notificación de brechas (Decreto 285/2021) — enlace con el IRP

La notificación de incidentes (plazo ≈ **72 horas** según el reglamento) se ejecuta desde el
**IRP (M7)**: el rol *Responsable Legal/Comunicaciones* notifica a la ANTAI y a los titulares
afectados, con la naturaleza del incidente, los datos comprometidos y las acciones correctivas.
Los **logs retenidos (Wazuh)** aportan la evidencia.

---

## 6. Resumen de controles del Módulo 6 (para la matriz de trazabilidad)

- Medidas de seguridad (Art. 31) / principio de seguridad (Art. 2) → MFA Keycloak + cifrado → M2, M5
- Diligencia (Art. 14) → hardening + SOC → M5, M3
- Derechos ARCO (Art. 15, 21) → política ARCO → anexo
- Notificación de brechas (Decreto 285) → IRP → M7
- Régimen sancionatorio (Arts. 42–43) → controles integrales → todo el repo

**Sources / referencias web consultadas:**
- [ANTAI — Ley 81 entra en vigencia](https://antai.gob.pa/ley-81-de-proteccion-de-datos-personales-entra-en-vigencia-en-panama/)
- [Texto oficial Ley 81 (Asamblea Nacional / Gaceta Oficial 28743-A)](https://s3-legispan.asamblea.gob.pa/legispan/NORMAS/2010/2019/LEY/Administrador%20Legispan_28743-A_2019_3_29_ASAMBLEA%20NACIONAL_81.pdf)
- [Decreto Ejecutivo 285 de 2021 (reglamento)](http://gacetas.procuraduria-admon.gob.pa/29296-A_56425.pdf)
