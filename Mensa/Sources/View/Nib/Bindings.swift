//
//  Bindings.swift
//  Mensa
//
//  Created by Jordan Kay on 4/8/19.
//  Copyright © 2019 Jordan Kay. All rights reserved.
//

@objc public extension UIButton {
    var titleText: String? {
        get {
            return title(for: .normal)
        }
        set {
            setTitle(newValue, for: .normal)
        }
    }
}

public extension Dictionary where Key == String, Value == String {
    init<T, U, V>(keyPaths: [KeyPath<T, U>: KeyPath<T, V>]) {
        self.init(uniqueKeysWithValues: keyPaths.map { ($0.name, $1.name) })
    }
}

private extension KeyPath {
    var name: String {
        return NSExpression(forKeyPath: self).keyPath
    }
}
