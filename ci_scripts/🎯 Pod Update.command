#!/bin/zsh
set -euo pipefail
cd "$(dirname "$0")/.."
echo "$PWD"
pod update --verbose || {
    say "Update failed"
    exit
}
./ci_scripts/sort_projects.sh
say "Update done"
