# CONTEXTO DEL PROYECTO — Plan Integral de Ciberseguridad "CREATIC"

> Documento de contexto para asistirme en el desarrollo de mi proyecto final de la
> **Maestría en Ciencias Computacionales (UTP)** — asignatura Tópicos Especiales.
> Léelo completo antes de proponer o generar nada. Todos los comentarios de código
> deben estar **en español**.

---

## 1. Resumen y objetivo

Debo actuar como un **equipo consultor de ciberseguridad** que diseña e implementa
(a nivel conceptual y de automatización) una arquitectura integral de seguridad para
una institución educativa simulada llamada **Instituto Tecnológico CREATIC**.

La arquitectura debe basarse en los principios de **Zero Trust** (verificar
continuamente, mínimo privilegio, asumir la brecha) y **Defensa en Profundidad**,
mitigando riesgos operativos, financieros y legales.

**Trabajo solo** (aunque formalmente es un proyecto de equipo).

---

## 2. Restricciones críticas (NO negociables)

- **Presupuesto de licencias = $0.** Prohibido proponer soluciones comerciales como
  CrowdStrike, Palo Alto, Splunk, etc. **Todo debe ser Open Source de nivel empresarial**
  (Wazuh, Elastic, Ansible, Headscale/Tailscale, OPNsense/pfSense, Suricata, OWASP ZAP, etc.).
- **No se aceptan listas teóricas de recomendaciones en texto plano.** Hay que entregar
  **código de infraestructura real** (Ansible + PowerShell), limpio y parametrizado.
- Las citas del análisis de amenazas deben referenciar el **Informe Mandiant M-Trends 2026
  con número de página**.

---

## 3. Contexto organizacional

CREATIC evolucionó a un modelo digital híbrido sin una estrategia de seguridad robusta.
En 2025–2026 sufrió: campañas de **spear-phishing** exitosas a docentes, **credenciales
administrativas comprometidas** expuestas en la Dark Web, **ransomware** en equipos
remotos y lentitud crítica por falta de control perimetral. La junta directiva declaró
obsoleto el modelo de "perímetro de castillo".

**Población de usuarios:**
- 120 administrativos/directivos (modelo híbrido).
- 350 profesores: 100 de planta + 250 contratistas en modalidad **BYOD**.
- 5,500 estudiantes activos.

**Modelo de operación:** acceso desde campus, redes domésticas y plataformas SaaS en la nube.

---

## 4. Inventario tecnológico y deuda técnica (estado actual)

| Identificador | Sistema Operativo | Función / Servicio | Vulnerabilidades actuales |
|---|---|---|---|
| **CR-DC-01** | Windows Server 2019 | Controlador de Dominio, DNS y DHCP | Config. por defecto. **SMBv1 activo**. Sin parches hace 6 meses. |
| **CR-APPSRV-02** | Debian 11 | Servidor Web Apache (Portal Académico) | **SSH abierto en puerto 22**. Login por contraseña permitido para **root**. |
| **CR-DB-01** | Debian 11 | Base de Datos MySQL (Calificaciones y Finanzas) | Mismo segmento que el web. **Sin cifrado en reposo (Data at Rest)**. |
| **CR-FILE-03** | Windows Server 2016 | Servidor de archivos (Administración) | Permisos laxos. Carpetas críticas legibles por el grupo **"Everyone"**. |

**Red y comunicaciones:** red completamente **plana** (sin VLANs ni microsegmentación).
Firewall perimetral tradicional (stateful), sin inspección de Capa 7 ni IPS/IDS. Acceso
remoto vía **VPN tradicional PPTP/L2TP** solo con usuario/contraseña, sin verificar la
postura del dispositivo.

**Endpoints:** 120 equipos de oficina con antivirus tradicional basado en firmas
(desactualizado fuera del campus). Los equipos BYOD de docentes **sin control ni
visibilidad institucional**.

**Ciclo de desarrollo:** 3 desarrolladores internos, sin pipelines automatizados.
Despliegues al portal académico (CR-APPSRV-02) mediante **FTP/SCP manual**. Sin auditoría
de código.

---

## 5. Los 7 módulos requeridos

**Módulo 1 — Panorama de Amenazas:** analizar amenazas usando obligatoriamente el
**Informe Mandiant 2026** (citar página) + una fuente secundaria (CISA/ENISA). Mapear
phishing avanzado, credential stuffing y movimiento lateral a CREATIC. Evaluar la triada
**CIA** de los activos críticos.

