#!/usr/bin/env bash
# aplicar-a-proyecto.sh — suma el estándar a un repo de proyecto:
#   .github/workflows/estandar-augu.yml  (control automático en cada push)
#   .devcontainer/                        (abrir el proyecto en Codespaces con todo instalado)
# Uso: bash aplicar-a-proyecto.sh <carpeta-del-repo>
set -e
AQUI="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${1:?Indicá la carpeta del repo del proyecto}"
[ -d "$DEST/.git" ] || { echo "$DEST no es un repo git"; exit 1; }
mkdir -p "$DEST/.github/workflows" "$DEST/.devcontainer"
cp "$AQUI/plantillas/.github/workflows/estandar-augu.yml" "$DEST/.github/workflows/"
if [ -f "$DEST/.devcontainer/devcontainer.json" ]; then
  echo "El proyecto ya tiene .devcontainer/devcontainer.json: no lo piso. Revisalo a mano."
else
  cp "$AQUI/plantillas/.devcontainer/"* "$DEST/.devcontainer/"
fi
grep -qxF ".env" "$DEST/.gitignore" 2>/dev/null || echo ".env" >> "$DEST/.gitignore"
echo "Listo. Revisá los cambios y commiteá:"
echo "  cd $DEST && git add .github .devcontainer .gitignore && git commit -m 'Sumar estándar Augu' && git push"
