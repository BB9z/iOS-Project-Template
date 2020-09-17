#! /bin/zsh

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

# 分支名
readonly CI_COMMIT_MESSAGE=${CI_COMMIT_MESSAGE:="$(logWarning 'CI_COMMIT_REF_NAME 未设置，可能非 GitLab CI 环境')"}
logInfo "CI_COMMIT_MESSAGE = $CI_COMMIT_MESSAGE"
isVerbose=false
if [[ "$CI_COMMIT_MESSAGE" = *"[ci verbose]"* ]]; then
    logWarning "verbose 已激活"
    isVerbose=true
fi

readonly XC_BUILD_SCHEME="${XC_BUILD_SCHEME:? 必须设置}"
logInfo "XC_BUILD_SCHEME = $XC_BUILD_SCHEME"
readonly XC_BUILD_WORKSPACE="${XC_BUILD_WORKSPACE:? 必须设置}"
logInfo "XC_BUILD_WORKSPACE = $XC_BUILD_WORKSPACE"
readonly XC_BUILD_CONFIGURATION="${XC_BUILD_CONFIGURATION:="$(logWarning 'XC_BUILD_CONFIGURATION 未设置，默认 Release')Release"}"
logInfo "XC_BUILD_CONFIGURATION = $XC_BUILD_CONFIGURATION"

readonly XC_PROVISIONING_ID=${XC_PROVISIONING_ID:="$(logWarning 'XC_PROVISIONING_ID 未设置')"}
if [ -n "$XC_PROVISIONING_ID" ]; then
    logInfo "XC_PROVISIONING_ID = $XC_PROVISIONING_ID"
fi
readonly XC_CODE_SIGN_IDENTITY=${XC_CODE_SIGN_IDENTITY:="$(logWarning 'XC_CODE_SIGN_IDENTITY 未设置')"}
if [ -n "$XC_CODE_SIGN_IDENTITY" ]; then
    logInfo "XC_CODE_SIGN_IDENTITY = $XC_CODE_SIGN_IDENTITY"
fi
readonly XC_IMPORT_PROVISIONING_PATH=${XC_IMPORT_PROVISIONING_PATH:=""}
logInfo "XC_IMPORT_PROVISIONING_PATH = $XC_IMPORT_PROVISIONING_PATH"
readonly XC_IMPORT_CERTIFICATE_PATH=${XC_IMPORT_CERTIFICATE_PATH:=""}
logInfo "XC_IMPORT_CERTIFICATE_PATH = $XC_IMPORT_CERTIFICATE_PATH"
readonly XC_IMPORT_CERTIFICATE_PASSWORD=${XC_IMPORT_CERTIFICATE_PASSWORD:=""}

FIR_UPLOAD_TOKEN=${FIR_UPLOAD_TOKEN:="$(logWarning 'FIR_UPLOAD_TOKEN 未设置')"}
if [ -n "$FIR_UPLOAD_TOKEN" ]; then
    logInfo "FIR_UPLOAD_TOKEN 将从 $FIR_UPLOAD_TOKEN 变量读取"
    FIR_UPLOAD_TOKEN=$(eval echo -e "\$$FIR_UPLOAD_TOKEN")
fi

readonly ARCHIVE_PATH="./$(date "+%Y-%m-%d %H.%M.%S").xcarchive"
readonly EXPORT_OPTIONS_PLIST="${EXPORT_OPTIONS_PLIST:="$(logWarning 'EXPORT_OPTIONS_PLIST 未设置，使用默认路径')./ci/ExportOptions.plist"}"
logInfo "EXPORT_OPTIONS_PLIST = $EXPORT_OPTIONS_PLIST"
readonly EXPORT_DIRECTORY_PATH="./export"
readonly EXPORT_IPA_PATH="$EXPORT_DIRECTORY_PATH/$XC_BUILD_SCHEME.ipa"

xcodebuild -version

logSection "配置更新"
isNeedsPodInstall=false
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

if [ -n "$XC_IMPORT_CERTIFICATE_PATH" ]; then
    if [ -z "$XC_IMPORT_CERTIFICATE_PASSWORD" ]; then
        logError "安装证书已指定，但是密码未设置"
        exit 1
    fi
    logInfo "导入签名证书"
    security import "$XC_IMPORT_CERTIFICATE_PATH" -P "$XC_IMPORT_CERTIFICATE_PASSWORD" -T /usr/bin/codesign
fi

if [ -n "$XC_IMPORT_PROVISIONING_PATH" ]; then
    logInfo "导入 provision profile"
    open "$XC_IMPORT_PROVISIONING_PATH"
fi

logSection "项目构建"
if [[ "$CI_COMMIT_MESSAGE" = *"[ci clean]"* ]]; then
    logWarning "提交信息指定项目清理"
    xcodebuild clean -workspace "$XC_BUILD_WORKSPACE" -scheme "$XC_BUILD_SCHEME" | xcpretty
fi

buildAddtionalOptions=""
xcprettyOptions=$(( $isVerbose && echo "" ) || echo "-t" )
if [ -n "$XC_PROVISIONING_ID" ] && [ -n "$XC_CODE_SIGN_IDENTITY" ]; then
    logInfo "指定签名，开始编译..."
    xcodebuild archive -archivePath "$ARCHIVE_PATH" \
        -workspace "$XC_BUILD_WORKSPACE" -scheme "$XC_BUILD_SCHEME" \
        -configuration "$XC_BUILD_CONFIGURATION" -destination generic/platform=iOS \
        CODE_SIGN_STYLE="Manual" PROVISIONING_PROFILE_SPECIFIER="$XC_PROVISIONING_ID" CODE_SIGN_IDENTITY="$XC_CODE_SIGN_IDENTITY" |
        xcpretty $xcprettyOptions
else
    logInfo "XC_PROVISIONING_ID 或 XC_CODE_SIGN_IDENTITY 未设置，尝试自动签名，开始编译..."
    xcodebuild archive -archivePath "$ARCHIVE_PATH" \
        -workspace "$XC_BUILD_WORKSPACE" -scheme "$XC_BUILD_SCHEME" \
        -configuration "$XC_BUILD_CONFIGURATION" -destination generic/platform=iOS |
        xcpretty $xcprettyOptions
fi

logSection "项目打包"
xcodebuild -exportArchive -archivePath "$ARCHIVE_PATH" -exportPath "$EXPORT_DIRECTORY_PATH" -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" | xcpretty $xcprettyOptions

dSYMsCount=$(find "$ARCHIVE_PATH/dSYMs" -d 1 -name "*.dSYM" | wc -l)
if [ $dSYMsCount -ge 1 ]; then
    logInfo "归档 dSYMs 文件"
    find "$ARCHIVE_PATH/dSYMs" -d 1 -name "*.dSYM" -print0 | while read -d $'\0' file; do
        logInfo "压缩 $file"
        zip -r -X "$EXPORT_DIRECTORY_PATH/$(basename $file).zip" "$file/"
    done
else
    logWarning "项目设置未生成 dSYMs 文件，跳过归档"
fi

logSection "应用包上传"
if [ -n "$FIR_UPLOAD_TOKEN" ]; then
    logInfo "上传到 fir.im"
    fir publish "$EXPORT_IPA_PATH" -T "$FIR_UPLOAD_TOKEN" --open
else
    logInfo "跳过上传"
fi
