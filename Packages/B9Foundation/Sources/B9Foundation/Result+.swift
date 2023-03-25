/*
 Result+
 B9Foundation

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import Foundation

public extension Result {
    /// Is success or not?
    var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }

    /// Conveniently return the error object, or nil if the result is success.
    var error: Error? {
        if case .failure(let failure) = self {
            return failure
        }
        return nil
    }
}
