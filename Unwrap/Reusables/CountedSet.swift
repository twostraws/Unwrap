//
//  CountedSet.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// An unordered collection of distinct objects where items may appear more than once. Similar to NSCountedSet, just using Swift and Codable.
struct CountedSet<T: Hashable & Codable>: Codable {
    /// The only thing we need to save is our underlying storage.
    enum CodingKeys: String, CodingKey {
        case storage
    }

    /// The underlying data storage is a dictionary with our type as a key and Int as its value so we can track how often each thing is inserted.
    private var storage = [T: Int]()

    /// The total number of distinct objects in the collection.
    public var count: Int {
        return storage.count
    }

    /// Returns true if this counted set has no objects inside.
    public var isEmpty: Bool {
        return count == 0
    }

    /// Returns the number of times a specific object has been inserted into the set.
    public func count(for object: T) -> Int {
        return storage[object, default: 0]
    }

    /// Returns true if the object is currently inside the counted set.
    public func contains(_ object: T) -> Bool {
        return storage[object] != nil
    }

    /// Adds an object to the counted set.
    public mutating func insert(_ object: T) {
        storage[object, default: 0] += 1
    }

    /// Removes one instance of an object from the counted set.
    public mutating func remove(_ object: T) {
        guard contains(object) else { return }

        let objectCount = count(for: object)

        if objectCount == 1 {
            storage.removeValue(forKey: object)
        } else {
            storage[object] = objectCount - 1
        }
    }
}

/// Make CountedSet conform to Sequence so we can loop over it.
extension CountedSet: Sequence {
    /// For the iterator, just pass back the iterator we get from our underlying storage.
    public func makeIterator() -> DictionaryIterator<T, Int> {
        return storage.makeIterator()
    }
}
