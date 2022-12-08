#!/bin/zsh
set -euo pipefail
cd "$(dirname "$0")/.."
echo "$PWD"
fastlane alpha || {
    say "Upload failed"
    exit
}
say "Uploaded successfully"
