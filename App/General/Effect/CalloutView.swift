/**
 带箭头的面板 view
 */
class CalloutView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        layer.masksToBounds = false
    }

    /// 箭头方向，0 向上，1 向下
    @IBInspectable var arrowDirection: Int = 0 {
        didSet {
            updatePanelLayer()
        }
    }
    var arrowSize = CGSize(width: 14, height: 8) {
        didSet {
            updatePanelLayer()
        }
    }
    var contentInset = UIEdgeInsets.zero {
        didSet {
            updatePanelLayer()
        }
    }
    @IBInspectable var color: UIColor = .white {
        didSet {
            updatePanelLayer()
        }
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        updatePanelLayer()
    }

    private func updatePanelLayer() {
        updatePanelStyle(layer: panelLayer)
    }

    private func updatePanelStyle(layer: CAShapeLayer) {
        let path = UIBezierPath()
        let frame = bounds.inset(by: contentInset)
        switch arrowDirection {
        case 1:
            makeDownArrow(path: path, frame: frame)
        default:
            makeUpArrow(path: path, frame: frame)
        }
        layer.path = path.cgPath
        layer.shadowPath = path.cgPath
        layer.shadowColor = UIColor(named: "Color/shadow")!.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 12
        layer.shadowOpacity = 1
        layer.masksToBounds = false
        layer.fillColor = color.cgColor
    }

    lazy var panelLayer: CAShapeLayer = {
        let aLayer = CAShapeLayer()
        layer.insertSublayer(aLayer, at: 0)
        return aLayer
    }()

    private func makeDownArrow(path: UIBezierPath, frame: CGRect) {
        let arW = arrowSize.width
        let arH = arrowSize.height
        let minX = frame.minX
        let minY = frame.minY
        let maxX = frame.maxX
        let maxY = frame.maxY
        let midX = frame.midX
        let bottomY = frame.maxY + arH
        let cRd = cornerRadius
        let cSp = cornerRadius * 0.4475

        //            。       |        。
        //                。   |   。
        //                   。 。
        path.move(    x: midX + arW * 1.00, y: maxY)    // 右中，底
        path.addCurve(c1x: midX + arW * 0.78, c1y: maxY,
                      c2x: midX + arW * 0.50, c2y: bottomY - arH * 0.87,
                      x: midX + arW * 0.36, y: bottomY - arH * 0.65)    // 右中中
        path.addLine( x: midX + arW * 0.14, y: bottomY - arH * 0.09)    // 中右
        path.addCurve(c1x: midX + arW * 0.07, c1y: bottomY,
                      c2x: midX - arW * 0.07, c2y: bottomY,
                      x: midX - arW * 0.14, y: bottomY - arH * 0.09)    // 中左
        path.addLine( x: midX - arW * 0.36, y: bottomY - arH * 0.65)    // 左中中
        path.addCurve(c1x: midX - arW * 0.50, c1y: bottomY - arH * 0.87,
                      c2x: midX - arW * 0.78, c2y: maxY,
                      x: midX - arW * 1.00, y: maxY)  // 左中，底
        path.addLine( x: minX + cRd, y: maxY)       // 左下，底部
        path.addCurve(c1x: minX + cSp, c1y: maxY,
                      c2x: minX, c2y: maxY - cSp,
                      x: minX, y: maxY - cRd)    // 左下，左侧
        path.addLine( x: minX, y: minY + cRd)       // 左上，左侧
        path.addCurve(c1x: minX, c1y: minY + cSp,
                      c2x: minX + cSp, c2y: minY,
                      x: minX + cRd, y: minY)       // 左上，顶部
        path.addLine( x: maxX - cRd, y: minY)       // 右上，顶部
        path.addCurve(c1x: maxX - cSp, c1y: minY,
                      c2x: maxX, c2y: minY + cSp,
                      x: maxX, y: minY + cRd)       // 右上，右侧
        path.addLine( x: maxX, y: maxY - cRd)    // 右下，右侧
        path.addCurve(c1x: maxX, c1y: maxY - cSp,
                      c2x: maxX - cSp, c2y: maxY,
                      x: maxX - cRd, y: maxY)    // 右下，底部
        path.addLine( x: midX + arW, y: maxY)
        path.close()
    }

    private func makeUpArrow(path: UIBezierPath, frame: CGRect) {
        let arW = arrowSize.width
        let arH = arrowSize.height
        let minX = frame.minX
        let minY = frame.minY
        let maxX = frame.maxX
        let maxY = frame.maxY
        let midX = frame.midX
        let topY = frame.minY - arH
        let cRd = cornerRadius
        let cSp = cornerRadius * 0.4475

        //                   。 。
        //                。   |   。
        //            。       |        。
        path.move(    x: midX + arW * 1.00, y: minY)    // 右中，底
        path.addCurve(c1x: midX + arW * 0.78, c1y: minY,
                      c2x: midX + arW * 0.50, c2y: topY + arH * 0.87,
                      x: midX + arW * 0.36, y: topY + arH * 0.65)    // 右中中
        path.addLine( x: midX + arW * 0.14, y: topY + arH * 0.09)    // 中右
        path.addCurve(c1x: midX + arW * 0.07, c1y: topY,
                      c2x: midX - arW * 0.07, c2y: topY,
                      x: midX - arW * 0.14, y: topY + arH * 0.09)    // 中左
        path.addLine( x: midX - arW * 0.36, y: topY + arH * 0.65)    // 左中中
        path.addCurve(c1x: midX - arW * 0.50, c1y: topY + arH * 0.87,
                      c2x: midX - arW * 0.78, c2y: minY,
                      x: midX - arW * 1.00, y: minY)    // 左中，底
        path.addLine( x: minX + cRd, y: minY)         // 左上，顶部
        path.addCurve(c1x: minX + cSp, c1y: minY,
                      c2x: minX, c2y: minY + cSp,
                      x: minX, y: minY + cRd)   // 左上，左侧
        path.addLine( x: minX, y: maxY - cRd)   // 左下，左侧
        path.addCurve(c1x: minX, c1y: maxY - cSp,
                      c2x: minX + cSp, c2y: maxY,
                      x: minX + cRd, y: maxY)         // 左下，底部
        path.addLine( x: maxX - cRd, y: maxY)         // 右下，底部
        path.addCurve(c1x: maxX - cSp, c1y: maxY,
                      c2x: maxX, c2y: maxY - cSp,
                      x: maxX, y: maxY - cRd)   // 右下，右侧
        path.addLine( x: maxX, y: minY + cRd)   // 右上，右侧
        path.addCurve(c1x: maxX, c1y: minY + cSp,
                      c2x: maxX - cSp, c2y: minY,
                      x: maxX - cRd, y: minY)         // 右上，顶部
        path.addLine( x: midX + arW, y: minY)
        path.close()
    }
}

private extension UIBezierPath {
    func move(x: CGFloat, y: CGFloat) {
        move(to: CGPoint(x: x, y: y))
    }
    func addLine(x: CGFloat, y: CGFloat) {
        addLine(to: CGPoint(x: x, y: y))
    }
    // swiftlint:disable:next function_parameter_count
    func addCurve(c1x: CGFloat, c1y: CGFloat, c2x: CGFloat, c2y: CGFloat, x: CGFloat, y: CGFloat) {
        addCurve(to: CGPoint(x: x, y: y), controlPoint1: CGPoint(x: c1x, y: c1y), controlPoint2: CGPoint(x: c2x, y: c2y))
    }
}

#if PREVIEW
import SwiftUI
struct CalloutPreview: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let view = CalloutView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
            return view
        }
    }
}
#endif
