//
//  Inspectable.swift
//  Mensa
//
//  Created by Jordan Kay on 4/8/19.
//  Copyright © 2019 Jordan Kay. All rights reserved.
//

public protocol NibInspectable: NibLoadable {
    static var inspectableBindings: [String: String] { get }
    
    func setupInspectableContent()
}

public extension NibInspectable {
    func setupInspectableContent() {
        return
    }
    
    func updateInspectableContent() {
        Self.inspectableBindings.forEach {
            if let value = value(forKey: $1) {
                setValue(value, forKeyPath: $0)
            }
        }
    }
}

extension NibInspectable {
    func setInspectableProperties(from view: UIView) {
        Self.inspectableBindings.values.forEach {
            if let value = view.value(forKey: $0) {
                setValue(value, forKey: $0)
            }
        }
        updateInspectableContent()
    }
}
