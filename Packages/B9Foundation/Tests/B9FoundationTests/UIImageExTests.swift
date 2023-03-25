/*
 UIImageExTests.swift
 B9Foundation

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import B9Foundation
import XCTest

// swiftlint:disable force_unwrapping

class UIImageExTests: XCTestCase {
    lazy var imageSolid12345 = loadTestImage(named: "image_solid_123456")
    lazy var imageSolid12345Diff = loadTestImage(named: "image_solid_123456_diff")

    func testNewImageColorSize() {
        let image = UIImage.newImage(color: .clear, size: CGSize(width: 100, height: 100))
        XCTAssertNotNil(image.cgImage)
        XCTAssertEqual(image.scale, UIScreen.main.scale)
    }

    func testNewImageColorSizeMatch() {
        let color = UIColor(
            red: CGFloat(0x12) / 255,
            green: CGFloat(0x34) / 255,
            blue: CGFloat(0x56) / 255,
            alpha: 1)
        let image = UIImage.newImage(color: color, size: CGSize(width: 10, height: 10), scale: 1)
        XCTAssertTrue(image.isContentMatch(another: imageSolid12345))
    }

    func testContentMatchBadCase() {
        // Nil parameter
        XCTAssertFalse(UIImage().isContentMatch(another: nil))

        // Empty image
        XCTAssertFalse(imageSolid12345.isContentMatch(another: UIImage()))
        XCTAssertFalse(UIImage().isContentMatch(another: UIImage()))
        XCTAssertFalse(UIImage().isContentMatch(another: imageSolid12345))

        // Diff size
        let imageSize = loadTestImage(named: "image_diff_size")
        XCTAssertFalse(imageSolid12345.isContentMatch(another: imageSize))
    }

    func testContentMatch() {
        XCTAssertFalse(imageSolid12345.isContentMatch(another: imageSolid12345Diff))

        let imageCopy = loadTestImage(named: "image_solid_123456")
        XCTAssertTrue(imageSolid12345.isContentMatch(another: imageCopy))

        let rectImage = loadTestImage(named: "image_diff_size")
        let orientated = UIImage(cgImage: rectImage.cgImage!, scale: 10, orientation: .right)
        XCTAssertTrue(orientated.isContentMatch(another: rectImage))
    }
}
