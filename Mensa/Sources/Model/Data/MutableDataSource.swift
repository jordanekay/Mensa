//
//  MutableDataSource.swift
//  Mensa
//
//  Created by Jordan Kay on 6/5/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public protocol MutableDataSource: DataSource where Item: Equatable {
    var sections: [SectionType] { get set }
}

// MARK: -
extension MutableDataSource {
    mutating func setItem(_ item: Item, at indexPath: IndexPath) {
        sections[indexPath.section][indexPath.row] = item
    }
}
