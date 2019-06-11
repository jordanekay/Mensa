//
//  SingleSectionDataSource.swift
//  Mensa
//
//  Created by Jordan Kay on 4/10/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public protocol SingleSectionDataSource: DataSource {
    var items: [Item] { get }
    var header: Header? { get }
}

// MARK: -
public extension SingleSectionDataSource {
    var header: Header? {
        return nil
    }
    
    func item(at index: Int) -> Item? {
        guard index >= 0, index < items.count else { return nil }
        return items[index]
    }
    
    // MARK: DataSource
    var sections: [Section<Item, Header>] {
        return [.init(header: header, items: items)]
    }
}
