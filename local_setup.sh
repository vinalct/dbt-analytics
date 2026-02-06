#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# local_setup.sh — bootstrap a local dev environment using pyenv + virtualenv
# Usage: bash local_setup.sh   (or via `make local-setup`)
# ---------------------------------------------------------------------------
set -euo pipefail

PYTHON_VERSION="3.11.11"
VENV_NAME="dbt-analytics"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "================================================"
echo "  dbt-analytics — local environment setup"
echo "================================================"

echo "🔧  Ensuring build dependencies are available..."
if command -v apt-get &>/dev/null; then
  sudo apt-get update -qq
  sudo apt-get install -y -qq make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
    libffi-dev liblzma-dev git 2>/dev/null
elif command -v dnf &>/dev/null; then
  sudo dnf install -y gcc make zlib-devel bzip2-devel readline-devel \
    sqlite-devel openssl-devel tk-devel libffi-devel xz-devel git 2>/dev/null
elif command -v yum &>/dev/null; then
  sudo yum install -y gcc make zlib-devel bzip2-devel readline-devel \
    sqlite-devel openssl-devel tk-devel libffi-devel xz-devel git 2>/dev/null
elif command -v brew &>/dev/null; then
  brew install openssl readline sqlite3 xz zlib tcl-tk git 2>/dev/null || true
else
  echo "⚠️  Could not detect package manager — build deps may be missing."
  echo "   If Python install fails, install them manually."
fi

if ! command -v pyenv &>/dev/null; then
  if [ -d "$HOME/.pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
  fi
fi

if ! command -v pyenv &>/dev/null; then
  echo "📦  pyenv not found — installing via pyenv-installer..."
  curl -fsSL https://pyenv.run | bash

  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"

  SHELL_RC=""
  if [ -n "${ZSH_VERSION:-}" ] || [ "$(basename "$SHELL")" = "zsh" ]; then
    SHELL_RC="$HOME/.zshrc"
  elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
  elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_RC="$HOME/.bash_profile"
  fi

  if [ -n "$SHELL_RC" ] && ! grep -q 'PYENV_ROOT' "$SHELL_RC" 2>/dev/null; then
    echo "" >> "$SHELL_RC"
    echo '# --- pyenv (added by dbt-analytics local_setup.sh) ---' >> "$SHELL_RC"
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$SHELL_RC"
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> "$SHELL_RC"
    echo 'eval "$(pyenv init -)"' >> "$SHELL_RC"
    echo 'eval "$(pyenv virtualenv-init -)"' >> "$SHELL_RC"
    echo "   ✅  Added pyenv init to $SHELL_RC"
  fi
else
  echo "✅  pyenv already installed"
fi

export PATH="$HOME/.pyenv/bin:$HOME/.pyenv/shims:$PATH"
eval "$(pyenv init -)"

if [ ! -d "$(pyenv root)/plugins/pyenv-virtualenv" ]; then
  echo "📦  Installing pyenv-virtualenv plugin..."
  git clone https://github.com/pyenv/pyenv-virtualenv.git "$(pyenv root)/plugins/pyenv-virtualenv"
else
  echo "✅  pyenv-virtualenv plugin already installed"
fi
eval "$(pyenv virtualenv-init -)" 2>/dev/null || true

if ! pyenv versions --bare | grep -qx "$PYTHON_VERSION"; then
  echo "📦  Installing Python $PYTHON_VERSION via pyenv (this may take a few minutes)..."
  pyenv install "$PYTHON_VERSION"
else
  echo "✅  Python $PYTHON_VERSION already installed"
fi

if ! pyenv virtualenvs --bare | grep -qx "$VENV_NAME"; then
  echo "🐍  Creating virtualenv '$VENV_NAME' (Python $PYTHON_VERSION)..."
  pyenv virtualenv "$PYTHON_VERSION" "$VENV_NAME"
else
  echo "✅  Virtualenv '$VENV_NAME' already exists"
fi

echo "📌  Setting local pyenv version → $VENV_NAME"
cd "$PROJECT_DIR"
pyenv local "$VENV_NAME"

export PYENV_VERSION="$VENV_NAME"

echo "⬆️   Upgrading pip..."
pip install --upgrade pip --quiet

echo "📥  Installing requirements..."
pip install -r "$PROJECT_DIR/requirements.txt" --quiet

echo "📦  Running dbt deps..."
dbt deps

echo ""
echo "================================================"
echo "  ✅  Setup complete!"
echo "================================================"
echo "  Python:     $(python --version)"
echo "  Virtualenv: $VENV_NAME"
echo "  dbt:        $(dbt --version | head -1)"
echo ""
echo "  The virtualenv activates automatically in this"
echo "  directory via .python-version (pyenv local)."
echo ""
echo "  Next steps:"
echo "    cp profiles.yml.example ~/.dbt/profiles.yml"
echo "    # edit ~/.dbt/profiles.yml with your project/dataset"
echo "    dbt debug"
echo "================================================"
