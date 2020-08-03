#! /bin/bash
# Copyright © 2014, 2018, 2020 BB9z.
# Copyright © 2016-2017 Beijing ZhiYun ZhiYuan Technology Co., Ltd.

echo "MBAutoBuildScript 1.0"
echo "-----------------------"
set -euo pipefail

# 解决 Ruby 脚本编码问题
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Clean 没有必要执行
if [[ $ACTION = "clean" ]]; then
  echo "清理"
  exit 0
fi

cd "$ScriptPath"
readonly timeFile=$"$ScriptPath/PreBuild.time"

# 验证项目文件
ruby "./ProjectFileVerification.rb"
test 0 -ne $? && exit 1

# 文件夹自动排序
if [[ $EnableAutoGroupSortByName = "YES" && $ACTION = "" && $CONFIGURATION = "Debug" && $USER != "_xcsbuildd" ]]; then
  if [ -n "$(find "$SRCROOT" -name project.pbxproj -newer "$timeFile")" ]; then
    perl -w "$ScriptPath/sort-Xcode-project-file.pl" "$PROJECT_FILE_PATH"
    echo "error: 整理 project.pbxproj，请重新编译项目"
    touch "$timeFile"
    exit 1
  else
    echo "跳过 project.pbxproj 整理"
  fi
fi

# 代码审查强制立即修改
# USER="User for test"
readonly codeReviewCommandList=$(find "$SRCROOT" \( -name "*.h" -or -name "*.m" -or -name "*.mm" -or -name "*.c" \) -print0 | xargs -0 egrep --with-filename --line-number --only-matching "// ($CodeReviewFixRightNowKeywordsExpression)\(($USER)\).*\$")
if [[ -n "$codeReviewCommandList" ]]; then
  echo "请你（$USER）立即对以下代码进行修改"
  echo "$codeReviewCommandList" | perl -p -e "s/\/\/ ($CodeReviewFixRightNowKeywordsExpression)\(($USER)\)/: CodeReview评级\(\$1\)/"
  exit 2
fi

# 特定注释高亮
if [ $EnableCodeCommentsHighlight = "YES" ]; then
  # When find return nothing, grep will fail. Just ignore pipefail instead of strictly checking to improve performance.
  set +o pipefail
  find "$SRCROOT" \( \( -not -path "${SRCROOT}/Pods/*" \) -and \( -name "*.swift" -or -name "*.h" -or -name "*.m" -or -name "*.mm" -or -name "*.c" \) \) -print0 | xargs -0 egrep --with-filename --line-number --only-matching "// ($CodeCommentsHighlightKeywordsExpression):.*\$" | perl -p -e "s/\/\/ ($CodeCommentsHighlightKeywordsExpression):/ warning: \$1/"
  set -o pipefail
fi

touch "$timeFile"
