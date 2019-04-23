//
//  DataSource.swift
//  Mensa
//
//  Created by Jordan Kay on 4/3/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public protocol DataSource {
    associatedtype Item
    associatedtype Header
    
    var sections: [Section<Item, Header>] { get }
}

// MARK: -
extension DataSource {
    func item(at indexPath: SectionIndexPath) -> Item {
        return sections[indexPath.section][indexPath.row]
    }
}
