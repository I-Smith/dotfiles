#!/usr/bin/env bash
# Installs all software for a new machine.
# Run this before setup.sh (which stows the dotfile packages into place).
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -s)" in
  Darwin) source "$REPO/install/macos.sh" ;;
  Linux)  source "$REPO/install/linux.sh" ;;
  *)      echo "Unsupported OS: $(uname -s)"; exit 1 ;;
esac

source "$REPO/install/common.sh"

echo ""
echo "Done. Run ./setup.sh next to stow the dotfiles into place."
