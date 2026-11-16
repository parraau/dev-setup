#!/usr/bin/env bash
# Instala Semgrep, pip-audit y gitleaks en Linux (GitHub Actions, Codespaces, WSL o servidor).
set -e
export PATH="$HOME/.local/bin:$PATH"

python3 -m pip install --user --upgrade --quiet semgrep pip-audit 2>/dev/null \
  || python3 -m pip install --user --upgrade --quiet --break-system-packages semgrep pip-audit

if ! command -v gitleaks >/dev/null 2>&1; then (
  set -e
  VER=$(curl -fsSL https://api.github.com/repos/gitleaks/gitleaks/releases/latest | grep -m1 '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
  ARCH=$(uname -m); [ "$ARCH" = "aarch64" ] && ARCH=arm64; [ "$ARCH" = "x86_64" ] && ARCH=x64
  curl -fsSL "https://github.com/gitleaks/gitleaks/releases/download/v${VER}/gitleaks_${VER}_linux_${ARCH}.tar.gz" | tar -xz -C /tmp gitleaks
  mkdir -p "$HOME/.local/bin" && mv /tmp/gitleaks "$HOME/.local/bin/gitleaks"
) || echo "AVISO: no se pudo instalar gitleaks; la revisión de secretos queda solo con Semgrep"
fi

[ -n "${GITHUB_PATH:-}" ] && echo "$HOME/.local/bin" >> "$GITHUB_PATH"
semgrep --version >/dev/null && echo "semgrep OK"
command -v gitleaks >/dev/null && echo "gitleaks OK" || true
