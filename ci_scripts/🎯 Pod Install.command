#!/bin/zsh
set -euo pipefail
cd "$(dirname "$0")/.."
echo "$PWD"
pod install --verbose || {
    say "Install failed"
    exit
}
./ci_scripts/sort_projects.sh
say "Install done"
