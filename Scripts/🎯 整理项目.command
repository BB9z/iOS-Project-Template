#!/bin/sh
set -euo pipefail
cd "$(dirname "$0")/.."
echo "$PWD"
fastlane sort_project
say "sort done"
