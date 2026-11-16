#!/usr/bin/env bash
# revisar-proyecto.sh — corre el estándar de Augu sobre una carpeta de proyecto.
# Lo usan: GitHub Actions (en cada push), Codespaces y cualquier máquina local (en Windows, desde Git Bash).
#
# Uso: bash revisar-proyecto.sh [carpeta]          (por defecto, la carpeta actual)
# Salida: código 1 si hay un problema de SEGURIDAD; diseño y plataforma se informan pero no bloquean.

set -u
DIR="${1:-.}"
AQUI="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR" || { echo "No existe la carpeta $DIR"; exit 2; }
BLOQUEA=0
AVISOS=0
tiene(){ command -v "$1" >/dev/null 2>&1; }
seccion(){ printf '\n\033[36m== %s ==\033[0m\n' "$1"; }
mal(){ printf '\033[31m  [BLOQUEA]\033[0m %s\n' "$1"; BLOQUEA=1; }
aviso(){ printf '\033[33m  [AVISO]\033[0m   %s\n' "$1"; AVISOS=$((AVISOS+1)); }
bien(){ printf '\033[32m  [OK]\033[0m      %s\n' "$1"; }

# Archivos de terceros o generados que no se revisan
EXCLUIR=(--exclude node_modules --exclude dist --exclude build --exclude .next --exclude vendor --exclude .venv --exclude venv)

seccion "1. Seguridad del código (Semgrep: OWASP Top 10 y secretos)"
if tiene semgrep; then
  CONF=(--config p/javascript --config p/typescript --config p/owasp-top-ten --config p/secrets --config "$AQUI/reglas-augu.yml")
  if ls ./*.py >/dev/null 2>&1 || [ -f requirements.txt ] || [ -f pyproject.toml ] || [ -f manage.py ]; then
    CONF+=(--config p/python)
    [ -f manage.py ] && CONF+=(--config p/django)
  fi
  if semgrep scan "${CONF[@]}" "${EXCLUIR[@]}" --metrics=off --error --quiet .; then
    bien "Semgrep sin hallazgos"
  else
    mal "Semgrep encontró problemas (detalle arriba)"
  fi
else
  mal "Semgrep no está instalado (correr instalar/setup-dev-augu)"
fi

seccion "2. Claves filtradas en el repo y su historial (gitleaks)"
if tiene gitleaks; then
  if [ -d .git ]; then
    gitleaks detect --source . --no-banner --redact && bien "Sin claves en el historial" || mal "gitleaks encontró posibles claves (detalle arriba)"
  else
    gitleaks detect --source . --no-git --no-banner --redact && bien "Sin claves en los archivos" || mal "gitleaks encontró posibles claves"
  fi
else
  aviso "gitleaks no instalado: solo se revisaron secretos con Semgrep"
fi

seccion "3. Dependencias con vulnerabilidades"
REVISO=0
if [ -f package-lock.json ]; then
  REVISO=1
  npm audit --audit-level=high --omit=dev && bien "npm: sin vulnerabilidades altas o críticas" || mal "npm audit: hay vulnerabilidades altas o críticas"
elif [ -f pnpm-lock.yaml ] && tiene pnpm; then
  REVISO=1
  pnpm audit --audit-level high --prod && bien "pnpm: sin vulnerabilidades altas o críticas" || mal "pnpm audit: hay vulnerabilidades altas o críticas"
elif [ -f package.json ]; then
  REVISO=1
  aviso "package.json sin lockfile: commitear package-lock.json para poder auditar y fijar versiones"
fi
if [ -f requirements.txt ]; then
  REVISO=1
  if tiene pip-audit; then PA=pip-audit; else PA="python3 -m pip_audit"; fi
  $PA -r requirements.txt --progress-spinner off && bien "Python: sin vulnerabilidades conocidas" || mal "pip-audit: hay dependencias vulnerables"
fi
[ $REVISO = 0 ] && bien "Sin dependencias declaradas"

seccion "4. Plataforma web (Modern Web Guidance: patrones heredados)"
if tiene npx; then
  SALIDA=$(npx -y modern-web-guidance@latest legacy-scan . 2>/dev/null | grep -v "npm notice")
  echo "$SALIDA" | sed 's/^/  /'
  if echo "$SALIDA" | grep -qE '^0 findings|^\s*0 findings'; then bien "Sin patrones heredados detectados"; else aviso "Hay patrones para modernizar (no bloquea)"; fi
else
  aviso "npx no disponible"
fi

seccion "5. Diseño (impeccable detect sobre los HTML)"
HTMLS=$(find . -name "*.html" -not -path "*/node_modules/*" -not -path "*/dist/*" -not -path "*/build/*" -not -path "*/.git/*" 2>/dev/null | head -50)
if [ -z "$HTMLS" ]; then
  bien "No hay archivos HTML"
elif tiene npx; then
  for f in $HTMLS; do
    echo "  -> $f"
    npx -y impeccable detect "$f" 2>/dev/null | grep -v "npm notice" | sed 's/^/     /' || aviso "impeccable marcó hallazgos en $f"
  done
fi

seccion "Resultado"
if [ $BLOQUEA = 1 ]; then
  printf '\033[31mNO APTO para producción: hay problemas de seguridad sin resolver.\033[0m\n'
  exit 1
fi
printf '\033[32mApto en seguridad.\033[0m Avisos de diseño o plataforma: %s\n' "$AVISOS"
exit 0
