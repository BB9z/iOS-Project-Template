/*
 应用级别的便捷方法：几何相关扩展
 */

extension CGRect {
    /// 矩形中心点
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}
