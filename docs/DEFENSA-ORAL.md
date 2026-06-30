# Ensayo de Defensa Oral — Simulacro de 15 minutos + Incidente Sorpresa

> Dinámica del profesor: en cualquier momento detiene la exposición y, como **Director de
> Tecnología**, **inyecta un incidente crítico en vivo**. Hay que pausar, abrir el IRP y dar
> **3 acciones exactas de contención** que **provengan del proyecto propio**.

---

## 1. Distribución del tiempo (15 min)

| Min | Bloque | Slides |
|---|---|---|
| 0–2 | Problema + enfoque Zero Trust | 2–3 |
| 2–5 | Arquitectura Antes/Después + identidad/MFA | 4–5 |
| 5–8 | SOC (Wazuh) + desarrollo seguro (RCE) | 6–7 |
| 8–11 | Hardening + cumplimiento Ley 81 | 8–9 |
| 11–14 | Riesgo (matriz) + viabilidad económica $0 | 10–11 |
| 14–15 | Hoja de ruta + cierre / pedir aprobación | 12 |

> Reservar mentalmente que el incidente puede caer en **cualquier** minuto → estar listo para
> saltar a la slide 13 (playbook de contención).

---

## 2. Protocolo ante el incidente sorpresa (4 pasos)

1. **Pausar y reconocer:** "Activamos nuestro IRP (NIST 800-61). Clasifico severidad y asumo el
   rol de Líder de Incidente."
2. **Abrir el playbook:** ir a `docs/M7-riesgos-irp.md` §4 (tabla pre-mapeada).
3. **Dar 3 acciones atómicas**, cada una **rastreable a un control propio** (ver §3).
4. **Cerrar el lazo:** mencionar detección (Wazuh), notificación ANTAI (Ley 81) y recuperación
   (backups), y retomar la exposición.

---

## 3. Respuestas modelo por incidente (3 acciones, cada una trazable)

**Si dicen "detectamos ransomware cifrando archivos en CR-FILE-03":**
1. *Contener:* aislar la VLAN 10 en el **NGFW OPNsense** (corto el este-oeste) → control M2.
2. *Cortar acceso:* revocar sesiones ZTNA y deshabilitar la cuenta afectada en **Keycloak** → M2.
3. *Erradicar/Detectar:* **active response de Wazuh** mata el proceso y bloquea el IOC; restauro
   desde backup limpio → M3. *(Y SMBv1 ya estaba deshabilitado por el hardening M5, lo que limitó
   la propagación.)*

**Si dicen "hay tráfico anómalo desde el portal web hacia la base de datos de finanzas":**
1. *Contener:* la política base ya bloquea 3306 salvo desde CR-APPSRV-02; **reforzar el bloqueo
   en el NGFW/ufw** → M2/M5.
2. *Cortar acceso:* aislar CR-APPSRV-02 en su VLAN y revocar su identidad → M2.
3. *Detectar:* la **regla Wazuh 100020** ya disparó la alerta; reviso logs retenidos → M3/M6.

**Si dicen "una cuenta de administrador fue comprometida":**
1. *Contener:* forzar cierre de sesión y reset en **Keycloak**, exigir MFA → M2.
2. *Cortar acceso:* revocar tokens ZTNA del usuario y bloquear su acceso a la VLAN 10 → M2.
3. *Detectar:* revisar **reglas 100040/100010** en Wazuh y rotar secretos → M3.

**Si dicen "se explotó el RCE de la librería de PDF en el portal":**
1. *Contener:* aislar CR-APPSRV-02 en VLAN 10 vía NGFW → M2.
2. *Cortar C2:* bloquear el egress a Internet del host en el NGFW → M2.
3. *Erradicar:* disparar el **pipeline SCA (Trivy)** para identificar y parchear la dependencia →
   M4. *(Y la segmentación impidió que el RCE alcanzara CR-DB-01.)*

---

## 4. Preguntas difíciles probables y respuestas

| Pregunta de la junta | Respuesta breve |
|---|---|
| "¿Por qué Open Source y no Palo Alto/Splunk?" | Restricción de $0 en licencias; OPNsense+Suricata+Wazuh dan capacidad equivalente. Mostrar slide 11. |
| "¿Cómo sé que esto realmente funciona?" | Los scripts tienen **verificación post-hardening** y el SIEM mide MTTD/MTTR. Evidencia, no promesas. |
| "¿Y los 250 BYOD que no controlamos?" | Cuarentena por defecto (VLAN 40) + postura + visibilidad por NGFW; acceso condicional mínimo. |
| "¿Esto nos cubre legalmente?" | Sí: tabla de mapeo Ley 81 (MFA Art. 13, cifrado, retención). Demuestra diligencia ante la ANTAI. |
| "¿Cuánto tarda implementarlo?" | Hoja de ruta por fases; quick wins (hardening/MFA) en 1–2 semanas. |

---

## 5. Checklist final antes de exponer

- [ ] Diagramas renderizados (Antes/Después/MFA) visibles.
- [ ] Slide 13 (playbook de contención) lista para abrir.
- [ ] Números de página de Mandiant 2026 completados en M1.
- [ ] Números de artículo de la Ley 81 verificados en M6.
- [ ] Repositorio accesible (enlace) con Ansible/PowerShell.
- [ ] Practicado el salto exposición → incidente → exposición.
</content>
