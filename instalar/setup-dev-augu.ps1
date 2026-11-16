<#
  setup-dev-augu.ps1
  Deja una máquina Windows lista con el estándar de código de Augu:
  Claude Code + Modern Web Guidance + impeccable + Semgrep + gitleaks + auditoría de dependencias.
  Vive en el repo parraau/dev-setup (carpeta instalar/). Cada vez que se corre, primero actualiza el repo.

  Uso (PowerShell normal, sin administrador):
    .\setup-dev-augu.ps1            instala o actualiza todo
    .\setup-dev-augu.ps1 -Verificar solo muestra qué está instalado y qué falta

  Es idempotente: si algo ya está instalado, lo deja o lo actualiza.
#>
param([switch]$Verificar)

$ErrorActionPreference = 'Continue'
$fallas = @()

function Titulo($t) { Write-Host "`n== $t ==" -ForegroundColor Cyan }
function Ok($t)     { Write-Host "  [OK]    $t" -ForegroundColor Green }
function Falta($t)  { Write-Host "  [FALTA] $t" -ForegroundColor Yellow }
function Error2($t) { Write-Host "  [ERROR] $t" -ForegroundColor Red; $script:fallas += $t }

function Refrescar-Path {
  $m = [Environment]::GetEnvironmentVariable('Path', 'Machine')
  $u = [Environment]::GetEnvironmentVariable('Path', 'User')
  $extra = "$env:USERPROFILE\.local\bin;$env:APPDATA\npm"
  $env:Path = "$m;$u;$extra"
}

function Existe($cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }

function Instalar-Winget($id, $cmd, $nombre) {
  if (Existe $cmd) { Ok "$nombre ya instalado"; return }
  if ($Verificar) { Falta $nombre; return }
  Write-Host "  Instalando $nombre..."
  winget install --id $id -e --silent --accept-package-agreements --accept-source-agreements | Out-Null
  Refrescar-Path
  if (Existe $cmd) { Ok "$nombre instalado" } else { Error2 "$nombre no quedó en el PATH (cerrá y abrí la consola y volvé a correr el script)" }
}

Refrescar-Path

Titulo 'Requisitos'
if (-not (Existe 'winget')) {
  Error2 'winget no está disponible. Instalá "App Installer" desde Microsoft Store y volvé a correr el script.'
  exit 1
}
Ok 'winget disponible'

Titulo 'Base: Git, Node.js, Python'
Instalar-Winget 'Git.Git'              'git'    'Git para Windows'
Instalar-Winget 'OpenJS.NodeJS.LTS'    'node'   'Node.js LTS'
Instalar-Winget 'Python.Python.3.12'   'python' 'Python 3.12'

Titulo 'Claude Code'
if (Existe 'claude') {
  Ok 'Claude Code ya instalado'
  if (-not $Verificar) { claude update 2>$null | Out-Null }
} elseif ($Verificar) {
  Falta 'Claude Code'
} else {
  Write-Host '  Instalando Claude Code (instalador oficial)...'
  try { Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression } catch { }
  Refrescar-Path
  if (-not (Existe 'claude')) {
    Write-Host '  Reintento con winget...'
    winget install --id Anthropic.ClaudeCode -e --silent --accept-package-agreements --accept-source-agreements | Out-Null
    Refrescar-Path
  }
  if (Existe 'claude') { Ok 'Claude Code instalado' } else { Error2 'Claude Code no quedó en el PATH' }
}

Titulo 'Modern Web Guidance (plugin de Claude Code)'
if (Existe 'claude') {
  $plugins = (claude plugin list 2>$null) -join "`n"
  if ($plugins -match 'modern-web-guidance') {
    Ok 'Plugin ya instalado'
  } elseif ($Verificar) {
    Falta 'Plugin modern-web-guidance'
  } else {
    claude plugin install modern-web-guidance@claude-plugins-official
    if ($LASTEXITCODE -eq 0) { Ok 'Plugin instalado' } else { Error2 'No se pudo instalar el plugin (¿iniciaste sesión con "claude" al menos una vez?)' }
  }
} else { Falta 'Plugin modern-web-guidance (requiere Claude Code)' }

