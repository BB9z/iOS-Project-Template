#!/bin/zsh
# Xcode Cloud 依赖安装脚本
# Copyright © 2022 BB9z.
# https://github.com/BB9z/iOS-Project-Template

echo "Xcode Cloud: Project Setup."

set -euo pipefail

brew install cocoapods
pod install
