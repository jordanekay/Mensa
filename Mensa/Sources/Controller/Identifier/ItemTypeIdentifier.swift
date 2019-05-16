//
//  ItemTypeIdentifier.swift
//  Mensa
//
//  Created by Jordan Kay on 4/22/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

struct ItemTypeIdentifier {
    let value: String
    
    init(itemType: Any.Type) {
        value = String(describing: itemType)
    }
}

extension ItemTypeIdentifier: Identifier {}
