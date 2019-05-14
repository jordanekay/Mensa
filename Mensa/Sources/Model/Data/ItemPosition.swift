//
//  ItemPosition.swift
//  Model
//
//  Created by Jordan Kay on 5/14/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public enum ItemPosition: String {
    case top
    case middle
    case bottom
    case lone
}

// MARK: -
extension ItemPosition {
    init(indexPath: IndexPath, itemCount: Int) {
        switch indexPath.item {
        case 0:
            self = (itemCount == 1) ? .lone : .top
        case itemCount - 1:
            self = .bottom
        default:
            self = .middle
        }
    }
}

// MARK: -
extension ItemPosition: CaseIterable {}