**Módulo 2 — Arquitectura de Red Moderna (Zero Trust & SASE):** sustituir la red plana por
**microsegmentación (VLANs)**, implementar un **NGFW con IPS/IDS**, y migrar la VPN a un
modelo **ZTNA**. Debe incluir: diagrama de flujo de autenticación con **MFA**, criterio de
evaluación de **postura del dispositivo**, y una solución open source nombrada
(Headscale, Tailscale, Cloudflare WARP o equivalente gratuito).

**Módulo 3 — Operaciones de Seguridad y Endpoints (SOC/SIEM):** integrar un agente
**EDR/SIEM abierto** (Wazuh o Elastic Security) para recolectar logs y centralizar alertas
en un SOC conceptual. Especificar: (a) fuentes de ingesta (mínimo Syslog de los 4 servidores
+ Windows Event logs), (b) **mínimo 3 reglas de correlación/alertas** con criterio de
disparo, (c) arquitectura de componentes nombrada (Manager, Agent, Indexer, Dashboard).
Incluir estrategia de visibilidad para BYOD.

**Módulo 4 — Ciclo de Desarrollo Seguro (SecDevOps):** reemplazar el despliegue manual por
un **pipeline CI/CD** (GitHub Actions o GitLab CI) con **SAST** y **DAST**.
*Inyección de emergencia:* una librería de terceros para generar PDF en el portal tiene una
vulnerabilidad **RCE**. Detallar cómo **SCA** lo previene y cómo la segmentación Zero Trust
evitaría que un atacante alcance **CR-DB-01** tras explotar esa vulnerabilidad.

**Módulo 5 — Automatización de Hardening:** *(núcleo de código — ver sección 7).*

**Módulo 6 — Cumplimiento Regulatorio (Ley 81 Panamá):** anexo normativo que justifique cómo
el cifrado, los controles de identidad (MFA) y la retención de logs cumplen la **Ley 81 de
Protección de Datos Personales**. Incluir: **tabla de mapeo** (Artículo Ley 81 → Control
técnico → Entregable que lo implementa), política de retención de logs conforme a la Ley 81
con su implementación técnica en el SIEM, y justificación de cómo el MFA cumple el principio
de seguridad técnica del **Artículo 13**.

**Módulo 7 — Gestión de Riesgos y Respuesta a Incidentes:** **matriz de riesgos** bajo NIST
SP 800-30 o ISO 27005 (mínimo 8 riesgos, al menos 1 por cada servidor del inventario), con
columnas: *Activo, Amenaza, Vulnerabilidad, Probabilidad (1-5), Impacto CIA (1-5), Riesgo
Inherente, Control Propuesto, Riesgo Residual*. Diseñar un **IRP** (Plan de Respuesta a
Incidentes) con roles del CSIRT interno y métricas **MTTR** y **MTTD**.

---

## 6. Entregables obligatorios

1. **Documento técnico (PDF), 20–30 páginas**, con diagramas de arquitectura que contrasten
   el **Estado Actual (Antes)** vs. el **Estado Propuesto (Después)**.
2. **Repositorio de código (GitHub/GitLab)** con los scripts limpios, parametrizados y
   documentados de **Ansible** y **PowerShell** (Módulo 5).
3. **Presentación ejecutiva** para la defensa ante la junta directiva.

---

## 7. Especificación de código — Módulo 5 (lo más importante para ti, Claude Code)

Hay que generar dos artefactos ejecutables. **Ambos deben cumplir estos criterios de
aceptación obligatorios:**

- **Parametrización:** puertos SSH, usuarios y reglas de firewall deben ser **variables**,
  nunca valores hardcodeados.
- **Comentarios explicativos:** comentario **en español** explicando *el qué* y *el para qué*
  por cada bloque lógico.
- **Verificación post-hardening:** al menos una tarea que **confirme el estado deseado**
  después de aplicar los cambios.

### 7.1 Playbook de Ansible — Linux (objetivos: CR-APPSRV-02 y CR-DB-01)

Debe automatizar:
- Desactivar el **login directo de root** por SSH.
- **Cambiar el puerto por defecto de SSH** (parametrizado).
- Deshabilitar **servicios innecesarios**.
- Configurar el **firewall local** (`ufw` o `iptables`) con reglas parametrizadas.
- **Remediación de vulnerabilidades importantes** del inventario (ej. para CR-DB-01,
  abordar el cifrado de datos en reposo y el aislamiento de segmento).
