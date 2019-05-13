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
    init<Interface: ItemInterfacing, DataInterface: DataInterfacing>(interfaceType: Interface.Type, displayVariant: Interface.View.DisplayVariant, dataInterface: DataInterface) {
        self.displayVariant = displayVariant
        interface = {
            let viewController = $0 as! Interface
            let item = $1 as! Interface.View.Item
            viewController.interface(with: item)
            
            if let item = item as? DataInterface.Item, let view = viewController.view as? DataInterface.ItemViewType {
                dataInterface.handleDisplay(of: item, using: view)
            } else if let header = item as? DataInterface.Header, let view = viewController.view as? DataInterface.HeaderViewType {
                dataInterface.handleDisplay(of: header, using: view)
            }
        }
        variableSize = {
            let viewController = $0 as! Interface
            return viewController.viewHasVariableSize
        }
    }
}
