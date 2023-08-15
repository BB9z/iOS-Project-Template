/*
 CollectionStateTracker
 AppFramework

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import Foundation

/**
 追踪一个集合都有哪些元素处于特定状态，每个操作都返回变化的元素集合

 实现备忘：

 考虑有相同元素的情况，用 Equatable 全遍历，这样效率会比较低，但还好这个类的使用场景不会有太多元素。
 如果找第一个相同的结束遍历，有多个相同元素时判定又是个问题。
 */
public final class CollectionStateTracker<Element: Equatable> {
    var elements = [Element]()

    // 与 activedElements 同时更新，维护序号，提高访问效率
    private(set) var activedIndexs = IndexSet()
    private(set) var activedElements = [Element]()

    public typealias Result = (actived: [Element], deactived: [Element])

//    func update(elements: [Element], keepActive: Bool) -> Result {
//
//    }

    /// 激活单个元素
    public func active(_ element: Element) -> Result {
        if activedElements.contains(element) {
            return ([], [])
        }
        var changeSet = [Element]()
        for (idx, elm) in elements.enumerated() where elm == element {
            active(idx: idx, elm: elm)
            changeSet.append(elm)
        }
        return (changeSet, [])
    }

    /// 将多个元素设置为激活状态
    public func active(_ elements: [Element]) -> Result {
        let actived = elements.filter { !activedElements.contains($0) }
        guard !actived.isEmpty else {
            return ([], [])
        }
        var changeSet = [Element]()
        for (idx, elm) in self.elements.enumerated() where actived.contains(elm) {
            active(idx: idx, elm: elm)
            changeSet.append(elm)
        }
        return (changeSet, [])
    }

    /// 取消激活单个元素
    public func deactive(_ element: Element) -> Result {
        if !activedElements.contains(element) {
            return ([], [])
        }
        var changeSet = [Element]()
        for (idx, elm) in elements.enumerated() where elm == element {
            deactive(idx: idx, elm: elm)
            changeSet.append(elm)
        }
        return ([], changeSet)
    }

    /// 取消多个元素的激活状态
    public func deactive(_ elements: [Element]) -> Result {
        let deactived = elements.filter { activedElements.contains($0) }
        guard !deactived.isEmpty else {
            return ([], [])
        }
        var changeSet = [Element]()
        for (idx, elm) in self.elements.enumerated() where deactived.contains(elm) {
            deactive(idx: idx, elm: elm)
            changeSet.append(elm)
        }
        return ([], changeSet)
    }

    private func active(idx: Int, elm: Element) {
        if let insertIndex = activedIndexs.firstIndex(where: { $0 > idx }) {
            let offset = activedIndexs.distance(from: activedIndexs.startIndex, to: insertIndex)
            activedElements.insert(elm, at: offset)
        } else {
            activedElements.append(elm)
        }
        activedIndexs.insert(idx)
    }

    private func deactive(idx: Int, elm: Element) {
        if let removeIndex = activedIndexs.firstIndex(of: idx) {
            let offset = activedIndexs.distance(from: activedIndexs.startIndex, to: removeIndex)
            activedIndexs.remove(idx)
            activedElements.remove(at: offset)
        } else {
            assertionFailure()
        }
    }
}
