#!/bin/zsh

set -euo pipefail

readonly ScriptPath=$(dirname $0)

for file in $(find . -name "*.xcodeproj" -maxdepth 2); do
    if [[ "$file" == *Pods.xcodeproj ]]; then
        # echo "跳过 pod"
        return
    fi
    echo "整理: $file"
    perl -w "$ScriptPath/sort-Xcode-project-file.pl" "$file"
done
