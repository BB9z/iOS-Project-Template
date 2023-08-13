#! /bin/zsh
# Test Package 
#
# Copyright © 2023 BB9z.
# https://github.com/BB9z/iOS-Project-Template
#
# The MIT License
# https://opensource.org/licenses/MIT

set -euo pipefail
cd "$(dirname "$0")"

formatter=xcpretty
if [ -x "$(command -v xcbeautify)" ]; then
    formatter=xcbeautify
fi

name="InterfaceApp"

echo "Test Release Build"
xcodebuild -workspace "$name.xcworkspace" -scheme "$name" -destination 'generic/platform=iOS' -configuration Release build | $formatter
echo "-----------"

echo "Run Unit Tests"
xcodebuild -workspace "$name.xcworkspace" -scheme "$name" -destination "platform=macOS,arch=x86_64,variant=Mac Catalyst" -derivedDataPath Build -enableCodeCoverage YES test | $formatter
echo "-----------"

echo "Test Coverage"
xcrun xccov view --only-targets --report Build/Logs/Test/*.xcresult

coverage=$(xcrun xccov view --report Build/Logs/Test/*.xcresult --json | python3 -c "import json,sys;obj=json.load(sys.stdin);print(obj['lineCoverage']);")
echo "Test coverage: $coverage"

if (( $(echo "$coverage > 0.95" | bc -l) )); then
    echo "✅ Coverage OK"
else
    echo "🛑 Coverage Bad"
    exit 1
fi
