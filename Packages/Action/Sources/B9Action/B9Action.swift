/*
 B9Action.swift

 Copyright © 2021-2022 BB9z.
 https://github.com/b9swift/Action

 The MIT License
 https://opensource.org/licenses/MIT
 */

import Foundation

/**
 一个简单的基础组件，主要目的是为 target/selector 模式和 block 调用提供统一的界面

 A simple foundational component, primarily intended to provide a uniform interface for target/selector patterns and block invocations.
 */
public final class Action {
    /// Action 触发时接收 selector 消息的对象
    ///
    /// The object that receives the selector message when the action is triggered.
    public weak var target: AnyObject?

    /// Action 触发时向 target 发送的消息
    ///
    /// The message sent to the target when the action is triggered.
    public var selector: Selector?

    /// Action 触发时执行的闭包
    ///
    /// The closure executed when the action is triggered.
    public var block: (() -> Void)?

    /// Action 初始化时设置的参照对象。当该对象被释放时，action 将变为无效的，任何操作将不再被执行
    ///
    /// The reference object set when the action is initialized. When this object is released, the action will become invalid and no operation can be executed.
    private(set) weak var reference: AnyObject?
    private let hasReferenceSet: Bool

    /// 创建一个 target/selector 模式的 Action 对象
    /// Create an Action object with target/selector patterns
    ///
    /// - Parameters:
    ///   - target: `target` 属性
    ///   - target: The `target` property.
    ///   - selector: `selector` 属性
    ///   - selector: The `selector` property.
    ///   - reference: `reference` 属性
    ///   - reference: The `reference` property.
    public init(target: AnyObject?, selector: Selector, reference: AnyObject? = nil) {
        self.target = target
        self.selector = selector
        hasReferenceSet = reference != nil
        self.reference = reference
    }

    /// 创建一个闭包调用模式的 Action 对象
    /// Create an action object with closure call
    ///
    /// - Parameters:
    ///   - action: `block` 属性
    ///   - action: The `block` property.
    ///   - reference: `reference` 属性
    ///   - reference: The `reference` property.
    public init(_ action: @escaping () -> Void, reference: AnyObject? = nil) {
        block = action
        hasReferenceSet = reference != nil
        self.reference = reference
    }

    /// 执行 Action
    /// Perform this action
    ///
    /// 如果 target、selector 和 block 均不为 nil，会先向 target 发送 selector，再调用 block
    /// If target, selector and block are not nil, the selector will be sent to the target first, and then the block will be called.
    ///
    /// - Parameter obj: 向 target 发送 selector 消息时附带的对象，闭包调用忽略
    /// - Parameter obj: An object sent with the selector message to the target, ignored when the closure is called.
    public func perform(with obj: Any?) {
        guard isValid else { return }
        if let selector = selector {
            _ = target?.perform(selector, with: obj)
        }
        if let action = block {
            action()
        }
    }

    /// Action 是否仍有效，当 Action 是无效时，执行 perform 方法无操作
    /// Whether this action is still or not. Execute the perform method with no action if the action is invalid.
    ///
    /// 若初始化时设置了 reference 对象，仅当该对象未释放时是有效的
    /// If a reference object is set during initialization, it is valid only when the reference is not released.
    public var isValid: Bool {
        if hasReferenceSet, reference == nil { return false }
        return true
    }
}

#if os(iOS)
import UIKit

extension Action {
    /// 通过响应者链发送 action 消息
    /// Perform action through responder chain.
    ///
    /// 必需在主线程调用
    /// Must be called on the main queue
    ///
    /// - Parameter sender: 向 target 发送 selector 消息时附带的对象，闭包调用忽略
    /// - Parameter sender: An object sent with the selector message to the target, ignored when the closure is called.
    public func perform(sender: Any?) {
        if #available(iOS 10.0, *) {
            dispatchPrecondition(condition: .onQueue(.main))
        }
        guard isValid else { return }
        if let selector = selector {
            UIApplication.shared.sendAction(selector, to: target, from: sender, for: nil)
        }
        if let action = block {
            action()
        }
    }
}

