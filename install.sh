#!/bin/bash
set -euo pipefail

DIR=~/dotfiles

if ! command -v nix &>/dev/null; then
  echo "Error: Nix is not installed."
  echo "Install Determinate Nix: https://docs.determinate.systems/ds/start/"
  exit 1
fi

echo "=== Applying Home Manager configuration ==="

if command -v home-manager &>/dev/null; then
  home-manager switch --flake "$DIR"
else
  echo "home-manager not found. Running initial setup..."
  nix run home-manager/master -- switch --flake "$DIR"
fi

echo "=== Done! ==="
