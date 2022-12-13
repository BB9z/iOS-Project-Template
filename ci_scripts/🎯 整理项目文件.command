#!/bin/zsh
set -euo pipefail
cd "$(dirname "$0")/.."
./ci_scripts/sort_projects.sh
say "sort done"
