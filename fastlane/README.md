fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
### check_metadata
```
fastlane check_metadata
```
检视 fastlane 配置
### setup_project
```
fastlane setup_project
```
安装整个项目依赖
### sort_project
```
fastlane sort_project
```
项目文件内容排序整理

----

## iOS
### ios test
```
fastlane ios test
```
Runs all the tests
### ios alpha
```
fastlane ios alpha
```
打包上传到 fir.im
### ios beta
```
fastlane ios beta
```
打包上传到 TestFlight

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
