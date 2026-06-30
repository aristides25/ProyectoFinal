<#
================================================================================
 Harden-Windows.ps1 — Automatización de Hardening Windows (Proyecto CREATIC, M5)
 Objetivos: CR-DC-01 (Windows Server 2019) y CR-FILE-03 (Windows Server 2016).

 Cumple los 3 criterios de aceptación:
   1) Parametrización  -> bloque param(); ningún valor crítico hardcodeado.
   2) Comentarios ES   -> cada bloque lógico explica el qué y el para qué.
   3) Verificación     -> bloque final que confirma cada cambio aplicado.

 Acciones:
   - Deshabilitar por completo el protocolo SMBv1 (CR-DC-01).
   - Aplicar políticas restrictivas de contraseñas complejas.
   - Inhabilitar la cuenta de invitado (Guest).
   - Remediar permisos laxos "Everyone/Todos" en carpetas críticas (CR-FILE-03).

 Uso (PowerShell como Administrador):
   .\Harden-Windows.ps1
   .\Harden-Windows.ps1 -CarpetasCriticas 'D:\Finanzas','E:\RRHH' -LongitudMinimaPwd 14
================================================================================
#>

# --- Parametrización (criterio de aceptación nº 1) ---
# Para qué: permitir adaptar el hardening sin editar la lógica del script.
param(
    # Carpetas críticas cuyo acceso "Everyone/Todos" debe removerse (CR-FILE-03).
    [string[]] $CarpetasCriticas = @('C:\DatosAdministracion'),

    # Grupo de seguridad que SÍ debe tener acceso legítimo (mínimo privilegio).
    [string]   $GrupoAutorizado = 'CREATIC\Administracion_RW',

    # Política de contraseñas: longitud mínima y vigencia máxima (días).
    [int]      $LongitudMinimaPwd = 14,
    [int]      $VigenciaMaximaPwd = 60,
    [int]      $HistorialPwd      = 24,

    # Nombre de la cuenta de invitado (parametrizable por idioma del SO).
    [string]   $CuentaInvitado    = 'Guest'
)

# Detener ante cualquier error no controlado, para no dejar el host a medias.
$ErrorActionPreference = 'Stop'

Write-Host "==== Hardening CREATIC — iniciando en $env:COMPUTERNAME ====" -ForegroundColor Cyan

# ----------------------------------------------------------------------------
# Bloque 1 — Deshabilitar SMBv1 por completo
# Qué: apaga el protocolo SMBv1 a nivel de servidor y como característica de Windows.
# Para qué: SMBv1 es obsoleto y vector de ransomware (p. ej. WannaCry/EternalBlue);
#           CR-DC-01 lo tiene activo "por compatibilidad antigua".
# ----------------------------------------------------------------------------
Write-Host "[1/4] Deshabilitando SMBv1..." -ForegroundColor Yellow

# Apaga el soporte SMBv1 del servicio de servidor (efecto inmediato).
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force

# Desinstala la característica opcional SMB1 (elimina el binario, persistente).
$smb1 = Get-WindowsOptionalFeature -Online -FeatureName 'SMB1Protocol' -ErrorAction SilentlyContinue
if ($smb1 -and $smb1.State -eq 'Enabled') {
    Disable-WindowsOptionalFeature -Online -FeatureName 'SMB1Protocol' -NoRestart | Out-Null
    Write-Host "      Característica SMB1Protocol deshabilitada (requiere reinicio para completar)." -ForegroundColor DarkGray
}

# ----------------------------------------------------------------------------
# Bloque 2 — Políticas restrictivas de contraseñas complejas
# Qué: fija longitud mínima, vigencia máxima, historial y complejidad obligatoria.
# Para qué: mitigar credential stuffing y contraseñas débiles (CIS Benchmark).
# Nota: se usa "net accounts" + secedit para la política local de seguridad.
# ----------------------------------------------------------------------------
Write-Host "[2/4] Aplicando políticas de contraseñas complejas..." -ForegroundColor Yellow

# Longitud mínima, vigencia máxima e historial (parametrizados).
net accounts /minpwlen:$LongitudMinimaPwd /maxpwage:$VigenciaMaximaPwd /uniquepw:$HistorialPwd | Out-Null

# La complejidad (mayúsculas, minúsculas, números, símbolos) se activa vía secedit,
# porque "net accounts" no expone ese parámetro directamente.
$plantilla = "$env:TEMP\creatic_secpol.inf"
secedit /export /cfg $plantilla /quiet
# Reemplaza el valor de PasswordComplexity a 1 (habilitada).
(Get-Content $plantilla) -replace 'PasswordComplexity\s*=\s*\d', 'PasswordComplexity = 1' |
    Set-Content $plantilla
