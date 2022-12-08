#! /bin/zsh
# 适用于 GitLab 的 iOS 项目打包脚本
# Copyright © 2020, 2022 BB9z.
# https://github.com/BB9z/iOS-Project-Template

set -euo pipefail
echo "$PWD"

logInfo() {
    echo "\033[32m$1\033[0m" >&2
}

logWarning() {
    echo "\033[33m$1\033[0m" >&2
}

logError() {
    echo "\033[31m$1\033[0m" >&2
}

# 蓝色背景
logSection() {
    echo "" >&2
    echo "\033[44m$1\033[0m" >&2
}

logSection "环境检查"
export LANG=en_US.UTF-8

readonly CI_COMMIT_MESSAGE=${CI_COMMIT_MESSAGE:="$(logWarning 'CI_COMMIT_MESSAGE 未设置，可能非 GitLab CI 环境')"}
logInfo "CI_COMMIT_MESSAGE = $CI_COMMIT_MESSAGE"
isVerbose=false
if [[ "$CI_COMMIT_MESSAGE" = *"[ci verbose]"* ]]; then
    logWarning "verbose 已激活"
    isVerbose=true
fi
isCleanEnabled=false
if [[ "$CI_COMMIT_MESSAGE" = *"[ci clean]"* ]]; then
    logWarning "清理已激活"
    isCleanEnabled=true
fi

readonly XC_BUILD_SCHEME="${XC_BUILD_SCHEME:? 必须设置}"
logInfo "XC_BUILD_SCHEME = $XC_BUILD_SCHEME"
readonly XC_BUILD_WORKSPACE="${XC_BUILD_WORKSPACE:? 必须设置}"
logInfo "XC_BUILD_WORKSPACE = $XC_BUILD_WORKSPACE"
readonly XC_BUILD_CONFIGURATION="${XC_BUILD_CONFIGURATION:="$(logWarning 'XC_BUILD_CONFIGURATION 未设置，默认 Release')Release"}"
logInfo "XC_BUILD_CONFIGURATION = $XC_BUILD_CONFIGURATION"

readonly XC_PROVISIONING_ID=${XC_PROVISIONING_ID:="$(logWarning 'XC_PROVISIONING_ID 未设置，将尝试自动签名')"}
if [ -n "$XC_PROVISIONING_ID" ]; then
    logInfo "XC_PROVISIONING_ID = $XC_PROVISIONING_ID"
fi
readonly XC_CODE_SIGN_IDENTITY=${XC_CODE_SIGN_IDENTITY:="$(logWarning 'XC_CODE_SIGN_IDENTITY 未设置，将尝试自动签名')"}
if [ -n "$XC_CODE_SIGN_IDENTITY" ]; then
    logInfo "XC_CODE_SIGN_IDENTITY = $XC_CODE_SIGN_IDENTITY"
fi
readonly XC_IMPORT_PROVISIONING_PATH=${XC_IMPORT_PROVISIONING_PATH:=""}
logInfo "XC_IMPORT_PROVISIONING_PATH = $XC_IMPORT_PROVISIONING_PATH"
readonly XC_IMPORT_CERTIFICATE_PATH=${XC_IMPORT_CERTIFICATE_PATH:=""}
logInfo "XC_IMPORT_CERTIFICATE_PATH = $XC_IMPORT_CERTIFICATE_PATH"
readonly XC_IMPORT_CERTIFICATE_PASSWORD=${XC_IMPORT_CERTIFICATE_PASSWORD:=""}
readonly XC_EXPORT_IPA_NAME="${XC_EXPORT_IPA_NAME:="$(logWarning 'XC_EXPORT_IPA_NAME 未设置，默认 XC_BUILD_SCHEME')$XC_BUILD_SCHEME"}"
logInfo "XC_EXPORT_IPA_NAMEXC_EXPORT_IPA_NAME = $XC_EXPORT_IPA_NAME"

# keychian 的设置可以从外部导入，但默认不推荐修改
readonly KC_NAME=${KC_NAME:="CIBuilder"}
readonly KC_PASSWORD=${KC_PASSWORD:="ci"}

FIR_UPLOAD_TOKEN=${FIR_UPLOAD_TOKEN:="$(logWarning 'FIR_UPLOAD_TOKEN 未设置，将跳过 fir.im 上传')"}
if [ -n "$FIR_UPLOAD_TOKEN" ]; then
    logInfo "FIR_UPLOAD_TOKEN 将从 $FIR_UPLOAD_TOKEN 变量读取"
    FIR_UPLOAD_TOKEN=$(eval echo -e "\$$FIR_UPLOAD_TOKEN")
fi

readonly ARCHIVE_PATH="./$(date "+%Y-%m-%d %H.%M.%S").xcarchive"
readonly EXPORT_OPTIONS_PLIST="${EXPORT_OPTIONS_PLIST:="$(logWarning 'EXPORT_OPTIONS_PLIST 未设置，使用默认路径')./ci_scripts/ExportOptions.plist"}"
logInfo "EXPORT_OPTIONS_PLIST = $EXPORT_OPTIONS_PLIST"
readonly EXPORT_DIRECTORY_PATH="./export"
readonly EXPORT_IPA_PATH="$EXPORT_DIRECTORY_PATH/$XC_EXPORT_IPA_NAME.ipa"

isCIKeycahinCreated=false
errorhandler () {
    logSection "异常清理"

    if $isCIKeycahinCreated; then
        logInfo "清理临时 keychain"
        security delete-keychain "$KC_NAME.keychain"
    fi
}
trap errorhandler ERR

