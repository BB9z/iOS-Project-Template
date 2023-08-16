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

 集合中重复元素会被去除
 */
public final class CollectionStateTracker<Element: Hashable> {

    public var elements: [Element] {
        get {
            elementStorage.array as? [Element] ?? []
        }
        set {
            elementStorage = NSMutableOrderedSet(array: newValue)
        }
    }
    public var activedElements: [Element] {
        activedStorage.array as? [Element] ?? []
    }

    private var elementStorage = NSMutableOrderedSet()

    // 与 activedIndexs 同时更新，提高访问效率
    private var activedStorage = NSMutableOrderedSet()
    private(set) var activedIndexs = IndexSet()

    public typealias Result = (actived: [Element], deactived: [Element])

//    func update(elements: [Element], keepActive: Bool) -> Result {
//    }

    /// 激活单个元素
    public func active(_ element: Element) -> Result {
        if activedStorage.contains(element) {
            return ([], [])
        }
        let idx = elementStorage.index(of: element)
        if idx == NSNotFound {
            return ([], [])
        }
        active(idx: idx, elm: element)
        return ([element], [])
    }

    /// 将多个元素设置为激活状态
    public func active(_ elements: [Element]) -> Result {
        let actived: Set = Set(elements).subtracting(activedStorage.set)
        var changeSet = [Element]()
        for (idx, elm) in self.elements.enumerated() where actived.contains(elm) {
            active(idx: idx, elm: elm)
            changeSet.append(elm)
        }
        return (changeSet, [])
    }

    /// 取消激活单个元素
    public func deactive(_ element: Element) -> Result {
        let idxInActive = activedStorage.index(of: element)
        if idxInActive == NSNotFound {
            return ([], [])
        }
        activedStorage.removeObject(at: idxInActive)
        activedIndexs.remove(elementStorage.index(of: element))
        return ([], [element])
    }

    /// 取消多个元素的激活状态
    public func deactive(_ elements: [Element]) -> Result {
        let deactived = elements.filter { activedStorage.contains($0) }
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
            activedStorage.insert(elm, at: offset)
        } else {
            activedStorage.add(elm)
        }
        activedIndexs.insert(idx)
    }

    private func deactive(idx: Int, elm: Element) {
        if let removeIndex = activedIndexs.firstIndex(of: idx) {
            let offset = activedIndexs.distance(from: activedIndexs.startIndex, to: removeIndex)
            activedIndexs.remove(idx)
            activedStorage.removeObject(at: offset)
        } else {
            assertionFailure()
        }
    }
}
