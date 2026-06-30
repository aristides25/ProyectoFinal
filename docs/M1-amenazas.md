# Módulo 1 — Panorama de Amenazas y relación con el caso CREATIC

> **Peso en la rúbrica: 15%** (junto con M6). Fuentes obligatorias: **Mandiant M-Trends 2026**
> (citar nº de página) + al menos una fuente secundaria (**CISA/ENISA**). Marco de mapeo de
> adversarios: **MITRE ATT&CK**.

> ⚠️ **NOTA DE CITAS — leer antes de entregar.** Los marcadores `[M-Trends 2026, p. ___]`
> deben completarse con los números de página reales de tu copia del informe Mandiant M-Trends
> 2026. No se incluyen números inventados a propósito (rigor académico). Sustituye cada `___`
> por la página correspondiente y, si el dato exacto difiere, ajusta la cifra al informe.

---

## 1. Panorama de amenazas actual (contexto táctico)

El sector educativo es uno de los más atacados: concentra datos personales de miles de
estudiantes, información financiera y de calificaciones, con presupuestos de seguridad
limitados — exactamente el perfil de CREATIC. Las tendencias relevantes:

| Tendencia (M-Trends 2026 / CISA) | Cita | Relevancia para CREATIC |
|---|---|---|
| Predominio del **phishing/ingeniería social** como vector inicial | `[M-Trends 2026, p. ___]` | Spear-phishing exitoso a docentes (caso real de CREATIC) |
| Uso de **credenciales válidas robadas** como vector de acceso | `[M-Trends 2026, p. ___]` | Credenciales admin expuestas en la Dark Web |
| **Ransomware** y tiempo de permanencia (*dwell time*) del atacante | `[M-Trends 2026, p. ___]` | Ransomware en equipos remotos de CREATIC |
| Crecimiento de ataques a **identidad** y MFA-bypass | `[M-Trends 2026, p. ___]` | Justifica MFA resistente a phishing (WebAuthn, M2) |
| Fuente secundaria: avisos de **CISA/ENISA** sobre sector educación | `[CISA, "K-12/Higher-Ed Cybersecurity", URL]` | Refuerza prioridad de segmentación y EDR |

---

## 2. Mapeo de los 3 vectores del caso a MITRE ATT&CK

El enunciado pide mapear **phishing avanzado**, **credential stuffing** y **movimiento lateral**.
Se traducen a técnicas concretas de MITRE ATT&CK y se enlazan con los controles del proyecto:

### 2.1 Phishing avanzado (acceso inicial)

| Táctica / Técnica ATT&CK | Cómo aplica a CREATIC | Control que lo mitiga |
|---|---|---|
| **TA0001 Initial Access** → **T1566** Phishing (T1566.001/.002) | Spear-phishing a docentes con enlaces/adjuntos maliciosos | MFA resistente a phishing (M2), concienciación, filtrado correo |
| **T1204** User Execution | El docente ejecuta el adjunto malicioso | EDR Wazuh en endpoint (M3), control de postura (M2) |

### 2.2 Credential stuffing / cuentas válidas

| Táctica / Técnica ATT&CK | Cómo aplica a CREATIC | Control que lo mitiga |
|---|---|---|
| **T1110** Brute Force (T1110.004 credential stuffing) | Reúso de credenciales filtradas en la Dark Web | MFA (M2) + **regla Wazuh 100010** (M3) |
| **T1078** Valid Accounts | Credenciales admin comprometidas usadas como acceso legítimo | Mínimo privilegio (M2), MFA, alertas de uso anómalo (M3) |

### 2.3 Movimiento lateral (post-explotación)

| Táctica / Técnica ATT&CK | Cómo aplica a CREATIC | Control que lo mitiga |
|---|---|---|
| **TA0008 Lateral Movement** → **T1021** Remote Services | Pivote desde el web server hacia la BD en la red plana | **Microsegmentación VLAN** (M2) + `ufw` (M5) |
| **T1210** Exploitation of Remote Services | Explotar SMBv1 / servicios expuestos | SMBv1 deshabilitado (M5) + **regla Wazuh 100030** (M3) |
| **T1570** Lateral Tool Transfer | Mover herramientas entre hosts | NGFW egress + segmentación (M2) |

> Esta tabla es el **puente entre amenaza y arquitectura**: cada técnica del adversario tiene un
> control nombrado y un archivo del repo que lo implementa (ver matriz de trazabilidad).

---

## 3. Evaluación de la triada CIA de los activos críticos

Impacto potencial sobre **Confidencialidad (C)**, **Integridad (I)** y **Disponibilidad (D)**
de cada activo del inventario (escala Bajo/Medio/Alto/Crítico):

| Activo | Datos/función | C | I | D | Justificación del impacto |
|---|---|---|---|---|---|
| **CR-DB-01** (MySQL finanzas/notas) | Calificaciones y finanzas | **Crítico** | **Crítico** | Alto | Una fuga viola privacidad (Ley 81) y la alteración de notas/finanzas es fraude |
| **CR-DC-01** (DC/DNS/DHCP) | Identidad del dominio | Alto | **Crítico** | **Crítico** | Comprometer el DC = control total del dominio; caída = parálisis de servicios |
| **CR-APPSRV-02** (Portal web) | Servicio académico expuesto | Medio | Alto | Alto | Es la cara expuesta; su compromiso es el trampolín al resto |
| **CR-FILE-03** (archivos admin) | Documentos administrativos | Alto | Alto | Medio | Permisos "Everyone" exponen confidencialidad de RR.HH./admin |

**Lectura Zero Trust:** los activos con C/I crítico (CR-DB-01, CR-DC-01) son los que más se
benefician de microsegmentación, cifrado y MFA. La triada CIA justifica priorizar su protección
y alimenta directamente la **matriz de riesgos del Módulo 7**.

---

## 4. Resumen de controles del Módulo 1 (para la matriz de trazabilidad)

- Inteligencia de amenazas → Mandiant M-Trends 2026 + CISA/ENISA → este documento
- Mapeo de TTPs → MITRE ATT&CK → tablas §2 + reglas Wazuh (M3)
- Evaluación CIA → base para priorización → alimenta M7 (matriz de riesgos)
</content>
