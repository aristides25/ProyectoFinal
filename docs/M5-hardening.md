# Módulo 5 — Automatización de Hardening

> **Peso en la rúbrica: 20%** (Calidad y lógica de los scripts). Marcos: **CIS Benchmarks**
> (Windows Server / Linux) y **NIST SP 800-123**. Código real en [`ansible/`](../ansible) y
> [`powershell/`](../powershell). **No son recomendaciones en texto plano: es infraestructura
> como código, ejecutable, parametrizada y verificada.**

---

## 1. Los 3 criterios de aceptación (cómo se cumplen)

| Criterio | Cómo se implementa |
|---|---|
| **1. Parametrización** | Linux: todas las variables en `ansible/group_vars/all.yml`. Windows: bloque `param()` al inicio del `.ps1`. **Cero valores hardcodeados** en la lógica. |
| **2. Comentarios en español** | Cada bloque lógico lleva un comentario `# qué / para qué` explicando la intención y la justificación de seguridad. |
| **3. Verificación post-hardening** | Linux: `ansible/tasks/verify.yml` con `assert` que **falla el playbook** si el estado no se cumple. Windows: bloque final de validación que reporta `[OK]`/`[FALLO]` y devuelve `exit 1` si algo falla. |

---

## 2. Hardening Linux — Playbook de Ansible (CR-APPSRV-02, CR-DB-01)

### 2.1 Estructura (patrón roles/tasks/handlers)

```
ansible/
├── inventory.ini            # hosts agrupados (linux_servers / windows_servers)
├── group_vars/all.yml       # TODAS las variables parametrizadas
├── hardening-linux.yml      # playbook principal (orquesta los bloques)
├── tasks/
│   ├── firewall.yml         # ufw: deny por defecto + lista blanca
│   ├── ssh.yml              # root off, puerto, clave pública
│   ├── servicios.yml        # deshabilitar servicios innecesarios
│   ├── remediacion.yml      # CR-DB-01: cifrado at-rest + aislamiento
│   └── verify.yml           # asserts de verificación
└── handlers/main.yml        # reinicios idempotentes (sshd, mysql)
```

### 2.2 Decisiones de diseño clave

- **Orden firewall → SSH:** se abre el puerto SSH nuevo (`2222`) en `ufw` **antes** de reiniciar
  `sshd`, evitando quedar bloqueados fuera del servidor (un error clásico de hardening remoto).
- **`validate: 'sshd -t -f %s'`:** cada cambio en `sshd_config` se valida sintácticamente **antes**
  de guardar; si la config es inválida, Ansible no la aplica.
- **Idempotencia:** los `handlers` reinician servicios **solo** cuando el archivo cambió.

### 2.3 Acciones del playbook (mapeadas al inventario)

| Acción | Vulnerabilidad remediada | Archivo |
|---|---|---|
| Deshabilitar login directo de root por SSH | "root + contraseña en puerto 22" (CR-APPSRV-02) | `tasks/ssh.yml` |
| Cambiar puerto SSH (22 → `{{ ssh_puerto }}`) | Reducir superficie/ruido de escaneos | `tasks/ssh.yml` |
| Exigir clave pública (sin contraseñas) | Credential stuffing / fuerza bruta | `tasks/ssh.yml` |
| Deshabilitar servicios innecesarios | Superficie de ataque (NIST 800-123) | `tasks/servicios.yml` |
| Firewall local `ufw` (deny + lista blanca) | Falta de control de host | `tasks/firewall.yml` |
| **Cifrado at-rest InnoDB** en CR-DB-01 | "Sin cifrado de datos en reposo" | `tasks/remediacion.yml` |
| **Aislar MySQL** (bind-address + 3306 solo desde web) | "Mismo segmento que el web" | `tasks/remediacion.yml` |

### 2.4 Ejemplo de parametrización (extracto de `group_vars/all.yml`)

