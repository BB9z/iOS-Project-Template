/*
 GError.swift
 BuildSystem

 Copyright © 2022 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import Foundation

enum GError: LocalizedError {

    case message(_ message: String)

    var errorDescription: String? {
        switch self {
        case let .message(text):
            return text
        }
    }
}
