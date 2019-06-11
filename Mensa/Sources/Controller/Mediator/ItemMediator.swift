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
    let setSelected: (UIViewController, Any, Bool) -> Void
    let shouldSelect: (UIViewController, Any) -> Bool
    let prepareToSelect: (UIViewController, Any) -> Void
    let highlight: (UIViewController, Bool, Bool) -> Void
}

// MARK: -
extension ItemMediator {
    init<Interface: ItemInterfacing, DataInterface: DataInterfacing>(interfaceType: Interface.Type, displayVariant: Interface.View.DisplayVariant, dataInterface: DataInterface) {
        self.displayVariant = displayVariant
        interface = { [weak dataInterface] in
            guard let dataInterface = dataInterface else { return }
            
            let viewController = $0 as! Interface
            let item = $1 as! Interface.View.Item
            viewController.interface(with: item)
            
            if let item = item as? DataInterface.Item, let viewController = viewController as? DataInterface.ItemViewController {
                dataInterface.handleDisplayingItem(item, using: viewController)
            } else if let header = item as? DataInterface.Header, let viewController = viewController as? DataInterface.HeaderViewController {
                dataInterface.handleDisplayingHeader(header, using: viewController)
            }
        }
        setSelected = {
            let viewController = $0 as! Interface
            let item = $1 as! Interface.View.Item
            let selected = $2
            viewController.set(item, selected: selected)
        }
        shouldSelect = {
            let viewController = $0 as! Interface
            let item = $1 as! Interface.View.Item
            return viewController.shouldSelect(item)
        }
        prepareToSelect = {
            let viewController = $0 as! Interface
            let item = $1 as! Interface.View.Item
            viewController.prepareToSelect(item)
        }
        highlight = {
            let viewController = $0 as! Interface
            let view: Interface.View = viewController.view
            view.setHighlighted($1, animated: $2)
        }
    }
}