- Tareas de **verificación** del estado final.

Sugerencia de estructura: usar `group_vars`/`defaults` para las variables, `handlers` para
reinicios de servicios, y un `tasks/verify.yml` o bloque con `assert`/`command` + `register`
para la verificación.

### 7.2 Script de PowerShell — Windows (objetivos: CR-DC-01 y CR-FILE-03)

Debe (ser ejecutable):
- Deshabilitar **por completo el protocolo SMBv1**.
- Aplicar **políticas restrictivas de contraseñas complejas**.
- **Inhabilitar la cuenta de invitado (Guest)**.
- **Remediación de vulnerabilidades importantes** (ej. para CR-FILE-03, corregir los permisos
  laxos de "Everyone" en carpetas críticas).
- Bloque de **verificación** que confirme cada cambio aplicado.

Sugerencia: usar `param()` para los valores configurables, `Write-Host`/`Write-Output`
informativos en español, y un bloque final de validación con `Get-SmbServerConfiguration`,
`Get-LocalUser`, `net accounts`, etc.

---

## 8. Estructura de repositorio sugerida

```
proyecto-creatic/
├── README.md                  # Resumen del proyecto, índice de entregables
├── CONTEXTO_PROYECTO.md       # Este archivo
├── ansible/
│   ├── inventory.ini          # Hosts CR-APPSRV-02, CR-DB-01
│   ├── group_vars/all.yml     # Variables parametrizadas (puerto SSH, usuarios, FW)
│   ├── hardening-linux.yml    # Playbook principal
│   ├── tasks/                 # Tareas modulares (ssh, servicios, firewall, verify)
│   └── handlers/main.yml
├── powershell/
│   └── Harden-Windows.ps1     # Script parametrizado con param() y verificación
├── diagramas/
│   ├── topologia-antes.*      # Estado actual (red plana)
│   └── topologia-despues.*    # Estado Zero Trust propuesto
├── siem/                      # (Módulo 3) reglas de correlación, arquitectura Wazuh
├── cicd/                      # (Módulo 4) pipeline conceptual SAST/DAST/SCA
└── docs/                      # Borradores del documento técnico por módulo
```

---

## 9. Estrategia de avance (orden recomendado, no es 1→7)

El **Módulo 2 (arquitectura)** es la columna vertebral; todo lo demás lo referencia.
El orden de trabajo por dependencias es:

1. **Cimientos:** crear el repo, plantilla del documento, estudiar el inventario,
   conseguir el Mandiant 2026.
2. **Arquitectura Zero Trust (M2):** VLANs, NGFW+IPS/IDS, ZTNA, diagramas Antes/Después. *(25%)*
3. **Hardening / código (M5):** Ansible + PowerShell. Lo más concreto, empezar temprano. *(20%)*
4. **SOC/SIEM (M3):** stack Wazuh/Elastic, ingesta, reglas de correlación, BYOD.
5. **SecDevOps (M4):** pipeline CI/CD, SAST/DAST, SCA, contención del RCE vía Zero Trust. *(15%)*
6. **Amenazas + Ley 81 (M1, M6):** análisis Mandiant, triada CIA, tabla de mapeo legal. *(15%)*
7. **Riesgos + IRP (M7):** matriz ≥8 riesgos, IRP, MTTR/MTTD. *(clave para la defensa)*
8. **Empaquetar:** PDF final, presentación ejecutiva, ensayo de defensa de 15 min y
   respuesta al incidente sorpresa (3 acciones de contención sacadas del propio IRP).

**Reparto aproximado de la nota:** Análisis de amenazas + cumplimiento legal 15% ·
Arquitectura Zero Trust + viabilidad económica 25% · Automatización del hardening 20% ·
SecDevOps + mitigación de vulnerabilidad 15% · Sustentación oral + manejo de incidentes 25%.

---

## 10. Cómo quiero trabajar contigo (Claude Code)

- Empieza creando la **estructura del repositorio** y luego ataquemos el **Módulo 5**
  (Ansible + PowerShell) cumpliendo los criterios de aceptación de la sección 7.
- Pregúntame antes de asumir valores concretos (puerto SSH destino, nombres de usuarios,
  rangos de VLAN) o proponme valores sensatos como variables por defecto.
- Recuerda: **comentarios en español**, **todo parametrizado**, **siempre con verificación
  post-cambio**, y **solo herramientas open source**.
