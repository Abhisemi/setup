#!/usr/bin/env bash
# One-shot laptop setup for ClusterMax work on a Mac.
# Installs: Homebrew (if missing), git, kubectl, uv, Claude Code, Codex CLI.
# Safe to re-run. Nothing here touches credentials or clusters.
#
#   curl -fsSL https://raw.githubusercontent.com/Abhisemi/setup/claude/sweet-hopper-92iau3/bootstrap-mac.sh | bash
#
set -euo pipefail

say() { printf '\n\033[1;32m==> %s\033[0m\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

# 1. Homebrew
if ! have brew; then
  say "Installing Homebrew (you'll be asked for your Mac password)"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# Put brew on PATH for this shell (Apple Silicon and Intel paths)
if [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
if [ -x /usr/local/bin/brew ]; then eval "$(/usr/local/bin/brew shellenv)"; fi
# ...and for future shells
if ! grep -q 'brew shellenv' ~/.zprofile 2>/dev/null; then
  echo 'eval "$('"$(command -v brew)"' shellenv)"' >> ~/.zprofile
fi

# 2. Core tools
say "Installing kubectl, uv, git, node"
brew install kubectl uv git node

# 3. Claude Code (official installer)
if ! have claude; then
  say "Installing Claude Code"
  curl -fsSL https://claude.ai/install.sh | bash
fi
# Claude's installer drops a binary in ~/.local/bin
if ! grep -q '.local/bin' ~/.zprofile 2>/dev/null; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zprofile
fi
export PATH="$HOME/.local/bin:$PATH"

# 4. Codex CLI
if ! have codex; then
  say "Installing Codex CLI"
  npm install -g @openai/codex
fi

# 5. Kube dir with sane permissions
mkdir -p ~/.kube && chmod 700 ~/.kube

say "Versions"
git --version
kubectl version --client 2>/dev/null | head -1
uv --version
claude --version || echo "claude: installed, open a new terminal tab if not found"
codex --version   || echo "codex: installed, open a new terminal tab if not found"

cat <<'EOF'

Done. Now:
  1. Open a NEW terminal tab so PATH updates apply.
  2. Save the kubeconfig you were sent to ~/.kube/yotta.yaml and run:
       chmod 600 ~/.kube/yotta.yaml
       export KUBECONFIG=~/.kube/yotta.yaml
       kubectl get nodes
  3. Clone the CLI repo and start Claude Code inside it:
       git clone https://github.com/SemiAnalysisAI/ClusterMAX-internal.git
       cd ClusterMAX-internal
       claude
EOF
