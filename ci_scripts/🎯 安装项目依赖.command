#!/bin/zsh
set -euo pipefail
cd "$(dirname "$0")/.."
echo "$PWD"
fastlane setup_project || {
    say "Setup failed"
    exit
}
say "Setup done"
