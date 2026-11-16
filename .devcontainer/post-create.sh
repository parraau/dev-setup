#!/usr/bin/env bash
# Se ejecuta una sola vez al crear el Codespace. Deja todo el estándar listo.
set -e
# Si este devcontainer está copiado en otro proyecto, trae las herramientas desde dev-setup.
if [ -f herramientas/instalar-linux.sh ]; then BASE=.; else
  gh repo clone parraau/dev-setup "$HOME/dev-setup" -- --depth 1 2>/dev/null || git clone --depth 1 https://github.com/parraau/dev-setup "$HOME/dev-setup"
  BASE="$HOME/dev-setup"
fi
bash "$BASE/herramientas/instalar-linux.sh"

# Claude Code + estándar como skill + plugin de Chrome
curl -fsSL https://claude.ai/install.sh | bash
mkdir -p "$HOME/.claude/skills"
cp -r "$BASE/claude/skills/estandar-code-augu" "$HOME/.claude/skills/"
export PATH="$HOME/.local/bin:$PATH"
claude plugin install modern-web-guidance@claude-plugins-official 2>/dev/null || echo "Plugin: iniciá sesión con 'claude' y corré: claude plugin install modern-web-guidance@claude-plugins-official"

# Atajo: 'revisar' corre el estándar completo sobre la carpeta actual
echo "alias revisar='bash $BASE/herramientas/revisar-proyecto.sh'" >> "$HOME/.bashrc"
echo "Entorno listo. Escribí 'revisar' en cualquier proyecto para correr el estándar."
