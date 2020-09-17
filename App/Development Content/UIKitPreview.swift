/*
 UIKitPreview.swift

 Copyright © 2020 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

#if PREVIEW

/**
 让 UIKit 也能利用 SwiftUI Preview 特性

 目前的实现与项目模版深度绑定

 示例

 ```
 #if PREVIEW
 import SwiftUI
 struct HomeVCPreview: PreviewProvider {
     static var previews: some View {
         ViewControllerPreview {
             HomeViewController.newFromStoryboard()
         }
     }
 }
 #endif
 ```

 参考:

 - [技术选型: 有助更快开发的工具](https://github.com/BB9z/iOS-Project-Template/wiki/%E6%8A%80%E6%9C%AF%E9%80%89%E5%9E%8B#tools-implement-faster)
 - [Swift​UI Previews on macOS Catalina and Xcode 11 - NSHipster](https://nshipster.com/swiftui-previews/)

 */
enum PreviewReadme {}

import SwiftUI

/// 预览 UIViewController，适应项目模版，设置了导航等
struct ViewControllerPreview: UIViewControllerRepresentable {
    typealias UIViewControllerType = RootViewController

    let viewController: UIViewController

    init(_ builder: @escaping () throws -> UIViewController) {
        do {
            try viewController = builder()
        } catch {
            print("💢 Preview 内容生成失败 \(error)")
            viewController = Self.content(error: error)
        }
    }

    static func content(error: Error?) -> UIViewController {
        let vc = UIViewController()
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        if let error = error {
            label.text = "Preview 内容生成失败\n\(error)"
        } else {
            label.text = "Preview 因未知原因生成失败"
        }
        label.translatesAutoresizingMaskIntoConstraints = false
        let container = vc.view!
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: container.leadingAnchor, multiplier: 1)
        ])
        return vc
    }

    func makeUIViewController(context: Context) -> UIViewControllerType {
        AppNavigationController()!.pushViewController(viewController, animated: false)
        return AppRootViewController()!
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        return
    }
}

// MARK: -

/// 直接预览 UIView
struct UIViewPreview<View: UIView>: UIViewRepresentable {
    let view: View

    init(_ builder: @escaping () -> View) {
        view = builder()
    }

    func makeUIView(context: Context) -> UIView {
        return view
    }

    func updateUIView(_ view: UIView, context: Context) {
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}

/// 直接预览 UIViewController
struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    let viewController: ViewController

    init(_ builder: @escaping () -> ViewController) {
        viewController = builder()
    }

    func makeUIViewController(context: Context) -> ViewController {
        viewController
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        return
    }
}
#endif
