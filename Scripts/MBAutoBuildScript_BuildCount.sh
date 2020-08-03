#! /bin/bash
# Copyright © 2020 BB9z.
# Copyright © 2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
# Copyright © 2013-2014 Chinamobo Co., Ltd.

echo "MBAutoBuildScript Build Count 1.0"
echo "-----------------------"
set -euo pipefail

# 自动构建数
if [ $enableAutoBuildCount = 1 ]; then
    readonly branchName=$(git symbolic-ref --short -q HEAD || echo "default");
	readonly output=$(ruby "$scriptPath/MBBuildCount.rb" "$buildCountRecordFile" "$USER" "$branchName")
    # echo "${output}"
    # 最后一行是版本号
    buildnum=$(echo "${output}"|tail -n1)
    echo "warning: 当前版本号 ${buildnum}"
    if [ $buildnum = "-1" ]; then
        echo "${output}"
        echo "error: 脚本执行错误"
    fi
	
	if [ $CONFIGURATION = "Debug" ]; then
		echo "Debug 模式，跳过版本设置"
	else
        # 项目目录中的文件的没有配置文件新
        # 忽略 .git 目录、xcuserdata、xcworkspace、.DS_Store文件和文件夹
		if [ -n "$(find "$SRCROOT" -not \( -name .git -prune \) -newer "$buildCountRecordFile" -not -path "*.xcodeproj/xcuserdata*" -not -path "*.xcodeproj/project.xcworkspace*" -not -name ".DS_Store" -not -type d)"]; then
			infoPlistPath="${PROJECT_DIR}/${INFOPLIST_FILE}"

			if [ -n $(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$infoPlistPath") ]; then
				if [ $autoBuildCountUseDataFormat = 1 ]; then
					buildnum=$(date $autoBuildCountDataFormat)
				fi
				/usr/libexec/PlistBuddy -c "Set CFBundleVersion $buildnum" "$infoPlistPath"
				echo "将版本设置为 $buildnum"
			else
				echo "错误：找不到 Info.plist 中的 CFBundleVersion"
			fi
		else
			echo "跳过版本设置"
		fi
	fi
fi
