#!/usr/bin/env bash
# One-shot laptop setup for ClusterMax work on a Mac.
# Installs: git, kubectl, uv, Claude Code, and (when possible) Homebrew + node + Codex.
# Works WITHOUT admin rights: falls back to user-local installs in ~/.local/bin.
# Safe to re-run. Nothing here touches credentials or clusters.
#
# Run it like this (download first so it has a real terminal for prompts):
#   curl -fsSLo ~/bootstrap-mac.sh https://raw.githubusercontent.com/Abhisemi/setup/claude/sweet-hopper-92iau3/bootstrap-mac.sh
#   bash ~/bootstrap-mac.sh
#
set -euo pipefail

say()  { printf '\n\033[1;32m==> %s\033[0m\n' "$*"; }
warn() { printf '\n\033[1;33m!!  %s\033[0m\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

mkdir -p ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"
if ! grep -q '.local/bin' ~/.zprofile 2>/dev/null; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zprofile
fi

# Are we an admin? Homebrew needs it. If not, skip brew entirely.
IS_ADMIN=0
if dscl . -read /Groups/admin GroupMembership 2>/dev/null | grep -qw "$(whoami)"; then IS_ADMIN=1; fi

# ---- Homebrew path (admin only) --------------------------------------------
if [ "$IS_ADMIN" = 1 ]; then
  if ! have brew; then
    say "Installing Homebrew (asks for your Mac password once)"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  if [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
  if [ -x /usr/local/bin/brew ];    then eval "$(/usr/local/bin/brew shellenv)"; fi
  if ! grep -q 'brew shellenv' ~/.zprofile 2>/dev/null; then
    echo 'eval "$('"$(command -v brew)"' shellenv)"' >> ~/.zprofile
  fi
  say "Installing kubectl, uv, node via Homebrew"
  brew install kubectl uv node
else
  warn "This account is not a Mac administrator, so skipping Homebrew. Installing user-local tools instead."
fi

# ---- kubectl (user-local fallback) -----------------------------------------
if ! have kubectl; then
  say "Installing kubectl into ~/.local/bin"
  ARCH="$(uname -m)"; case "$ARCH" in arm64) KARCH=arm64;; x86_64) KARCH=amd64;; *) KARCH=amd64;; esac
  KVER="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
  curl -fsSLo ~/.local/bin/kubectl "https://dl.k8s.io/release/${KVER}/bin/darwin/${KARCH}/kubectl"
  chmod +x ~/.local/bin/kubectl
fi

# ---- uv (user-local fallback) ----------------------------------------------
if ! have uv; then
  say "Installing uv into ~/.local/bin"
  curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="$HOME/.local/bin" sh
fi

# ---- Claude Code (official installer, no admin needed) ---------------------
if ! have claude; then
  say "Installing Claude Code"
  curl -fsSL https://claude.ai/install.sh | bash
fi

# ---- Codex CLI (needs node; only if node exists) ---------------------------
if have node && ! have codex; then
  say "Installing Codex CLI"
  npm install -g @openai/codex || warn "Codex install failed, skip it for today"
elif ! have node; then
  warn "No node.js, so skipping Codex CLI for now. Claude Code is enough to start."
fi

# ---- kube dir -----------------------------------------------------------------
mkdir -p ~/.kube && chmod 700 ~/.kube

say "Versions"
git --version
kubectl version --client 2>/dev/null | head -1 || echo "kubectl: not found"
uv --version || echo "uv: not found"
claude --version 2>/dev/null || echo "claude: installed, open a NEW terminal tab if not found"
codex --version 2>/dev/null || echo "codex: not installed (optional)"

cat <<'EOF'

Done. Now:
  1. Open a NEW terminal tab so PATH updates apply.
  2. In Finder, open Downloads and find the kubeconfig file Sam sent.
     Drag it into the terminal after typing "mv " to get the exact path, then:
       mv <dragged path> ~/.kube/yotta.yaml
       chmod 600 ~/.kube/yotta.yaml
       export KUBECONFIG=~/.kube/yotta.yaml
       kubectl get nodes
  3. Clone the CLI repo and start Claude Code inside it:
       cd ~ && git clone https://github.com/SemiAnalysisAI/ClusterMAX-internal.git
       cd ClusterMAX-internal
       claude
EOF
