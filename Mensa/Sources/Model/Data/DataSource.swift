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
    
    typealias SectionType = Section<Item, Header>
    
    var sections: [SectionType] { get }
}

// MARK: -
extension DataSource {
    func item(at indexPath: IndexPath) -> Item {
        return sections[indexPath.section][indexPath.row]
    }
    
    func header(for section: Int) -> Header? {
        return sections[section].header
    }
}

// MARK: -
extension DataSource where Item: Equatable {
    func indexPath(for item: Item) -> IndexPath? {
        for (sectionIndex, section) in sections.enumerated() {
            for (itemIndex, sectionItem) in section.items.enumerated() {
                if item == sectionItem {
                    return IndexPath(item: itemIndex, section: sectionIndex)
                }
            }
        }
        return nil
    }
}
