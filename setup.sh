#!/usr/bin/env bash
# Symlinks every package in this repo into place using GNU Stow.
# Safe to re-run: `stow -R` is idempotent, and any real (non-symlink) file
# already sitting at a target path is backed up as .bak before stowing.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh vim cursor claude launchd)

if ! command -v stow >/dev/null 2>&1; then
  echo "GNU Stow is not installed."
  case "$(uname -s)" in
    Darwin) echo "  Install with: brew install stow" ;;
    Linux)  echo "  Install with: sudo apt-get install stow" ;;
  esac
  exit 1
fi

echo "==> Backing up any real files that would conflict with stow"
for pkg in "${PACKAGES[@]}"; do
  [ -d "$REPO/$pkg" ] || continue
  while IFS= read -r -d '' file; do
    rel="${file#"$REPO"/"$pkg"/}"
    dest="$HOME/$rel"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
      echo "  backup  $dest → ${dest}.bak"
      mkdir -p "$(dirname "${dest}.bak")"
      mv "$dest" "${dest}.bak"
    fi
  done < <(find "$REPO/$pkg" -type f -print0)
done

echo ""
echo "==> Stowing packages: ${PACKAGES[*]}"
cd "$REPO"
stow -v -R -t "$HOME" "${PACKAGES[@]}"

echo ""
echo "==> Git hooks"
git config core.hooksPath hooks
chmod +x hooks/pre-commit hooks/secrets-check.sh hooks/monthly-sync.sh
echo "  core.hooksPath -> hooks/ (pre-commit secrets scan active)"

echo ""
echo "==> Monthly sync (launchd)"
PLIST="$HOME/Library/LaunchAgents/com.ismith.dotfiles.monthly-sync.plist"
if launchctl list | grep -q com.ismith.dotfiles.monthly-sync; then
  echo "  already loaded: com.ismith.dotfiles.monthly-sync"
else
  launchctl load "$PLIST" 2>/dev/null && echo "  loaded: runs at 9:03am on the 1st of each month" \
    || echo "  could not load $PLIST — load manually with: launchctl load $PLIST"
fi

echo ""
echo "Done. Open a new shell and restart Cursor to pick up changes."
echo ""
echo "Manual steps:"
echo "  1. If this is a new machine, run ./install.sh first to install all software."
echo "  2. Fill in ~/.zshenv: AWS_MFA_ARN, GOPRIVATE, AWS_PROFILE (currently blank placeholders)."
echo "  3. Store Gmail app password in Keychain for monthly-sync email notifications:"
echo "     security add-generic-password -a \"\$USER\" -s \"gmail-app-password\" -w \"your-app-password\""
echo "     Get an app password at: myaccount.google.com/apppasswords"
