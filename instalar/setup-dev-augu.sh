#!/usr/bin/env bash
# setup-dev-augu.sh — equivalente para Linux, macOS o WSL.
# Uso: bash setup-dev-augu.sh   |   bash setup-dev-augu.sh --verificar
set -u
VER=0; [ "${1:-}" = "--verificar" ] && VER=1
ok(){ printf '  \033[32m[OK]\033[0m    %s\n' "$1"; }
falta(){ printf '  \033[33m[FALTA]\033[0m %s\n' "$1"; }
tiene(){ command -v "$1" >/dev/null 2>&1; }
export PATH="$HOME/.local/bin:$PATH"

echo "== Base =="
for c in git node python3; do tiene "$c" && ok "$c" || falta "$c (instalalo con el gestor de paquetes del sistema)"; done

echo "== Claude Code =="
if tiene claude; then ok "Claude Code"; [ $VER = 0 ] && claude update >/dev/null 2>&1
elif [ $VER = 0 ]; then curl -fsSL https://claude.ai/install.sh | bash; tiene claude && ok "Claude Code instalado" || falta "Claude Code"
else falta "Claude Code"; fi

echo "== Modern Web Guidance =="
if tiene claude; then
  if claude plugin list 2>/dev/null | grep -q modern-web-guidance; then ok "plugin"
  elif [ $VER = 0 ]; then claude plugin install modern-web-guidance@claude-plugins-official && ok "plugin instalado"
  else falta "plugin"; fi
fi

echo "== Semgrep y pip-audit =="
for p in semgrep pip-audit; do
  if tiene "$p"; then ok "$p"
  elif [ $VER = 0 ]; then
    if tiene pipx; then pipx install "$p" >/dev/null; else python3 -m pip install --user --upgrade --quiet "$p" 2>/dev/null || python3 -m pip install --user --upgrade --quiet --break-system-packages "$p"; fi
    tiene "$p" && ok "$p instalado" || falta "$p"
  else falta "$p"; fi
done

echo "== gitleaks =="
if tiene gitleaks; then ok gitleaks
elif [ $VER = 0 ] && tiene brew; then brew install gitleaks && ok "gitleaks instalado"
else falta "gitleaks (macOS: brew install gitleaks · Linux: binario en github.com/gitleaks/gitleaks/releases)"; fi

echo "== npx =="
tiene npx && ok "modern-web-guidance, impeccable y npm audit vía npx" || falta "npx (viene con Node.js)"

echo "== Estándar en Claude Code y comando revisar =="
REPO="$(cd "$(dirname "$0")/.." && pwd)"
if [ $VER = 0 ]; then
  [ -d "$REPO/.git" ] && git -C "$REPO" pull --ff-only --quiet 2>/dev/null
  mkdir -p "$HOME/.claude/skills/estandar-code-augu"
  cp "$REPO/claude/skills/estandar-code-augu/SKILL.md" "$HOME/.claude/skills/estandar-code-augu/" && ok "skill del estándar"
  mkdir -p "$HOME/.local/bin"
  printf '#!/usr/bin/env bash\nexec bash "%s/herramientas/revisar-proyecto.sh" "$@"\n' "$REPO" > "$HOME/.local/bin/revisar" && chmod +x "$HOME/.local/bin/revisar" && ok "comando revisar (en ~/.local/bin)"
else
  [ -f "$HOME/.claude/skills/estandar-code-augu/SKILL.md" ] && ok "skill del estándar" || falta "skill del estándar"
  tiene revisar && ok "comando revisar" || falta "comando revisar"
fi
