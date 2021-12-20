/*
 应用级别的便捷方法：几何相关扩展
 */

extension CGRect {
    /// 矩形中心点
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}

extension UIEdgeInsets {
    /// 使用各个方向相同的边距创建
    /// - Parameter edge: 边距大小
    init(edge: CGFloat) {
        self.init(top: edge, left: edge, bottom: edge, right: edge)
    }
}
