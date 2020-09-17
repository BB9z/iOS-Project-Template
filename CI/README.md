# CI 说明

## 特色功能

- 高效的 CocoaPods 配置：自动跳过 install，缓存，按需 repo update；
- 支持自动/手动代码签名，手动代码签名支持 provisioning profile 、证书自动更新；
- dSYMs 符号文件打包；
- fir.im 上传，可选从哪个环境变量载入 token。

⚠️ p12 导入功能目前不够完善，导入后的访问权限没设置好，可能导致在 build 最后阶段卡住，如果出现这种情况先手动导入。

⚠️ 初次使用请按需修改 deploy 步骤下的 tags，以便 CI 能跑在正确的环境下。

## commit message 行为控制

除了基本的用 `[ci skip]` 跳过 CI 外，额外添加以下开关：

* `[ci clean]` 清理编译
* `[ci verbose]` 输出更多信息
