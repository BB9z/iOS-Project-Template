#!/bin/zsh
# 搜寻目录下的 Xcode 项目文件，对项目文件执行排序整理操作
# Copyright © 2018, 2022 BB9z.
# https://github.com/BB9z/iOS-Project-Template

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
