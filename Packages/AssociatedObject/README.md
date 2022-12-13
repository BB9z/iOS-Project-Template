# B9AssociatedObject

[![Swift Version](https://img.shields.io/badge/Swift-5.3+-F05138.svg?style=flat-square)](https://swift.org)
[![Swift Package Manager](https://img.shields.io/badge/spm-compatible-F05138.svg?style=flat-square)](https://swift.org/package-manager)
[![Build Status](https://img.shields.io/github/workflow/status/b9swift/Action/Swift?style=flat-square&colorA=555555&colorB=F05138)](https://github.com/b9swift/AssociatedObject/actions)
[![gitee 镜像](https://img.shields.io/badge/%E9%95%9C%E5%83%8F-gitee-C61E22.svg?style=flat-square)](https://gitee.com/b9swift/AssociatedObject)
[![GitHub Source](https://img.shields.io/badge/Source-GitHub-24292F.svg?style=flat-square)](https://github.com/b9swift/AssociatedObject)

方便地在 Swift 中利用 Objective-C 关联对象。

Objective-C associated value wrapper for convenient use in Swift. It is primarily used to add attributes to existing types through extensions.

## 集成

使用 Swift Package Manager 或手工导入。

You can also use [GitHub source](https://github.com/b9swift/AssociatedObject).

## Installation

You can use either Swift Package Manager or manual importing to add this package to your project.

你也可以使用 [gitee 镜像](https://gitee.com/b9swift/AssociatedObject)。

## 使用

定义扩展属性可以像下面这样，不仅支持 Objective-C 对象，各种 Swift 类型也支持。

## Usage

You can define extended properties like below. All kinds of Swift types are also supported, not only Objective-C objects.

```swift
import B9AssociatedObject

private let fooAssociation = AssociatedObject<String>()
extension SomeObject {
    var foo: String? {
        get { fooAssociation[self] }
        set { fooAssociation[self] = newValue }
    }
}
```