#elseif os(macOS)
import AppKit

extension Action {
    /// 通过响应者链发送 action 消息
    /// Perform action through responder chain.
    ///
    /// 必需在主线程调用
    /// Must be called on the main queue
    ///
    /// - Parameter sender: 向 target 发送 selector 消息时附带的对象，闭包调用忽略
    /// - Parameter sender: An object sent with the selector message to the target, ignored when the closure is called.
    public func perform(sender: Any?) {
        if #available(macOS 10.12, *) {
            dispatchPrecondition(condition: .onQueue(.main))
        }
        guard isValid else { return }
        if let selector = selector {
            NSApp.sendAction(selector, to: target, from: sender)
        }
        if let action = block {
            action()
        }
    }
}

#endif

extension Action: CustomDebugStringConvertible {
    public var debugDescription: String {
        let properties: [(String, Any?)] = [("target", target), ("selector", selector), ("block", block), ("reference", reference), ("isValid", isValid)]
        let propertyDescription = properties.compactMap { key, value in
            if let value = value {
                return "\(key) = \(value)"
            }
            return nil
        }.joined(separator: ", ")
        return "<Action \(Unmanaged.passUnretained(self).toOpaque()): \(propertyDescription)>"
    }
}

/**
 延迟一段时间再执行 Action 对象，典型场景：setNeedsDoSomething 模式
 Perform an action object after delay. Typical scenarios: setNeedsDoSomething pattern.

 例如：
 eg.
 ```
 // 创建延迟控制器
 // Create delay controller
 lazy var needsSave = DelayAction(delay: 0.3, action: Action(target: self, selector: #selector(save)))

 // 当需要保存时调用
 // Called when saving is required
 needsSave.set()
 ```
 */
public final class DelayAction {
    /// Action 对象
    /// An action object.
    public let action: Action

    /// 触发 Action 所在的队列
    /// The queue which the action is performed on.
    public let queue: DispatchQueue

    /// Action 延迟触发的时长
    /// The length of time that the action needs to be delayed.
    public let delay: TimeInterval

    /// 创建一个 DelayAction 对象
    /// Create a DelayAction object
    ///
    /// - Parameters:
    ///   - action: Action 对象
    ///   - action: An action object
    ///   - delay: 延迟执行的时间，不能为负
    ///   - delay: The duration of the action is delayed. Must not be negative.
    ///   - queue: Action 执行所在的队列，默认为主线程队列
    ///   - queue: Action will be performed on this queue. If not specified, the main queue will be use.
    public init(_ action: Action, delay: TimeInterval = 0, queue: DispatchQueue = .main) {
        precondition(delay >= 0)
        self.action = action
        self.delay = delay
        self.queue = queue
    }

    deinit {
        work?.cancel()
    }

    /// 标记 Action 需要被执行，实际操作会在延时一定时间后在指定队列上触发
    /// Mark the action needs to be performed. The actual operation will be triggered on the specified queue after a certain delay.
    ///
    /// - Parameter reschedule: 为 true 重新安排延迟时间
    /// - Parameter reschedule: Reschedule the delay time for true
    public func set(reschedule: Bool = false) {
        lock.lock()
        defer { lock.unlock() }
        if needs {
            if !reschedule { return }
        }
        needs = true
        let newItem = DispatchWorkItem { self.fired() }
        queue.asyncAfter(deadline: .now() + delay, execute: newItem)
        work?.cancel()
        work = newItem
    }

    /// 重置执行标记并取消计划中的执行
    /// Reset the marks and cancel any scheduled.
    public func cancel() {
        lock.lock()
        defer { lock.unlock() }
        needs = false
        work?.cancel()
        work = nil
    }

    private let lock = NSLock()
    private var needs: Bool = false
    private var work: DispatchWorkItem?

    private func fired() {
        lock.lock()
        guard needs else {
            lock.unlock()
            return
        }
        needs = false
        work = nil
        lock.unlock()
        action.perform(with: nil)
    }
}
