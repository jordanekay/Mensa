//
//  ItemTypeVariantIdentifier.swift
//  Mensa
//
//  Created by Jordan Kay on 4/22/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

struct ItemTypeVariantIdentifier {
    let value: String
    
    init(itemTypeIdentifier: ItemTypeIdentifier, variant: Variant) {
        value = itemTypeIdentifier.value + variant.name
    }
}

extension ItemTypeVariantIdentifier: Identifier {}
