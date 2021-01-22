#!/bin/sh
set -euo pipefail
cd "$(dirname "$0")/.."
echo "$PWD"
pod update --verbose || {
    say "Update failed"
    exit
}
./Scripts/sort_projects.sh
say "Update done"
