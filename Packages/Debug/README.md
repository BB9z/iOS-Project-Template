# B9Debug

[![Swift Version](https://img.shields.io/badge/Swift-5+-F05138.svg?style=flat-square)](https://swift.org)
[![Swift Package Manager](https://img.shields.io/badge/spm-compatible-F05138.svg?style=flat-square)](https://swift.org/package-manager)
[![Build Status](https://img.shields.io/github/workflow/status/b9swift/Debug/Swift?style=flat-square&colorA=555555&colorB=F05138)](https://github.com/b9swift/Debug/actions)
[![gitee 镜像](https://img.shields.io/badge/%E9%95%9C%E5%83%8F-gitee-C61E22.svg?style=flat-square)](https://gitee.com/b9swift/Debug)
[![GitHub Source](https://img.shields.io/badge/Source-GitHub-24292F.svg?style=flat-square)](https://github.com/b9swift/Debug)

为调试提供支持的简单组件。

Some simple components support debugging.

目前只有一个方法 —— `ThrowExceptionToPause()`，通过抛出 NSException 异常起到运行时断点的作用，你需要启用 Objective-C 异常断点。

At the moment there is only one method -- `ThrowExceptionToPause()`, which acts as a runtime breakpoint by throwing an NSException exception. You need to enable the Objective-C exception breakpoint to activate it.

## 集成

使用 Swift Package Manager 或手工导入。

You can also use [GitHub source](https://github.com/b9swift/Debug).

## Installation

Using Swift Package Manager or import manually.

你也可以使用 [gitee 镜像](https://gitee.com/b9swift/Debug)。