xcodebuild -version

logSection "配置更新"
if [ -f "Podfile" ]; then
    local isNeedsPodInstall=false
    diff "Podfile.lock" "Pods/Manifest.lock" >/dev/null || {
        isNeedsPodInstall=true
    }
    if $isNeedsPodInstall; then
        logInfo "执行 CocoaPods"
        local installOption=$(( $isVerbose && echo "" ) || echo "--silent" )
        pod install $installOption || {
            logError "pod install 失败，尝试更新 repo"
            pod install --repo-update
        }
    else
        logInfo "Podfile 未变化，跳过 CocoaPods 安装"
    fi
else
    logWarning "Podfile 不存在？跳过 CocoaPods 安装"
fi

if [ -n "$XC_IMPORT_PROVISIONING_PATH" ]; then
    logInfo "导入 provision profile"
    open "$XC_IMPORT_PROVISIONING_PATH"
fi

if [ -n "$XC_IMPORT_CERTIFICATE_PATH" ]; then
    if [ -z "$XC_IMPORT_CERTIFICATE_PASSWORD" ]; then
        logError "安装证书已指定，但是密码未设置"
        exit 1
    fi
    logInfo "创建临时 keychain"
    security create-keychain -p "$KC_PASSWORD" "$KC_NAME.keychain" || {
        logWarning "$KC_NAME 可能已存在，将尝试利用现有 keychain，也可以通过设置 KC_NAME 环境变量指定另外一个"
    }
    isCIKeycahinCreated=true
    security list-keychains -d user -s "$KC_NAME.keychain" $(security list-keychains -d user | sed s/\"//g)
    security set-keychain-settings "$KC_NAME.keychain"
    security unlock-keychain -p "$KC_PASSWORD" "$KC_NAME.keychain"
    logInfo "导入签名证书"
    security import "$XC_IMPORT_CERTIFICATE_PATH" -k "$KC_NAME.keychain" -P "$XC_IMPORT_CERTIFICATE_PASSWORD" -T "/usr/bin/codesign"
    security set-key-partition-list -S apple-tool:,apple: -s -k "$KC_PASSWORD" "$KC_NAME.keychain"
fi

logSection "项目构建"
xcprettyOptions=$(( $isVerbose && echo "" ) || echo "-t" )

if $isCleanEnabled; then
    xcodebuild clean -workspace "$XC_BUILD_WORKSPACE" -scheme "$XC_BUILD_SCHEME" | xcpretty $xcprettyOptions
fi

if [ -n "$XC_PROVISIONING_ID" ] && [ -n "$XC_CODE_SIGN_IDENTITY" ]; then
    logInfo "指定签名，开始编译..."
    xcodebuild archive -archivePath "$ARCHIVE_PATH" \
        -workspace "$XC_BUILD_WORKSPACE" -scheme "$XC_BUILD_SCHEME" \
        -configuration "$XC_BUILD_CONFIGURATION" -destination generic/platform=iOS \
        CODE_SIGN_STYLE="Manual" PROVISIONING_PROFILE_SPECIFIER="$XC_PROVISIONING_ID" CODE_SIGN_IDENTITY="$XC_CODE_SIGN_IDENTITY" |
        xcpretty $xcprettyOptions
else
    logInfo "尝试自动签名，开始编译..."
    xcodebuild archive -archivePath "$ARCHIVE_PATH" \
        -workspace "$XC_BUILD_WORKSPACE" -scheme "$XC_BUILD_SCHEME" \
        -configuration "$XC_BUILD_CONFIGURATION" -destination generic/platform=iOS |
        xcpretty $xcprettyOptions
fi

logSection "项目打包"
xcodebuild -exportArchive -archivePath "$ARCHIVE_PATH" -exportPath "$EXPORT_DIRECTORY_PATH" -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" | xcpretty $xcprettyOptions

if $isCIKeycahinCreated; then
    logInfo "清理临时 keychain"
    security delete-keychain "$KC_NAME.keychain"
fi

dSYMsCount=$(find "$ARCHIVE_PATH/dSYMs" -d 1 -name "*.dSYM" | wc -l)
if [ $dSYMsCount -ge 1 ]; then
    logInfo "归档 dSYMs 文件"
    find "$ARCHIVE_PATH/dSYMs" -d 1 -name "*.dSYM" -print0 | while read -d $'\0' file; do
        logInfo "压缩 $file"
        local pushCD="$PWD"
        cd "$(dirname $file)"
        if $isVerbose; then
            echo $PWD
            echo "zip -r -X \"$pushCD/$EXPORT_DIRECTORY_PATH/$(basename $file).zip\" \"$(basename $file)/\""
        fi
        zip -r -X "$pushCD/$EXPORT_DIRECTORY_PATH/$(basename $file).zip" "$(basename $file)/"
        cd "$pushCD"
    done
else
    logWarning "项目设置未生成 dSYMs 文件，跳过归档"
fi

logSection "应用包上传"
if [ -n "$FIR_UPLOAD_TOKEN" ]; then
    logInfo "上传到 fir.im"
    fir publish "$EXPORT_IPA_PATH" -c "$CI_COMMIT_MESSAGE" -T "$FIR_UPLOAD_TOKEN" --open
else
    logInfo "跳过上传"
fi

echo ""
logInfo "🎉 一切正常"