Titulo 'Semgrep (análisis de seguridad del código)'
if (Existe 'semgrep') {
  Ok 'Semgrep ya instalado'
  if (-not $Verificar) { python -m pip install --user --upgrade --quiet semgrep }
} elseif ($Verificar) {
  Falta 'Semgrep'
} elseif (Existe 'python') {
  python -m pip install --user --upgrade --quiet semgrep
  $scripts = python -c "import sysconfig,os;print(sysconfig.get_path('scripts', os.name + '_user'))"
  $u = [Environment]::GetEnvironmentVariable('Path', 'User')
  if ($u -notlike "*$scripts*") { [Environment]::SetEnvironmentVariable('Path', "$u;$scripts", 'User') }
  Refrescar-Path; $env:Path += ";$scripts"
  if (Existe 'semgrep') { Ok 'Semgrep instalado' } else { Error2 'Semgrep instalado pero no aparece en el PATH' }
} else { Error2 'Semgrep requiere Python' }

Titulo 'gitleaks (claves filtradas en repos)'
Instalar-Winget 'Gitleaks.Gitleaks' 'gitleaks' 'gitleaks'

Titulo 'pip-audit (dependencias de proyectos Python)'
if (Existe 'pip-audit') { Ok 'pip-audit ya instalado' }
elseif ($Verificar) { Falta 'pip-audit' }
elseif (Existe 'python') {
  python -m pip install --user --upgrade --quiet pip-audit
  Refrescar-Path
  if (Existe 'pip-audit') { Ok 'pip-audit instalado' } else { Ok 'pip-audit instalado (usar: python -m pip_audit)' }
}

Titulo 'Herramientas por npx (se descargan al usarse, sin instalación fija)'
if (Existe 'npx') {
  if (-not $Verificar) {
    npx -y modern-web-guidance@latest --version 2>$null | Out-Null
    npx -y impeccable --help 2>$null | Out-Null
  }
  Ok 'modern-web-guidance (search, retrieve, legacy-scan) vía npx'
  Ok 'impeccable detect vía npx'
  Ok 'npm audit incluido con Node.js'
} else { Falta 'npx (viene con Node.js)' }

Titulo 'Estándar de Augu dentro de Claude Code y comando revisar'
$repo = Split-Path -Parent $PSScriptRoot
if (-not $Verificar) {
  if (Test-Path "$repo\.git") { git -C $repo pull --ff-only --quiet 2>$null }
  $destSkill = "$env:USERPROFILE\.claude\skills\estandar-code-augu"
  New-Item -ItemType Directory -Force -Path $destSkill | Out-Null
  Copy-Item "$repo\claude\skills\estandar-code-augu\SKILL.md" $destSkill -Force
  Ok 'Skill estandar-code-augu copiado a Claude Code'

  # Comando 'revisar' disponible en cualquier consola (CMD o PowerShell)
  $bin = "$env:USERPROFILE\.local\bin"
  New-Item -ItemType Directory -Force -Path $bin | Out-Null
  $gitBash = "$env:ProgramFiles\Git\bin\bash.exe"
  $script = ("$repo\herramientas\revisar-proyecto.sh" -replace '\\','/')
  Set-Content -Path "$bin\revisar.cmd" -Encoding ASCII -Value "@echo off`r`n`"$gitBash`" `"$script`" %*"
  $u = [Environment]::GetEnvironmentVariable('Path', 'User')
  if ($u -notlike "*$bin*") { [Environment]::SetEnvironmentVariable('Path', "$u;$bin", 'User') }
  Ok "Comando 'revisar' listo (abrí una consola nueva y escribí: revisar  o  revisar C:\ruta\al\proyecto)"
} else {
  if (Test-Path "$env:USERPROFILE\.claude\skills\estandar-code-augu\SKILL.md") { Ok 'Skill del estándar en Claude Code' } else { Falta 'Skill del estándar en Claude Code' }
  if (Test-Path "$env:USERPROFILE\.local\bin\revisar.cmd") { Ok "Comando 'revisar'" } else { Falta "Comando 'revisar'" }
}

Titulo 'Resumen'
$tabla = @(
  @{n='git';c='git'}, @{n='node';c='node'}, @{n='python';c='python'},
  @{n='claude';c='claude'}, @{n='semgrep';c='semgrep'}, @{n='gitleaks';c='gitleaks'}
)
foreach ($t in $tabla) { if (Existe $t.c) { Ok $t.n } else { Falta $t.n } }

if ($fallas.Count -gt 0) {
  Write-Host "`nHubo $($fallas.Count) problema(s). Cerrá la consola, abrí una nueva y corré el script otra vez. Si persiste, pasale este resultado a Claude." -ForegroundColor Yellow
} elseif (-not $Verificar) {
  Write-Host "`nListo. Si es la primera vez en esta máquina: corré 'claude' para iniciar sesión y volvé a correr este script para instalar el plugin." -ForegroundColor Green
}
