//
//  ItemInterfacing.swift
//  Mensa
//
//  Created by Jordan Kay on 4/10/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public protocol ItemInterfacing: UIViewController {
    associatedtype View: ItemDisplaying
    
    func interface(with item: View.Item)
    func set(_ item: View.Item, selected: Bool)
    func select(_ item: View.Item)
    func deselect(_ item: View.Item)
    func shouldSelect(_ item: View.Item) -> Bool
    func prepareToSelect(_ item: View.Item)
}

public extension ItemInterfacing {
    var view: View {
        return view as! View
    }

    func interface(with item: View.Item) {
        view.display(item)
    }
    
    func set(_ item: View.Item, selected: Bool) {
        if selected {
            select(item)
        } else {
            deselect(item)
        }
    }
    
    func select(_ item: View.Item) {
        return
    }
    
    func deselect(_ item: View.Item) {
        return
    }
    
    func shouldSelect(_ item: View.Item) -> Bool {
        return true
    }
    
    func prepareToSelect(_ item: View.Item) {
        return
    }
}

