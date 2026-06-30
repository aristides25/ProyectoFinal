# Módulo 6 — Cumplimiento Regulatorio (Ley 81 de Protección de Datos, Panamá)

> **Peso en la rúbrica: 15%** (junto con M1). Marco: **Ley 81 de 26 de marzo de 2019**
> sobre Protección de Datos Personales (Panamá), supervisada por la **ANTAI**.
> Procesa datos sensibles de estudiantes, calificaciones e información financiera.

> ⚠️ **NOTA DE CITAS LEGALES.** El profesor indica expresamente que el **Artículo 13** consagra
> el principio de seguridad técnica; se usa como dato dado. Los demás números de artículo del
> mapeo siguen la estructura de la Ley 81 (principios, derechos ARCO, deber de seguridad,
> régimen sancionatorio de la ANTAI); **confírmalos contra el texto oficial** antes de entregar
> y ajusta el número exacto si difiere. El valor del módulo está en la *trazabilidad
> control↔norma*, que se mantiene aunque se afine la numeración.

---

## 1. Por qué CREATIC está obligada

CREATIC trata **datos personales** (estudiantes, docentes) y **datos sensibles/financieros**
(calificaciones, finanzas). La Ley 81 le impone: principios de tratamiento, garantía de los
**derechos ARCO** (Acceso, Rectificación, Cancelación/Supresión y Oposición), y un **deber de
seguridad** técnico-organizativo. El incumplimiento habilita **sanciones de la ANTAI**.

---

## 2. Tabla de mapeo: Artículo Ley 81 → Control técnico → Entregable

| Artículo / Principio Ley 81 | Exigencia | Control técnico propuesto | Entregable que lo implementa |
|---|---|---|---|
| **Art. 13 — Seguridad de los datos** (dado por el profesor) | Medidas técnicas y organizativas para proteger los datos | **MFA** (Keycloak), control de acceso por identidad, ZTNA | `docs/M2-arquitectura.md`, `diagramas/flujo-auth-mfa.mmd` |
| **Principio de seguridad — cifrado** | Proteger la confidencialidad, incl. en reposo | **Cifrado at-rest** de CR-DB-01 (InnoDB/LUKS) | `ansible/tasks/remediacion.yml` |
| **Principio de confidencialidad / mínimo acceso** | Acceso solo a quien lo necesita | Microsegmentación VLAN + permisos mínimo privilegio (quitar "Everyone") | `docs/M2-arquitectura.md`, `powershell/Harden-Windows.ps1` |
| **Deber de registro / trazabilidad** | Poder auditar el tratamiento y los accesos | **Retención de logs** y auditoría en Wazuh | `siem/`, §4 de este documento |
| **Derechos ARCO (Acceso/Rectificación/Cancelación/Oposición)** | Atender solicitudes del titular | Procedimiento documentado + integridad/disponibilidad de los datos para localizarlos y rectificarlos | Política ARCO (anexo) + cifrado/respaldo |
| **Notificación de brechas** | Informar incidentes que afecten datos | **IRP** con flujo de notificación a la ANTAI y a titulares | `docs/M7-riesgos-irp.md` |
| **Régimen sancionatorio (ANTAI)** | Evitar multas por incumplimiento | Conjunto completo de controles técnicos del proyecto | Todo el repositorio (defensa de diligencia) |

---

## 3. Justificación: cómo el MFA cumple el Artículo 13 (seguridad técnica)

El Artículo 13 exige medidas de seguridad **proporcionales al riesgo** de los datos tratados.
Dado que CREATIC maneja datos sensibles y financieros, el riesgo es alto y exige autenticación
fuerte:

1. **Mitiga el vector real del caso:** las credenciales administrativas de CREATIC ya estuvieron
   expuestas en la Dark Web. El **MFA** (Keycloak con TOTP/WebAuthn) impide que una contraseña
   robada baste para acceder — exige un segundo factor en posesión del titular legítimo.
2. **Resistencia a phishing:** con **WebAuthn/passkeys**, el segundo factor está ligado al
   dominio, neutralizando el spear-phishing dirigido a docentes (vector inicial del caso).
3. **Proporcionalidad:** el MFA se aplica especialmente al acceso a la VLAN 10 (servidores con
   datos sensibles) y a la gestión, alineando la *intensidad del control* con la *sensibilidad
   del dato* — exactamente el criterio de proporcionalidad del Art. 13.
4. **Verificación continua (Zero Trust):** no es un control de una sola vez; el acceso se
   reevalúa con postura del dispositivo, reforzando el deber de seguridad sostenido.

---

## 4. Política de retención de logs conforme a la Ley 81 (implementación en el SIEM)

| Aspecto | Definición | Implementación técnica en Wazuh |
|---|---|---|
| **Qué se retiene** | Logs de autenticación, acceso a datos, alertas de seguridad, auditoría de los 4 servidores | Ingesta vía Wazuh Agent (Syslog + Windows Event) |
| **Plazo de retención** | Conforme a los plazos de la Ley 81 / lineamientos ANTAI `[confirmar plazo exacto]`; se propone **≥ 12 meses** en caliente + archivado para el plazo legal completo | *Index State Management* del Wazuh Indexer (hot → warm → cold/archive) |
| **Integridad** | Los registros no deben poder alterarse (valor probatorio) | Almacenamiento con control de acceso estricto (VLAN 99), *hashing*/firmas de los índices de archivo |
| **Confidencialidad** | Los logs pueden contener datos personales | Cifrado del almacenamiento del Indexer + acceso solo a administradores con MFA |
| **Disponibilidad para auditoría** | La ANTAI o una investigación pueden requerirlos | Dashboards y exportación desde el Wazuh Dashboard |
| **Supresión al vencer el plazo** | Borrado seguro tras cumplir el plazo (minimización) | Política automática de borrado del Indexer al expirar el índice |

> Esta política **cierra el círculo** con M3: el SIEM no solo detecta, también **sostiene el
> cumplimiento legal** (trazabilidad, integridad y plazos de los registros).

---

## 5. Resumen de controles del Módulo 6 (para la matriz de trazabilidad)

- Seguridad técnica (Art. 13) → MFA Keycloak → M2
- Cifrado de datos → at-rest InnoDB/LUKS → M5 (`remediacion.yml`)
- Mínimo privilegio → microsegmentación + permisos → M2, M5
- Retención e integridad de logs → Wazuh Indexer → M3 + §4
- Notificación de brechas → IRP → M7
</content>