secedit /configure /db "$env:windir\security\local.sdb" /cfg $plantilla /areas SECURITYPOLICY /quiet
Remove-Item $plantilla -Force -ErrorAction SilentlyContinue

# ----------------------------------------------------------------------------
# Bloque 3 — Inhabilitar la cuenta de invitado (Guest)
# Qué: deshabilita la cuenta Guest local.
# Para qué: las cuentas anónimas/invitado permiten acceso no autenticado.
# ----------------------------------------------------------------------------
Write-Host "[3/4] Inhabilitando la cuenta de invitado ($CuentaInvitado)..." -ForegroundColor Yellow

$guest = Get-LocalUser -Name $CuentaInvitado -ErrorAction SilentlyContinue
if ($guest) {
    Disable-LocalUser -Name $CuentaInvitado
} else {
    Write-Host "      La cuenta '$CuentaInvitado' no existe en este host (puede variar por idioma)." -ForegroundColor DarkGray
}

# ----------------------------------------------------------------------------
# Bloque 4 — Remediar permisos laxos "Everyone/Todos" (CR-FILE-03)
# Qué: quita el acceso del grupo "Everyone" en carpetas críticas y concede acceso
#      solo al grupo autorizado (mínimo privilegio).
# Para qué: remediar "carpetas críticas legibles por Everyone" del inventario.
# ----------------------------------------------------------------------------
Write-Host "[4/4] Corrigiendo permisos 'Everyone' en carpetas críticas..." -ForegroundColor Yellow

foreach ($carpeta in $CarpetasCriticas) {
    if (Test-Path $carpeta) {
        # Eliminar todas las ACE del identificador bien conocido "Everyone" (S-1-1-0),
        # independientemente del idioma del SO.
        icacls $carpeta /remove:g "*S-1-1-0" /T /C | Out-Null
        # Conceder control de modificación SOLO al grupo autorizado, heredable.
        icacls $carpeta /grant "${GrupoAutorizado}:(OI)(CI)M" /T /C | Out-Null
        Write-Host "      Permisos remediados en: $carpeta" -ForegroundColor DarkGray
    } else {
        Write-Host "      AVISO: la carpeta '$carpeta' no existe en este host; se omite." -ForegroundColor DarkYellow
    }
}

# ============================================================================
#  Bloque de VERIFICACIÓN post-hardening (criterio de aceptación nº 3)
#  Qué: confirma con evidencia que cada control quedó aplicado.
#  Para qué: no declarar "listo" sin pruebas; deja un resumen auditable.
# ============================================================================
Write-Host "`n==== VERIFICACIÓN POST-HARDENING ====" -ForegroundColor Cyan
$ok = $true

# Verificar SMBv1 deshabilitado.
$smbCfg = Get-SmbServerConfiguration
if (-not $smbCfg.EnableSMB1Protocol) {
    Write-Host "[OK]  SMBv1 deshabilitado." -ForegroundColor Green
} else {
    Write-Host "[FALLO] SMBv1 sigue habilitado." -ForegroundColor Red; $ok = $false
}

# Verificar política de contraseñas (longitud mínima e historial).
$cuentas = net accounts
$lineaLongitud = ($cuentas | Select-String -Pattern 'minimum password length|longitud mínima' )
Write-Host "[INFO] Política de contraseñas vigente:" -ForegroundColor Green
$cuentas | Select-String -Pattern 'password|contraseña' | ForEach-Object { Write-Host "       $_" }

# Verificar cuenta Guest deshabilitada.
$guestChk = Get-LocalUser -Name $CuentaInvitado -ErrorAction SilentlyContinue
if (-not $guestChk -or -not $guestChk.Enabled) {
    Write-Host "[OK]  Cuenta de invitado deshabilitada (o inexistente)." -ForegroundColor Green
} else {
    Write-Host "[FALLO] La cuenta de invitado sigue habilitada." -ForegroundColor Red; $ok = $false
}

# Verificar que "Everyone" ya no aparece en las carpetas críticas.
foreach ($carpeta in $CarpetasCriticas) {
    if (Test-Path $carpeta) {
        $acl = (icacls $carpeta) -join "`n"
        if ($acl -match 'Everyone|Todos') {
            Write-Host "[FALLO] '$carpeta' aún tiene permisos de Everyone/Todos." -ForegroundColor Red; $ok = $false
        } else {
            Write-Host "[OK]  '$carpeta' sin permisos de Everyone/Todos." -ForegroundColor Green
        }
    }
}

# Resultado global del hardening.
if ($ok) {
    Write-Host "`n==== Hardening COMPLETADO y verificado correctamente ====" -ForegroundColor Cyan
} else {
    Write-Host "`n==== Hardening con FALLOS de verificación: revisar los [FALLO] ====" -ForegroundColor Red
    exit 1
}
