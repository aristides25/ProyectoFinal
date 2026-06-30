# Proyecto CREATIC — Plan Integral de Ciberseguridad

> **Maestría en Ciencias Computacionales — UTP · Tópicos Especiales**
> Prof. Xavier Trujillo · Grupo 1M3213
> Diseño e Implementación de un Plan Integral de Ciberseguridad para el
> **Instituto Tecnológico CREATIC** bajo principios de **Zero Trust** y **Defensa en Profundidad**.

Toda la solución usa **exclusivamente herramientas Open Source de nivel empresarial**
(presupuesto de licencias = $0). Los comentarios de código están en español, todo está
parametrizado y cada cambio incluye verificación post-aplicación.

---

## Índice de entregables

| # | Entregable | Ubicación |
|---|---|---|
| — | Contexto del proyecto (resumen) | [`CONTEXTO_PROYECTO.md`](CONTEXTO_PROYECTO.md) |
| — | Plan maestro + estrategia | [`plan/plan-maestro.md`](plan/plan-maestro.md) |
| — | Matriz de trazabilidad marco → control → entregable | [`plan/matriz-trazabilidad.md`](plan/matriz-trazabilidad.md) |
| M1 | Panorama de amenazas (Mandiant 2026 + MITRE ATT&CK + CISA) | [`docs/M1-amenazas.md`](docs/M1-amenazas.md) |
| M2 | Arquitectura de red moderna (Zero Trust & SASE) | [`docs/M2-arquitectura.md`](docs/M2-arquitectura.md) · [`diagramas/`](diagramas/) |
| M3 | Operaciones de seguridad (SOC/SIEM Wazuh) | [`docs/M3-soc-siem.md`](docs/M3-soc-siem.md) · [`siem/`](siem/) |
| M4 | Ciclo de desarrollo seguro (SecDevOps) | [`docs/M4-secdevops.md`](docs/M4-secdevops.md) · [`cicd/`](cicd/) |
| M5 | Automatización de hardening (código real) | [`ansible/`](ansible/) · [`powershell/`](powershell/) |
| M6 | Cumplimiento regulatorio (Ley 81 Panamá) | [`docs/M6-cumplimiento-ley81.md`](docs/M6-cumplimiento-ley81.md) |
| M7 | Gestión de riesgos y respuesta a incidentes (IRP) | [`docs/M7-riesgos-irp.md`](docs/M7-riesgos-irp.md) |
| M8 | Documento técnico (plantilla de ensamblaje del PDF) | [`docs/DOCUMENTO-TECNICO.md`](docs/DOCUMENTO-TECNICO.md) |
| M8 | Presentación ejecutiva (guion de slides) | [`docs/PRESENTACION-EJECUTIVA.md`](docs/PRESENTACION-EJECUTIVA.md) |
| M8 | Ensayo de defensa oral + incidente sorpresa | [`docs/DEFENSA-ORAL.md`](docs/DEFENSA-ORAL.md) |

## Estructura del repositorio

```
proyecto-creatic/
├── README.md                  # este archivo
├── CONTEXTO_PROYECTO.md       # contexto y restricciones del proyecto
├── plan/                      # plan maestro + matriz de trazabilidad
├── ansible/                   # M5 · hardening Linux (CR-APPSRV-02, CR-DB-01)
├── powershell/                # M5 · hardening Windows (CR-DC-01, CR-FILE-03)
├── diagramas/                 # topologías Antes/Después + flujo MFA (Mermaid)
├── siem/                      # M3 · arquitectura y reglas de Wazuh
├── cicd/                      # M4 · pipeline CI/CD (SAST/DAST/SCA)
└── docs/                      # un documento por módulo → fuente del PDF final
```

## Stack tecnológico (todo Open Source, $0)

| Área | Herramienta | Módulo |
|---|---|---|
| NGFW + IPS/IDS | OPNsense + Suricata | M2 |
| ZTNA / VPN moderna | Headscale (Tailscale self-hosted) | M2 |
| Identidad / MFA | Keycloak | M2 |
| SIEM / EDR | Wazuh (Manager, Indexer, Dashboard, Agent) | M3 |
| CI/CD | GitHub Actions + Semgrep (SAST) + OWASP ZAP (DAST) + Trivy (SCA) | M4 |
| Hardening | Ansible + PowerShell | M5 |
| Diagramas | Mermaid | transversal |

## Inventario de activos críticos

| ID | SO | Función | Hardening por |
|---|---|---|---|
| CR-DC-01 | Windows Server 2019 | Controlador de Dominio, DNS, DHCP | `powershell/Harden-Windows.ps1` |
| CR-APPSRV-02 | Debian 11 | Servidor Web Apache (Portal Académico) | `ansible/hardening-linux.yml` |
| CR-DB-01 | Debian 11 | Base de Datos MySQL (Calificaciones y Finanzas) | `ansible/hardening-linux.yml` |
| CR-FILE-03 | Windows Server 2016 | Servidor de archivos (Administración) | `powershell/Harden-Windows.ps1` |
</content>
