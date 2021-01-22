#!/bin/sh
set -euo pipefail
cd "$(dirname "$0")/.."
echo "$PWD"
pod install --verbose || {
    say "Install failed"
    exit
}
./Scripts/sort_projects.sh
say "Install done"
