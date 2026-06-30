# Presentación Ejecutiva — Defensa ante la Junta Directiva de CREATIC
### Guion de diapositivas (15 minutos máx.)

> Audiencia: Alta Gerencia (no técnica) + el docente como Director de Tecnología.
> Objetivo: aprobar la arquitectura y demostrar dominio bajo presión.
> Regla de oro: hablar de **riesgo de negocio y costo**, no solo de tecnología.

---

### Slide 1 — Portada (15 s)
Plan Integral de Ciberseguridad CREATIC · Zero Trust + Defensa en Profundidad · Costo de
licencias: **$0**. Grupo 1M3213.

### Slide 2 — El problema en números (1 min)
Lo que ya pasó: spear-phishing a docentes, credenciales admin en la Dark Web, ransomware,
caídas por falta de control. Mensaje: **"el modelo de castillo está roto; cada incidente tiene
costo financiero, legal (Ley 81) y reputacional."**

### Slide 3 — Nuestro enfoque (1 min)
Tres principios Zero Trust: **verificar continuamente · mínimo privilegio · asumir la brecha**.
Más Defensa en Profundidad. Todo con Open Source de nivel empresarial.

### Slide 4 — Antes vs Después (2 min) ⭐
Diagrama `topologia-antes` vs `topologia-despues` lado a lado. Señalar: de **1 red plana** a
**6 segmentos** con NGFW e IPS. *"El servidor web y la base de finanzas ya no son vecinos."*

### Slide 5 — Identidad y acceso (1.5 min)
ZTNA (Headscale) reemplaza la VPN insegura; **MFA** (Keycloak) + postura del dispositivo.
Diagrama `flujo-auth-mfa`. *"Una contraseña robada ya no basta para entrar."*

### Slide 6 — Visibilidad: el SOC (1.5 min)
Wazuh (SIEM/EDR) vigila los 4 servidores; 4 reglas de correlación mapeadas a MITRE ATT&CK.
*"Ahora vemos el ataque mientras ocurre, no meses después."* MTTD objetivo < 1 h.

### Slide 7 — Desarrollo seguro (1.5 min)
Pipeline CI/CD con SAST/DAST/SCA reemplaza el FTP manual. Caso RCE de la librería PDF:
*"lo detectamos en el pipeline; y si llegara a pasar, la segmentación impide que toque finanzas."*

### Slide 8 — Hardening automatizado (1 min)
Ansible + PowerShell: código real, parametrizado, verificado. *"No son recomendaciones en papel;
es automatización ejecutable y auditable."*

### Slide 9 — Cumplimiento legal (1 min)
Ley 81 / ANTAI: MFA (Art. 13), cifrado, retención de logs. Tabla de mapeo norma→control.
*"Blindaje legal: podemos demostrar diligencia ante una auditoría."*

### Slide 10 — Riesgo: antes y después (1.5 min) ⭐
Matriz de riesgos: todos los **críticos** bajan a medio/bajo. Mostrar 3–4 filas clave.
*"Reducción medible del riesgo, no promesas."*

### Slide 11 — Viabilidad económica (1 min) ⭐
Tabla comercial vs Open Source: **$0 en licencias**. *"Misma capacidad que Palo Alto/Splunk/
CrowdStrike, sin su costo de licenciamiento."*

### Slide 12 — Hoja de ruta + cierre (1 min)
Quick wins → columna vertebral → visibilidad → desarrollo seguro. Pedir aprobación.

### Slide 13 (oculta) — IRP de bolsillo para el incidente sorpresa ⭐⭐
Tabla de **3 acciones de contención** por tipo de incidente (de `docs/M7-riesgos-irp.md` §4).
Tener esta slide lista para abrir cuando el Director inyecte el incidente.

---

## Tips de defensa
- Lleva impreso/visible el **playbook de contención** (M7 §4): es tu red de seguridad.
- Cada respuesta técnica termina con **"…y eso está implementado en `<archivo>`"** (trazabilidad).
- Si no sabes un dato (p. ej. página de Mandiant), dilo y remite al informe; no inventes.
</content>
