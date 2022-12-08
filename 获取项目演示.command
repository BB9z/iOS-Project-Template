#! /bin/zsh

# 拉取 demo 分支
# Copyright © 2020, 2022 BB9z.
# https://github.com/BB9z/iOS-Project-Template

set -euo pipefail

cd "$(dirname "$0")"
echo "$PWD"

logInfo () {
    echo "\033[32m$1\033[0m" >&2
}

logWarning () {
    echo "\033[33m$1\033[0m" >&2
}

logError () {
    echo "\033[31m$1\033[0m" >&2
}

logInput () {
    echo "\033[37m$1\033[0m" >&2
}

CLONE_DESTINATION="Template Demos"
if [ -d "$CLONE_DESTINATION" ]; then
    logWarning "Demo 已下载，终止脚本"
    exit
fi
git clone --depth 1 --branch=demo https://github.com/BB9z/iOS-Project-Template.git "$CLONE_DESTINATION"
open "$CLONE_DESTINATION"
