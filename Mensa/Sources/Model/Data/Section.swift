//
//  Section.swift
//  Mensa
//
//  Created by Jordan Kay on 4/10/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public struct Section<Item, Header> {
    let header: Header?
    var items: [Item]
    
    public init(header: Header? = nil, items: [Item]) {
        self.items = items
        self.header = header
    }
}

// MARK: -
extension Section {
    var itemCount: Int {
        return items.count
    }
    
    subscript(index: Int) -> Item {
        get {
            return items[index]
        }
        set {
            items[index] = newValue
        }
    }
}

// MARK: -
extension Section: ExpressibleByArrayLiteral {
    public init(arrayLiteral items: Item...) {
        self.init(items: items)
    }
}
