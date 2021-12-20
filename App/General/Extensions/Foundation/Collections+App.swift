/*
 应用级别的便捷方法：对标准库中的集合进行扩展

 除 Array、Dictionary、Set 等顶层结构的扩展放到相应文件外，其余扩展都放这里
 */

extension Sequence where Iterator.Element: Hashable {
    /// 返回去重的序列
    func uniqued() -> [Iterator.Element] {
        var seen = [Iterator.Element: Bool]()
        return filter { seen.updateValue(true, forKey: $0) == nil }
    }
}

extension Collection {

    // @MBDependency:4
    /// 非空，结合空的判断使用起来更容易些
    var isNotEmpty: Bool {
        !isEmpty
    }

    // @MBDependency:3
    /// 安全的获取元素，index 超出范围返回 nil
    func element(at index: Index) -> Element? {
        if startIndex..<endIndex ~= index {
            return self[index]
        }
        return nil
    }

    // 模版 6.x 移除
    @available(*, unavailable, renamed: "element(at:)")
    func rf_object(at index: Index) -> Element? {
        element(at: index)
    }

    // @MBDependency:2
    /**
     遍历集合，同时访问元素和序号，并可随时终止遍历
     */
    func enumerateElements(_ block: (Element, Index, _ stopped: inout Bool) -> Void) {
        var stop = false
        var i = startIndex
        while i != endIndex {
            block(self[i], i, &stop)
            if stop { return }
            i = index(after: i)
        }
    }
}

extension RangeReplaceableCollection where Self: MutableCollection, Index == Int {

    // @MBDependency:3
    /**
     移除指定序号的元素，返回被移除的对象
     */
    @discardableResult mutating func remove(at indexes: IndexSet) -> [Element] {
        // via: https://stackoverflow.com/a/50835467/945906
        guard var i = indexes.first, i < count else { return [] }
        var j = index(after: i)
        var k = indexes.integerGreaterThan(i) ?? endIndex
        while j != endIndex {
            if k != j {
                swapAt(i, j); formIndex(after: &i)
            } else {
                k = indexes.integerGreaterThan(k) ?? endIndex
            }
            formIndex(after: &j)
        }
        let ret = self[i...]
        removeSubrange(i...)
        return Array(ret)
    }
}
