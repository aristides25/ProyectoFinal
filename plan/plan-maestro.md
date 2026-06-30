# Plan Maestro — Proyecto CREATIC

## Objetivo

Diseñar e implementar (conceptual + automatización) una arquitectura integral de
ciberseguridad para el Instituto Tecnológico CREATIC bajo **Zero Trust** y **Defensa en
Profundidad**, mitigando riesgos operativos, financieros y legales. Presupuesto de
licencias = **$0** → solo Open Source de nivel empresarial.

## Stack tecnológico (todo Open Source)

| Área | Elección | Marco que la fundamenta |
|---|---|---|
| NGFW + IPS/IDS (M2) | OPNsense + Suricata | NIST 800-207; CISA ZTMM pilar Redes |
| ZTNA / VPN moderna (M2) | Headscale | CISA ZTMM pilar Dispositivos/Redes |
| MFA / Identidad (M2) | Keycloak | CISA ZTMM pilar Identidad; Ley 81 Art. 13 |
| SIEM / EDR (M3) | Wazuh (Manager/Agent/Indexer/Dashboard) | — |
| CI/CD (M4) | GitHub Actions + Semgrep + OWASP ZAP + Trivy | OWASP Top 10/ASVS; CISA/NIST Supply Chain |
| Hardening (M5) | Ansible + PowerShell | CIS Benchmarks; NIST 800-123 |

## Contrato de variables (valores por defecto parametrizados)

- Puerto SSH destino: `2222` · Usuario admin no-root: `adminseg`
- VLANs: **10** Servidores · **20** Administrativos · **30** Profesores planta ·
  **40** BYOD docentes (cuarentena/postura) · **50** Estudiantes · **99** Gestión/SOC
- Cifrado at-rest CR-DB-01: LUKS (disco) + cifrado de tablespace InnoDB/MariaDB

## Orden de ejecución (por dependencias técnicas)

1. **M0 Cimientos** — estructura repo, README, inventario, matriz de trazabilidad
2. **M2 Arquitectura Zero Trust** — columna vertebral; todo lo demás la referencia
3. **M5 Hardening (código)** — Ansible + PowerShell
4. **M3 SOC/SIEM** — Wazuh: ingesta, reglas de correlación, BYOD
5. **M4 SecDevOps** — pipeline CI/CD + SAST/DAST/SCA + contención del RCE
6. **M1 + M6** — amenazas (Mandiant/MITRE/CISA) + Ley 81 (ARCO/ANTAI)
7. **M7 Riesgos + IRP** — matriz ≥8 riesgos + IRP (NIST 800-61)
8. **M8 Empaque** — documento técnico, presentación ejecutiva, ensayo de defensa

## Reparto de la nota (rúbrica del profesor)

| Componente | Peso |
|---|---|
| Análisis de Amenazas y Cumplimiento Legal (M1+M6) | 15% |
| Arquitectura Zero Trust y Viabilidad Económica (M2) | 25% |
| Automatización del Hardening (M5) | 20% |
| Estrategia SecDevOps y mitigación de vulnerabilidad (M4) | 15% |
| Sustentación Oral y Manejo de Incidentes bajo presión (M7) | 25% |

## Dinámica de defensa (clave)

15 min de exposición. El profesor (como Director de Tecnología) **inyecta un incidente en
vivo**; hay que pausar, abrir el IRP propio y dar **3 acciones exactas de contención**
demostrablemente derivadas del IRP + arquitectura propios. → El M7 se diseña para que cada
acción de contención sea rastreable a una VLAN, una regla de Wazuh o un control de Headscale.
