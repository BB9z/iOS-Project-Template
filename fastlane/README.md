fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### check_metadata

```sh
[bundle exec] fastlane check_metadata
```

检视 fastlane 配置

### setup_project

```sh
[bundle exec] fastlane setup_project
```

安装整个项目依赖

### sort_project

```sh
[bundle exec] fastlane sort_project
```

项目文件内容排序整理

----


## iOS

### ios test

```sh
[bundle exec] fastlane ios test
```

Runs all the tests

### ios alpha

```sh
[bundle exec] fastlane ios alpha
```

打包上传到 fir.im

### ios beta

```sh
[bundle exec] fastlane ios beta
```

打包上传到 TestFlight

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
