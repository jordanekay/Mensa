//
//  MutableSingleSectionDataSource.swift
//  Mensa
//
//  Created by Jordan Kay on 6/5/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public protocol MutableSingleSectionDataSource: MutableDataSource {
    var items: [Item] { get set }
}

// MARK: -
public extension MutableSingleSectionDataSource {
    var header: Header? {
        return nil
    }
    
    func item(at index: Int) -> Item? {
        guard index >= 0, index < items.count else { return nil }
        return items[index]
    }
    
    // MARK: DataSource
    var sections: [SectionType] {
        get {
            return [.init(header: header, items: items)]
        }
        set {
            guard let section = newValue.first else { return }
            items = section.items
        }
    }
}

