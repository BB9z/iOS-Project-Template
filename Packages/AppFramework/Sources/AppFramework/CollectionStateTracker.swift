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
    /// 当前集合中的元素
    public var elements: [Element] {
        elementStorage.array as? [Element] ?? []
    }
    /// 当前激活的元素
    public var activedElements: [Element] { elements(of: activedStorage) }
    /// 当前激活的元素的索引
    public var activedIndexs: IndexSet { activedStorage }

    public init(elements: [Element] = []) {
        elementStorage = NSOrderedSet(array: elements)
    }

    /// 顺序与 elements 一致
    public typealias Result = (actived: [Element], deactived: [Element])

    /**
     更新元素集合

     - Parameters:
     - elements: 新的元素集合
     - keepActive: 是否保持原有激活状态，如果为 false，所有元素都会被取消激活
     */
    public func update(elements: [Element], keepActive: Bool) -> Result {
        let actived = self.activedElements
        elementStorage = NSOrderedSet(array: elements)

        if keepActive {
            activedStorage = indexSet(of: actived)
            let removed = actived.filter { !elementStorage.contains($0) }
            return ([], removed)
        } else {
            activedStorage.removeAll()
            return ([], actived)
        }
    }

    /// 激活单个元素
    public func active(_ element: Element) -> Result {
        active([element])
    }

    /// 将多个元素设置为激活状态
    public func active(_ elements: [Element]) -> Result {
        let newIndexSet = activedStorage.union(indexSet(of: elements))
        return update(activedIndexs: newIndexSet)
    }

    /// 取消激活单个元素
    public func deactive(_ element: Element) -> Result {
        deactive([element])
    }

    /// 取消多个元素的激活状态
    public func deactive(_ elements: [Element]) -> Result {
        let newIndexSet = activedStorage.subtracting(indexSet(of: elements))
        return update(activedIndexs: newIndexSet)
    }

    /// 设置激活的元素，其他元素取消激活
    public func set(activedElements: [Element]) -> Result {
        let newIndexSet = indexSet(of: activedElements)
        return update(activedIndexs: newIndexSet)
    }

    /// 查询元素是否处于激活状态。元素应当是当前集合的成员，否则会触发断言
    public func isActived(_ element: Element) -> Bool {
        let idx = elementStorage.index(of: element)
        if idx == NSNotFound {
            MBAssert(false, "\(self) 不包含元素: \(element).")
            return false
        }
        return activedStorage.contains(idx)
    }

    // MARK: -

    private var elementStorage: NSOrderedSet
    private var activedStorage = IndexSet()
}

extension CollectionStateTracker {
    func elements(of indexSet: IndexSet) -> [Element] {
        if indexSet.isEmpty { return [] }
        return elementStorage.objects(at: indexSet) as? [Element] ?? []
    }

    func indexSet(of elements: [Element]) -> IndexSet {
        let idxs = elements.compactMap {
            let idx = elementStorage.index(of: $0)
            return idx == NSNotFound ? nil : idx
        }
        return IndexSet(idxs)
    }

    private func update(activedIndexs newValue: IndexSet) -> Result {
        let oldValue = activedStorage
        activedStorage = newValue
        let addedIndexs = newValue.subtracting(oldValue)
        let removedIndexs = oldValue.subtracting(newValue)
        return (elements(of: addedIndexs), elements(of: removedIndexs))
    }
}
