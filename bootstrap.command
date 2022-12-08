#! /bin/sh

# 项目初始化：项目自动更名，重建 git，检查工具依赖等
# Copyright © 2019, 2022 BB9z.
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

# 确认用户输入 y/n
#
# $1: 提示输入的文本
# return: "y" or "n"
AskYesOrNo () {
    logInput "$1 [y/n]"

    read input
    while [ "$input" != "y" ] && [ "$input" != "n" ]; do
        logInput "y/n?"
        read input
    done

    echo "$input"
}

# 得到经用户二次确认的输入
# 
# $1: 提示输入的文本
# return: 用户输入的非空文本
GetConfirmedInput () {
    readonly local title=$1
    logInput "$title"

    local isConfirmed="n"
    local input=""
    while [[ $isConfirmed == "n" ]]; do
        read input
        if [ -z $input ]; then
            logError "输入为空"
        else
            if [ $( AskYesOrNo "确认是${input}吗？" ) == "y" ]; then
                isConfirmed="y"
            else
                logInput "$title"
            fi
        fi
    done
    echo "$input"
}

# 
SedReplaceFormat () {
    # https://unix.stackexchange.com/a/112024
    sed 's/[]$&^*\./[]/\\&/g
     s| *\([^ ]*\) *\([^ ]*\).*|s/\1/\2/g|
' <<< "$1"
}

# 对文件执行文本替换
#
# $1: 旧文本，暂不支持包含空格
# $2: 新文本，暂不支持包含空格
# $3: 文件路径
SedReplaceFileContent () {
    local format=$(SedReplaceFormat "$1 $2")
    sed -i '' "$format" "$3"
}

isValidProductName () {
    if [ -z "$1" ]; then
        logError "项目名为空"
        return 1
    elif [[ "$1" = *" "* ]]; then
        logError "暂不支持包含空格的项目名"
        return 1
    elif [[ "$1" = *"/"* ]] || [[ "$1" = *":"* ]]; then
        logError "项目名中含有非法符号"
        return 1
    else
        return 0
    fi
}

logInfo "本脚本将辅助你完成项目初始化"
logInfo "在开始前先收集一些信息"

isNeedsRename=false
readonly oldName="App"
name="$oldName"
if [ $( AskYesOrNo "是否需要重命名项目？" ) == "y" ]; then
    isNeedsRename=true

    logWarning "项目名由纯英文构成，不要包含空格、符号，否则脚本可能失败甚至损坏项目文件"
    name=$(GetConfirmedInput "请输入新的项目名:")
fi

isValidProductName "$name" || {
    exit
}

isNeedsRecreateGit=false
gitRemoteURL=""
if [ $( AskYesOrNo "是否需要重建 git 仓库？" ) == "y" ]; then
    isNeedsRecreateGit=true
    if ! [ -x "$(command -v git)" ]; then
        logError "git 命令不存在"
        exit
    fi

    logInput "请输入新的仓库地址，为空跳过:"
    logInfo  "  例：https://example.com/path.git, git@example.com:path.git"
    read gitRemoteURL
    if [ -z "$gitRemoteURL" ]; then
        logInfo "跳过仓库地址设置"
    fi
fi

echo ""
logWarning "即将开始操作，请关闭打开的项目，并确认以下信息"
if $isNeedsRename ; then
    logInfo " * 项目更名：$name"
else
    logInfo " * 跳过项目更名"
fi

if $isNeedsRecreateGit ; then
    logInfo " * 重建 git 仓库"
    if [ -n "$gitRemoteURL" ]; then
        logInfo " * 仓库远端地址：$gitRemoteURL"
    fi
else
    logInfo " * 不重建 git 仓库"
fi

logInfo " * 重新 pod install"
logInfo " * 检查工具依赖是否安装"

echo ""
echo "点击任意键继续，如需终止按 Ctrl+C"
read -n 1 -s -r
echo ""

readonly backupDir="Backup/$(date "+%Y-%m-%d %H.%M.%S")"
logInfo "备份文件到 $backupDir"
mkdir -pv "$backupDir"

if $isNeedsRename ; then
    logInfo "  $oldName.xcworkspace"
    cp -R "$oldName.xcworkspace" "$backupDir/$oldName.xcworkspace"

    logInfo "  $oldName.xcodeproj"
    cp -R "$oldName.xcodeproj" "$backupDir/$oldName.xcodeproj"

    logInfo "  Podfile"
    cp "Podfile" "$backupDir/Podfile"
fi

if $isNeedsRecreateGit ; then
    logInfo "  .git"
    mv ".git" "$backupDir/.git"

    logInfo "重建 git 仓库"
    git init
    if [ -n "$gitRemoteURL" ]; then
        logInfo "设置 remote 地址"
        git remote add origin "$gitRemoteURL"
    fi
fi

if $isNeedsRename ; then
    logInfo "准备修改命名为：$name"
    logInfo "  当前改名的实现比较简单，直接对文本进行替换，如果失败请从备份目录找回文件手动改名"
    logInfo "  也可到 https://github.com/BB9z/iOS-Project-Template/issues 提醒我修正"

    SedReplaceFileContent "$oldName.xcodeproj" "$name.xcodeproj" "$oldName.xcworkspace/contents.xcworkspacedata"

    SedReplaceFileContent "Pods-$oldName" "Pods-$name" "$oldName.xcodeproj/project.pbxproj"
    SedReplaceFileContent "$oldName.app"  "$name.app"  "$oldName.xcodeproj/project.pbxproj"
    sed -i '' "s/name = $oldName;/name = \"$name\";/g" "$oldName.xcodeproj/project.pbxproj"
    sed -i '' "s/Name = $oldName;/Name = \"$name\";/g" "$oldName.xcodeproj/project.pbxproj"

    SedReplaceFileContent '"$oldName"'      '"$name"'            "$oldName.xcodeproj/xcshareddata/xcschemes/$oldName.xcscheme"
    SedReplaceFileContent '"$oldName.app"'  '"$name.app"'        "$oldName.xcodeproj/xcshareddata/xcschemes/$oldName.xcscheme"
    SedReplaceFileContent "$oldName.xcodeproj" "$name.xcodeproj" "$oldName.xcodeproj/xcshareddata/xcschemes/$oldName.xcscheme"

    sed -i '' "s/target '$oldName' do/target '$name' do/g" "Podfile"

    mv -v "$oldName.xcworkspace" "$name.xcworkspace"
    mv -v "$oldName.xcodeproj"   "$name.xcodeproj"
fi

if ! [ -x "$(command -v pod)" ]; then
    logWarning "CocoaPods 貌似没有安装，请执行 brew install cocoapods 进行安装"
else
    logInfo "重新 pod install"
    pod install
fi

logInfo "整理项目文件"
ci_scripts/sort_projects.sh

echo "项目设置完成"
logInfo "  检查一切 OK 后，可删除 Backup 目录，bootstrap 脚本也建议删除"
open "$name.xcworkspace"
