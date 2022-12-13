# ci_scripts

脚本目录，存放日常用脚本和部分 CI/CD 脚本。目录名以前是 Scripts，为支持 Xcode Cloud 更名为此（Xcode Cloud 定死改不了，弄两个脚本目录也难看）。

🎯 开头的 command 脚本是用来快捷执行常用操作的，我一般直接在 Xcode 中右键 "Open with External Editor" 直接运行。如果系统提示未认证的开发者禁止运行，可通过在 Finder（访达）中右键，选择 "打开" 来解除限制。

## GitLab CI 脚本

### 特色功能

- 高效的 CocoaPods 配置：自动跳过 install，缓存，按需 repo update；
- 支持自动/手动代码签名，手动代码签名支持 provisioning profile 、证书自动更新；
- dSYMs 符号文件打包；
- fir.im 上传，可选从哪个环境变量载入 token。

⚠️ 初次使用请按需修改 deploy 步骤下的 tags，以便 CI 能跑在正确的环境下。

### commit message 行为控制

除了基本的用 `[ci skip]` 跳过 CI 外，额外添加以下开关：

- `[ci clean]` 清理编译
- `[ci verbose]` 输出更多信息

## Xcode Cloud 脚本

只用了 `ci_post_clone.sh`，用以安装 CocoaPods 依赖。

[Xcode Cloud 使用](https://developer.apple.com/documentation/xcode/writing-custom-build-scripts)
