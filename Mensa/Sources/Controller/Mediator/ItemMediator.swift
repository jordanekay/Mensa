//
//  AnyItemInterfacing.swift
//  Mensa
//
//  Created by Jordan Kay on 4/11/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

struct ItemMediator {
    let displayVariant: Variant
    let interface: (UIViewController, Any) -> Void
    let variableSize: (UIViewController) -> Bool
}

// MARK: -
extension ItemMediator {
    init<Interface: ItemInterfacing>(interfaceType: Interface.Type, displayVariant: Interface.View.DisplayVariant) {
        self.displayVariant = displayVariant
        interface = {
            let viewController = $0 as! Interface
            let item = $1 as! Interface.View.Item
            viewController.interface(with: item, displayedWith: displayVariant)
        }
        variableSize = {
            let viewController = $0 as! Interface
            return viewController.viewHasVariableSize
        }
    }
}
