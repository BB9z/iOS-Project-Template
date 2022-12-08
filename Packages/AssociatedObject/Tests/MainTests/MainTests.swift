import XCTest
@testable import B9AssociatedObject

enum EnumType: Equatable, CustomDebugStringConvertible {
    case one
    case two

    var debugDescription: String {
        switch self {
        case .one:
            return "<EnumType.one>"
        case .two:
            return "<EnumType.two>"
        }
    }
}

let enumAssociation = AssociatedObject<EnumType>()

class A {}

extension A {
    var enumValue: EnumType? {
        get { enumAssociation[self] }
        set { enumAssociation[self] = newValue }
    }
}

final class AssociatedObjectTests: XCTestCase {
    func testSwiftEnum() {
        let a1 = A()
        let a2 = A()
        assert(a1.enumValue == nil)
        a1.enumValue = .one
        a2.enumValue = .two
        debugPrint(a1.enumValue as Any, a2.enumValue as Any)
        assert(a1.enumValue == .one)
        assert(a2.enumValue == .two)
        assert(a1.enumValue != a2.enumValue)
        a1.enumValue = .two
        assert(a1.enumValue == .two)
        assert(a1.enumValue == a2.enumValue)
    }
}
