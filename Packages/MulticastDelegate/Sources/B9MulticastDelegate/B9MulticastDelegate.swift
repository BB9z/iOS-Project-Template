/*
 MulticastDelegate
 B9Swift

 Copyright © 2019-2021 BB9z
 https://github.com/B9Swift/MulticastDelegate

 The MIT License (MIT)
 http://www.opensource.org/licenses/mit-license.php
 */

import Foundation

/// Multicast delegate is a delegate that can have more than one element in its invocation list.
///
/// This class is thread safe.
public final class MulticastDelegate<Element> {
    
    public init() {
    }

    private var store = [Weak]()
    private let lock = NSLock()

    /// Add an object to the multicast delegate.
    ///
    /// If the given parameter has been added to the multicast delegate or a non-object,
    /// it takes no effect.
    ///
    /// - Parameter delegate: An optional object to add.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the internal storage.
    public func add(_ delegate: Element?) {
        guard let d = delegate else { return }
        let weakRef = Weak(object: d as AnyObject)
        guard let dobj = weakRef.object else {
            print("[B9MulticastDelegate] warning: \(d) is not an object, it will be ignored. Adding a non-object as delegate is meaningless.")
            return
        }
        lock.lock()
        defer { lock.unlock() }
        if store.contains(where: { $0.object === dobj }) {
            return
        }
        store.append(weakRef)
        underestimatedCount += 1
    }

    /// Remove an object from the multicast delegate.
    ///
    /// - Parameter delegate: An optional object to remove. Its tasks no action if `nil`.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the internal storage.
    public func remove(_ delegate: Element?) {
        guard let d = delegate else { return }
        lock.lock()
        store.removeAll { $0.object === d as AnyObject || $0.object == nil }
        underestimatedCount = store.count
        lock.unlock()
    }

    /// Calls the given closure on each object in the multicast delegate.
    ///
    /// The calling order is in [FIFO]( https://en.wikipedia.org/wiki/LIFO_(computing) ).
    ///
    /// - Parameter invocation: A closure that takes an object in the multicast delegate as a parameter.
    public func invoke(_ invocation: (Element) throws -> ()) rethrows {
        lock.lock()
        let shadowStore = store
        lock.unlock()
        for ref in shadowStore {
            if let d = ref.element {
                try invocation(d)
            }
        }
    }

    /// Returns a Boolean value indicating whether an given object has been added to the multicast delegate.
    ///
    /// This method uses `===` to check if two objects are equal, which means it checks if any objects have the same identity, not the same value.
    ///
    /// - Parameter object: The object to find in the multicast delegate.
    /// - Returns: `true` if the object was found in the multicast delegate;
    ///     otherwise, `false`.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the internal storage.
    public func contains(object: AnyObject) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        for weakRef in store {
            if weakRef.object === object {
                return true
            }
        }
        return false
    }

    private struct Weak {
        weak var object: AnyObject?
        var element: Element? {
            return object as! Element?
        }
    }

    // For Sequence, it improves performance.
    /// - See Also: protocol Sequence -> underestimatedCount
    public private(set) var underestimatedCount: Int = 0
}

// Make MulticastDelegate a Sequence gives us lots of sequence features for free.
extension MulticastDelegate: Sequence {
    public func makeIterator() -> AnyIterator<Element> {
        var iterator = store.makeIterator()

        return AnyIterator {
            while let next = iterator.next() {
                if let delegate = next.element {
                    return delegate
                }
            }
            return nil
        }
    }
}

extension MulticastDelegate: CustomStringConvertible {
    public var description: String {
        let aType = type(of: self)
        let address = Unmanaged.passUnretained(self).toOpaque()
        let itemsDescriptions = map { "\t\($0)" }
        if itemsDescriptions.isEmpty {
            return "<\(aType) \(address): elements: []>"
        }
        return """
        <\(aType) \(address): elements: [
        \(itemsDescriptions.joined(separator: ",\n"))
        ]>
        """
    }
}
