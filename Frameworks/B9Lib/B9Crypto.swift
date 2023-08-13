/*
 B9Crypto

 Copyright © 2021 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import CryptoKit

enum B9Crypto {

    /**
     Returns a MD5 hash result of the given UTF-8 string.

     ```
     B9Crypto.md5(utf8: "example")  // Optional("1a79a4d60de6718e8e5b326e338ae533")
     ```
     */
    static func md5(utf8 string: String) -> String? {
        var hasher = Insecure.MD5()
        return hasher.hash(utf8: string)
    }

    /**
     Returns a SHA-1 hash result of the given UTF-8 string.

     ```
     B9Crypto.sha1(utf8: "example")  // Optional("c3499c2729730a7f807efb8676a92dcb6f8a3f8f")
     ```
     */
    static func sha1(utf8 string: String) -> String? {
        var hasher = Insecure.SHA1()
        return hasher.hash(utf8: string)
    }

    /**
     Returns a SHA-256 hash result of the given UTF-8 string.

     ```
     B9Crypto.sha256(utf8: "example")  // Optional("50d858e0985ecc7f60418aaf0cc5ab587f42c2570a884095a9e8ccacd0f6545c")
     ```
     */
    static func sha256(utf8 string: String) -> String? {
        var hasher = SHA256()
        return hasher.hash(utf8: string)
    }
}

extension HashFunction {
    mutating func hash(utf8 string: String) -> String? {
        guard let input = string.data(using: .utf8) else {
            return nil
        }
        update(data: input)
        return finalize().toString()
    }
}

extension Digest where Self.Element == UInt8 {
    func toString() -> String {
        map { String(format: "%02x", $0) }.joined()
    }
}

