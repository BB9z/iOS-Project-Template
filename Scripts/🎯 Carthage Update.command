#!/bin/sh
set -euo pipefail
cd "$(dirname "$0")/.."
echo "$PWD"
carthage update --cache-builds --use-xcframeworks --platform iOS || {
    say "Update failed"
    exit
}
say "Update done"
