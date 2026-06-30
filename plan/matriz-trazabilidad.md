# Matriz de Trazabilidad — Marco → Control → Entregable

> Artefacto transversal y vivo. Demuestra que **cada marco de referencia exigido por el
> profesor** (sección "Material de Referencia") se traduce en un control concreto y en un
> entregable verificable del repositorio. Es la herramienta principal para la defensa: ante
> cualquier pregunta, se localiza el marco, el control y el archivo que lo implementa.

## 1. Trazabilidad por marco de referencia

| Marco de referencia | Pilar / Control que aporta | Entregable que lo implementa | Módulo |
|---|---|---|---|
| **NIST SP 800-207** (Zero Trust Architecture) | Modelo conceptual ZT: verificación continua, mínimo privilegio, asumir la brecha | `docs/M2-arquitectura.md`, `diagramas/topologia-despues.mmd` | M2 |
| **CISA Zero Trust Maturity Model v2.0** | 5 pilares: Identidad, Dispositivos, Redes, Aplicaciones, Datos | `docs/M2-arquitectura.md` (tabla de madurez por pilar) | M2 |
| **CIS Benchmarks** (Windows Server / Linux) | Líneas base de configuración segura por SO | `ansible/hardening-linux.yml`, `powershell/Harden-Windows.ps1` | M5 |
| **NIST SP 800-123** (General Server Security) | Defensa en profundidad a nivel de SO y servicios | `ansible/tasks/*.yml`, `powershell/Harden-Windows.ps1` | M5 |
| **OWASP Top 10 / OWASP ASVS** | Verificación de seguridad de aplicaciones; diseño de SAST/DAST | `cicd/pipeline.yml`, `docs/M4-secdevops.md` | M4 |
| **CISA/NIST — Defending Against Software Supply Chain Attacks** | Gestión de riesgo de dependencias de terceros; análisis SCA | `cicd/pipeline.yml` (Trivy/Dependabot), `docs/M4-secdevops.md` | M4 |
| **Mandiant M-Trends 2026** | Inteligencia táctica de amenazas (citar nº de página) | `docs/M1-amenazas.md` | M1 |
| **MITRE ATT&CK** | Mapeo de TTPs: phishing, credential stuffing, movimiento lateral | `docs/M1-amenazas.md`, `siem/reglas-correlacion.xml` | M1, M3 |
| **NIST SP 800-30 / ISO 27005** | Metodología de matriz de riesgos | `docs/M7-riesgos-irp.md` | M7 |
| **NIST SP 800-61 Rev. 2** (Incident Handling) | Ciclo de vida del IRP; roles CSIRT; MTTR/MTTD | `docs/M7-riesgos-irp.md` | M7 |
| **Ley 81 de 2019 (Panamá)** | Derechos ARCO, régimen sancionatorio ANTAI, deber de seguridad técnica | `docs/M6-cumplimiento-ley81.md` | M6 |

## 2. Trazabilidad de controles técnicos (control → marco → archivo)

| Control técnico | Marco que lo respalda | Implementado en |
|---|---|---|
| Microsegmentación por VLANs (10/20/30/40/50/99) | CISA ZTMM pilar Redes; NIST 800-207 | `docs/M2-arquitectura.md`, `diagramas/topologia-despues.mmd` |
| NGFW con IPS/IDS (OPNsense + Suricata) | CISA ZTMM pilar Redes | `docs/M2-arquitectura.md` |
| ZTNA con MFA y postura del dispositivo (Headscale + Keycloak) | CISA ZTMM pilares Identidad/Dispositivos; Ley 81 Art. 13 | `docs/M2-arquitectura.md`, `diagramas/flujo-auth-mfa.mmd` |
| Deshabilitar root-SSH + cambiar puerto SSH | CIS Benchmark Linux; NIST 800-123 | `ansible/tasks/ssh.yml` |
| Firewall local parametrizado (ufw/iptables) | CIS Benchmark Linux | `ansible/tasks/firewall.yml` |
| Cifrado at-rest CR-DB-01 + aislamiento de segmento | NIST 800-207 (Datos); Ley 81 | `ansible/tasks/remediacion.yml` |
| Deshabilitar SMBv1 | CIS Benchmark Windows | `powershell/Harden-Windows.ps1` |
| Políticas de contraseña + deshabilitar Guest | CIS Benchmark Windows | `powershell/Harden-Windows.ps1` |
| Corregir permisos "Everyone" en CR-FILE-03 | CIS Benchmark Windows; mínimo privilegio | `powershell/Harden-Windows.ps1` |
| Ingesta de logs + reglas de correlación (Wazuh) | MITRE ATT&CK; Ley 81 (retención) | `siem/reglas-correlacion.xml`, `docs/M3-soc-siem.md` |
| Pipeline SAST/DAST/SCA | OWASP ASVS; CISA Supply Chain | `cicd/pipeline.yml` |

> **Estado:** matriz inicial creada en M0. Se actualiza al cerrar cada módulo, enlazando
> los archivos reales conforme se generan.
