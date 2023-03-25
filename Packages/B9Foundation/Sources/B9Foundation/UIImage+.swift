/*
 UIImage+
 B9Foundation

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import UIKit

public extension UIImage {
    /// Creates a new UIImage with the specified color and size.
    ///
    /// - Parameters:
    ///   - color: The color to fill the UIImage with.
    ///   - size: The size of the UIImage to create. The dimensions must be greater than zero.
    ///   - scale: The scale factor of the UIImage. Default is 0, which means use the device's main screen scale.
    /// - Returns: A UIImage with the specified color and size.
    static func newImage(color: UIColor, size: CGSize, scale: CGFloat = 0) -> UIImage {
        assert(size.width > 0 && size.height > 0,
               "The size dimensions must be greater than zero.")
        let format = UIGraphicsImageRendererFormat.default()
        if scale > 0 {
            format.scale = scale
        }
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let image = renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        return image
    }

    /// Compare the content of the receiver image with another image.
    ///
    /// This method only compares the size of the image and the color value of each pixel point.
    /// Other things such as orientation, scale factor, and layout properties are not considered.
    ///
    /// Images created by CIImage are not supported.
    ///
    /// This method is intended for test purposes and will return false in case of exceptions instead of throwing an exception.
    ///
    /// - Parameter another: The image to compare.
    /// - Returns: A boolean value indicating whether the images are exactly the same in size and content.
    func isContentMatch(another: UIImage?) -> Bool {
        guard let cgImage1 = self.cgImage, let cgImage2 = another?.cgImage else {
            return false
        }
        let width = cgImage1.width
        let height = cgImage1.height
        guard width > 0, height > 0, width == cgImage2.width, height == cgImage2.height else {
            return false
        }
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let pixelCount = width * height

        guard let bitmapData1 = calloc(pixelCount, bytesPerPixel),
              let bitmapData2 = calloc(pixelCount, bytesPerPixel) else {
            return false
        }
        defer {
            free(bitmapData1)
            free(bitmapData2)
        }

        func makeContext(_ data: UnsafeMutableRawPointer?) -> CGContext? {
            CGContext(
                data: data,
                width: width,
                height: height,
                bitsPerComponent: bitsPerComponent,
                bytesPerRow: bytesPerRow,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        }
        guard let context1 = makeContext(bitmapData1),
              let context2 = makeContext(bitmapData2) else {
            return false
        }

        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context1.draw(cgImage1, in: rect)
        context2.draw(cgImage2, in: rect)

        for i in 0..<pixelCount {
            let address = i * bytesPerPixel
            let pixel1 = bitmapData1.load(fromByteOffset: address, as: UInt32.self)
            let pixel2 = bitmapData2.load(fromByteOffset: address, as: UInt32.self)
            if pixel1 != pixel2 {
                return false
            }
        }
        return true
    }
}
