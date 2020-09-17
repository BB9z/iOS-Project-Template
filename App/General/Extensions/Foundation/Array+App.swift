/*
 应用级别的便捷方法：Array 扩展

 很多方法定义在更底层的 Collections+App.swift 中
 */
extension Array {

    // @MBDependency:2
    /**
     从数组中提取元素，这些元素会从数组中移除并返回

     例
     ```
     var a = [1, 2, 3, 4, 5, 6]
     print(a.extract { $0 < 3 })  // [1, 2]
     print(a)                     // [3, 4, 5, 6]
     ```
     */
    mutating func extract(while predicate: (Element) -> Bool) -> [Element] {
        var elementRemoved = [Element]()
        removeAll { e -> Bool in
            let shouldExtracted = predicate(e)
            if shouldExtracted {
                elementRemoved.append(e)
            }
            return shouldExtracted
        }
        return elementRemoved
    }
}

extension Array where Self.Element: UIView {
    // @MBDependency:3
    /// 改变一组 view 的隐藏
    func views(hidden: Bool, animated: Bool = false) {
        if !animated {
            forEach { v in
                v.isHidden = hidden
            }
            return
        }
        if !hidden {
            forEach { v in
                v.isHidden = false
            }
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.forEach { v in
                v.alpha = hidden ? 0 : 1
            }
        }, completion: { _ in
            if hidden {
                self.forEach { v in
                    v.isHidden = true
                }
            }
        })
    }

    // @MBDependency:2
    /// 按照 tag 值从小到大重新排序
    /// bug(Xcode 10.2): 用于修正 IBOutletCollection 顺序错乱
    mutating func sortByTag() {
        self = sorted { $0.tag < $1.tag }
    }
}
