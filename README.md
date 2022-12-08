# *修改为项目名称*

仓库地址 *https://example.com/change-to-repo.git*

## 需求

iOS 13+；Xcode 14.1+；macOS 13+。

依赖：

```sh
brew install cocoapods
brew install fastlane  # 可选
brew install swiftlint # 可选
```

## 配置

项目初始化请双击执行 bootstrap.command，随引导操作。

command 脚本第一次运行时，系统可能会提示未认证的开发者禁止运行。可通过右键菜单，选择打开来解除限制。

正常执行 CocoaPods 安装或用 fastlane 配置即可：

```sh
pod install
或
fastlane setup_project
```

## 关于项目模版

强烈推荐阅读[项目模版 wiki](https://github.com/BB9z/iOS-Project-Template/wiki)内的相关文档。

```text
Copyright © 2018-2022 BB9z.
Copyright © 2014-2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
Copyright © 2013-2014 Chinamobo Co., Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
