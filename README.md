# dev-setup

Entorno de desarrollo y estándar de código de Augu, igual en todas las máquinas.

El estándar combina cuatro capas:

| Capa | Herramienta | Bloquea la entrega |
|---|---|---|
| Plataforma web | Modern Web Guidance (Chrome) | No, avisa |
| Diseño | impeccable | No, avisa |
| Copy | no-ai-slop | No, lo aplica Claude al escribir |
| Seguridad | Semgrep (OWASP, secretos y reglas propias), gitleaks, npm audit, pip-audit | Sí |

El detalle completo está en [`claude/skills/estandar-code-augu/SKILL.md`](claude/skills/estandar-code-augu/SKILL.md).

## Tres formas de trabajar

### 1. En la nube, sin instalar nada (Codespaces)

Desde cualquier máquina con navegador: en este repo, o en cualquier proyecto al que se le aplicó el estándar, **Code → Codespaces → Create codespace**. Se abre VS Code en el navegador con Node, Python, Semgrep, gitleaks, Claude Code y el estándar ya instalados. Para revisar el proyecto, escribí `revisar` en la terminal.

### 2. En una máquina propia (una sola vez por máquina)

**Windows:**

```
git clone https://github.com/parraau/dev-setup %USERPROFILE%\dev-setup
%USERPROFILE%\dev-setup\instalar\setup-dev-augu.cmd
```

Si la máquina no tiene Git, primero: `winget install --id Git.Git -e`, y abrí una consola nueva.

**Linux, macOS o WSL:**

```
git clone https://github.com/parraau/dev-setup ~/dev-setup && bash ~/dev-setup/instalar/setup-dev-augu.sh
```

Para ver qué está instalado y qué falta sin cambiar nada: `setup-dev-augu.cmd -Verificar` (Windows) o `setup-dev-augu.sh --verificar`.

Para actualizar, volvé a correr el instalador: primero trae la última versión del repo.

Después de instalar, en cualquier consola:

```
revisar                       (revisa la carpeta actual)
revisar C:\ruta\al\proyecto
```

### 3. Automático en GitHub (en cada push)

Cada proyecto con el estándar aplicado corre la revisión completa en GitHub Actions en cada push y pull request. Si hay un problema de seguridad, el check queda en rojo.

Para sumar un proyecto:

```
bash ~/dev-setup/herramientas/aplicar-a-proyecto.sh <carpeta-del-repo>
```

Copia el workflow y la configuración de Codespaces, y suma `.env` al `.gitignore`.

## Configuración que se hace una sola vez en GitHub

- **Settings → Actions → General → Access** de este repo: elegir *Accessible from repositories owned by the user 'parraau'*. Sin esto, los otros repos no pueden usar el workflow.
- Si este repo es **privado**: crear un token *fine-grained* con permiso de lectura (*Contents: Read*) sobre `parraau/dev-setup` y guardarlo como secreto `DEV_SETUP_TOKEN` en cada proyecto (o en una organización). Si el repo es público, no hace falta.

## Estructura

```
dev-setup/
├── instalar/                 instaladores por máquina (Windows y Linux/macOS)
├── herramientas/
│   ├── revisar-proyecto.sh   la revisión completa (la usan Actions, Codespaces y el comando revisar)
│   ├── reglas-augu.yml       reglas propias de Semgrep (innerHTML, eval, handlers inline, target=_blank)
│   ├── instalar-linux.sh     Semgrep, pip-audit y gitleaks en Linux
│   └── aplicar-a-proyecto.sh suma el estándar a un repo
├── claude/skills/            el estándar como skill de Claude Code
├── plantillas/               lo que se copia a cada proyecto
├── .devcontainer/            Codespaces de este repo
└── .github/workflows/        control automático reutilizable
```

## Qué bloquea y qué no

- **Bloquea:** hallazgos de Semgrep, claves detectadas por gitleaks, dependencias con vulnerabilidades altas o críticas.
- **Avisa:** patrones heredados de la plataforma web y hallazgos de diseño.
- Un falso positivo de Semgrep se silencia en esa línea con `// nosemgrep: <id-de-la-regla>` y una explicación al lado.
