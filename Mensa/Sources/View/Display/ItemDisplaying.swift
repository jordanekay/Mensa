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
    
    func setHighlighted(_ highlighted: Bool, animated: Bool)
}

// MARK: -
public extension ItemDisplaying {
    func setHighlighted(_ highlighted: Bool, animated: Bool) {
        return
    }
}

// MARK: -
public extension ItemDisplaying where DisplayVariant == Invariant {
    static var defaultVariant: Invariant {
        return .init()
    }
    
    static var itemDisplayVariants: [Invariant] {
        return [.init()]
    }
}

public extension ItemDisplaying where DisplayVariant: CaseIterable, DisplayVariant.AllCases == [DisplayVariant] {
    static var itemDisplayVariants: [DisplayVariant] {
        return DisplayVariant.allCases
    }
}

// MARK: -
extension ItemPosition: Variant {}
