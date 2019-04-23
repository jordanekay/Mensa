//
//  ItemDisplaying.swift
//  Mensa
//
//  Created by Jordan Kay on 4/10/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public protocol ItemDisplaying: CustomDisplaying {
    typealias Item = Model
    
    static var itemDisplayVariants: [DisplayVariant] { get }
    static var hasVariableSize: Bool { get }
}

public extension ItemDisplaying {
    static var hasVariableSize: Bool {
        return false
    }
    
    func display(_ item: Item) {
        display(item, with: Self.defaultVariant)
    }
}

public extension ItemDisplaying where DisplayVariant: CaseIterable, DisplayVariant.AllCases == [DisplayVariant] {
    static var itemDisplayVariants: [DisplayVariant] {
        return DisplayVariant.allCases
    }
}

public extension ItemDisplaying where DisplayVariant == Invariant {
    static var defaultVariant: Invariant {
        return .init()
    }
    
    static var itemDisplayVariants: [Invariant] {
        return [.init()]
    }
}
