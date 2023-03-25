/*
 Helper.swift
 B9Foundation

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import XCTest

extension XCTestCase {
    /// Load test image in test bundle
    func loadTestImage(named: String, extension: String = "png", directory: String? = nil) -> UIImage {
        guard let url = Bundle.module.url(forResource: named, withExtension: `extension`, subdirectory: directory),
              let image = UIImage(contentsOfFile: url.path) else {
            fatalError("Unable load test image: \(named).")
        }
        return image
    }
}