```yaml
ssh_puerto: 2222
usuario_admin: "adminseg"
ssh_permitir_root: "no"
fw_reglas_permitidas:
  - { puerto: "{{ ssh_puerto }}", proto: "tcp", origen: "10.10.99.0/24", desc: "SSH de gestion (VLAN 99)" }
db_bind_address: "10.10.10.13"     # CR-DB-01 escucha solo en su IP de VLAN 10
db_ip_web_autorizada: "10.10.10.12" # unica IP que puede conectar a 3306
```

### 2.5 Verificación (extracto de `tasks/verify.yml`)

```yaml
- name: "VERIFICAR · SSH endurecido (puerto, root y contraseñas)"
  ansible.builtin.assert:
    that:
      - "'Port ' ~ ssh_puerto in ssh_conf.stdout"
      - "'PermitRootLogin ' ~ ssh_permitir_root in ssh_conf.stdout"
    fail_msg: "FALLO: la configuración de SSH no cumple el estado deseado."
```

> **Ejecución:** `ansible-playbook -i inventory.ini hardening-linux.yml`
> (tras el primer run, reconectar con `-e "ansible_port=2222"`).

---

## 3. Hardening Windows — Script PowerShell (CR-DC-01, CR-FILE-03)

### 3.1 Acciones (mapeadas al inventario)

| Acción | Vulnerabilidad remediada | Técnica |
|---|---|---|
| **Deshabilitar SMBv1** por completo | "SMBv1 activo" (CR-DC-01) — riesgo de ransomware | `Set-SmbServerConfiguration` + `Disable-WindowsOptionalFeature` |
| Políticas de contraseñas complejas | Credenciales débiles | `net accounts` + `secedit` (PasswordComplexity=1) |
| Inhabilitar cuenta **Guest** | Acceso anónimo | `Disable-LocalUser` |
| Corregir permisos **"Everyone"** | "Carpetas legibles por Everyone" (CR-FILE-03) | `icacls` (remueve S-1-1-0, concede al grupo autorizado) |

### 3.2 Parametrización (extracto de `param()`)

```powershell
param(
    [string[]] $CarpetasCriticas   = @('C:\DatosAdministracion'),
    [string]   $GrupoAutorizado    = 'CREATIC\Administracion_RW',
    [int]      $LongitudMinimaPwd  = 14,
    [int]      $VigenciaMaximaPwd  = 60,
    [string]   $CuentaInvitado     = 'Guest'
)
```

### 3.3 Detalle técnico importante: permisos por SID

La remoción de "Everyone" usa el **SID bien conocido `S-1-1-0`** en lugar del nombre, para que
funcione **independientemente del idioma del SO** (en Windows en español sería "Todos"). Es una
decisión de robustez real:

```powershell
icacls $carpeta /remove:g "*S-1-1-0" /T /C        # quita Everyone/Todos por SID
icacls $carpeta /grant "${GrupoAutorizado}:(OI)(CI)M" /T /C  # mínimo privilegio
```

### 3.4 Verificación (bloque final)

El script confirma cada cambio con `Get-SmbServerConfiguration`, `net accounts`, `Get-LocalUser`
e `icacls`, imprime `[OK]`/`[FALLO]` por control y termina en `exit 1` si algo no se aplicó.

> **Nota de codificación:** el `.ps1` se guarda en **UTF-8 con BOM**; en PowerShell 5.1 un script
> con acentos sin BOM se interpreta como ANSI y corrompe el texto en consola. (Verificado: el
> parser de PowerShell valida el script sin errores de sintaxis.)

---

## 4. Resumen de controles del Módulo 5 (para la matriz de trazabilidad)

- Líneas base de SO → CIS Benchmarks / NIST 800-123 → `ansible/`, `powershell/`
- Cifrado at-rest + aislamiento → NIST 800-207 (Datos) / Ley 81 (Art. 31) → `ansible/tasks/remediacion.yml`
- Verificación post-cambio → criterio de aceptación → `ansible/tasks/verify.yml`, bloque PS final
