#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
hermes_home="${HERMES_HOME:-$HOME/.hermes}"
skins_dir="$hermes_home/skins"

mkdir -p "$skins_dir"
install -m 0644 "$repo_root/apps/hermes/dusk.yaml" "$skins_dir/dusk.yaml"
install -m 0644 "$repo_root/apps/hermes/cream.yaml" "$skins_dir/cream.yaml"

printf 'Installed Hermes skins in %s\n' "$skins_dir"
printf 'Activate with: hermes config set display.skin dusk\n'
printf '          or: hermes config set display.skin cream\n'
