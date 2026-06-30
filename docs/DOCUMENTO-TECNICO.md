# Plan Integral de Ciberseguridad — Instituto Tecnológico CREATIC
### Documento Técnico Principal · Maestría en Ciencias Computacionales (UTP) · Tópicos Especiales

> **Estructura del PDF final (20–30 páginas).** Este documento es la **plantilla de ensamblaje**:
> el contenido detallado vive en los archivos `docs/M1..M7`. Para producir el PDF, se exportan
> las secciones en este orden (con los diagramas Mermaid renderizados como imágenes).
> Comando sugerido de exportación al final del documento.

---

## Portada

- **Título:** Diseño e Implementación de un Plan Integral de Ciberseguridad para CREATIC
- **Asignatura:** Tópicos Especiales · **Profesor:** Xavier Trujillo · **Grupo:** 1M3213
- **Enfoque:** Zero Trust + Defensa en Profundidad · **Presupuesto de licencias:** $0 (Open Source)

---

## Resumen ejecutivo (1 página)

El Instituto CREATIC migró a un modelo digital híbrido sin una estrategia de seguridad, lo que
derivó en spear-phishing exitoso, credenciales comprometidas, ransomware y una red plana sin
control perimetral moderno. Este proyecto rediseña su seguridad bajo **Zero Trust** (verificar
continuamente, mínimo privilegio, asumir la brecha) y **Defensa en Profundidad**, usando
**exclusivamente herramientas Open Source de nivel empresarial** (costo de licencias = $0).

Las palancas principales: **microsegmentación por VLANs** y **NGFW con IPS/IDS** (OPNsense +
Suricata); **ZTNA con MFA y postura de dispositivo** (Headscale + Keycloak) en reemplazo de la
VPN PPTP/L2TP; **SOC/SIEM** con Wazuh; **pipeline SecDevOps** con SAST/DAST/SCA; **automatización
de hardening** (Ansible + PowerShell); y un marco de **cumplimiento (Ley 81)** y **gestión de
riesgos + respuesta a incidentes** (NIST 800-30/61). El resultado reduce todos los riesgos
críticos a niveles medios/bajos y deja a la institución en condición de defender su diligencia
ante la ANTAI.

---

## Índice y orden de ensamblaje del PDF

| Sección | Contenido | Fuente |
|---|---|---|
| 1 | Resumen ejecutivo | (arriba) |
| 2 | Contexto organizacional e inventario | `CONTEXTO_PROYECTO.md` |
| 3 | **M1** Panorama de amenazas (Mandiant/MITRE/CISA) + triada CIA | `docs/M1-amenazas.md` |
| 4 | **M2** Arquitectura Zero Trust + diagramas Antes/Después | `docs/M2-arquitectura.md` + `diagramas/` |
| 5 | **M5** Automatización de hardening (código) | `ansible/`, `powershell/` + `docs` embebidos |
| 6 | **M3** SOC/SIEM (Wazuh) | `docs/M3-soc-siem.md` + `siem/` |
| 7 | **M4** Ciclo de desarrollo seguro (SecDevOps) | `docs/M4-secdevops.md` + `cicd/` |
| 8 | **M6** Cumplimiento Ley 81 (anexo normativo) | `docs/M6-cumplimiento-ley81.md` |
| 9 | **M7** Gestión de riesgos + IRP | `docs/M7-riesgos-irp.md` |
| 10 | Matriz de trazabilidad marco → control → entregable | `plan/matriz-trazabilidad.md` |
| 11 | Conclusiones y hoja de ruta de implementación | (abajo) |

---

## Contraste Antes / Después (resumen visual para el PDF)

| Dimensión | Estado Actual (Antes) | Estado Propuesto (Después) |
|---|---|---|
| Topología | Red plana única | 6 VLANs microsegmentadas + NGFW inter-VLAN |
| Perímetro | Firewall stateful, sin IPS | OPNsense + Suricata (IPS/IDS, L7) |
| Acceso remoto | VPN PPTP/L2TP, usuario+clave | ZTNA Headscale + MFA + postura |
| Identidad | Sin MFA | Keycloak (TOTP/WebAuthn) |
| Endpoints | AV por firmas; BYOD ciego | EDR Wazuh; BYOD en cuarentena/postura |
| Monitoreo | Inexistente | SOC con Wazuh (SIEM) + reglas ATT&CK |
| Desarrollo | FTP/SCP manual | CI/CD con SAST/DAST/SCA |
| Datos (BD) | Sin cifrado, segmento compartido | Cifrado at-rest + aislamiento 3306 |
| Cumplimiento | Sin marco | Ley 81 mapeada (MFA, cifrado, retención) |

Diagramas: `diagramas/topologia-antes.mmd`, `diagramas/topologia-despues.mmd`,
`diagramas/flujo-auth-mfa.mmd`.

---

## Conclusiones y hoja de ruta

1. **Quick wins (semana 1–2):** hardening automatizado (M5), deshabilitar SMBv1, MFA en accesos
   críticos. Bajo costo, alto impacto.
2. **Columna vertebral (semana 3–6):** microsegmentación VLAN + NGFW + ZTNA (M2).
3. **Visibilidad (semana 5–8):** desplegar Wazuh y las reglas de correlación (M3).
4. **Desarrollo seguro (semana 6–9):** migrar a CI/CD con compuertas (M4).
5. **Gobierno continuo:** operar el SOC, revisar la matriz de riesgos y ensayar el IRP.

**Viabilidad económica:** costo de licencias **$0**; la inversión es en horas de ingeniería y
hardware/VMs existentes — sostenible para una institución educativa.

---

## Cómo exportar a PDF (sugerencia, todo Open Source)

```bash
# 1) Renderizar los diagramas Mermaid a imágenes:
#    npx @mermaid-js/mermaid-cli -i diagramas/topologia-antes.mmd -o diagramas/topologia-antes.png
# 2) Concatenar los Markdown en el orden del índice y convertir con Pandoc:
#    pandoc portada.md resumen.md docs/M1-amenazas.md ... -o CREATIC.pdf
```
