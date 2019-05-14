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
    func select(_ item: View.Item)
    func shouldSelect(_ item: View.Item) -> Bool
}

public extension ItemInterfacing {
    var view: View {
        return view as! View
    }

    func interface(with item: View.Item) {
        view.display(item)
    }
    
    func select(_ item: View.Item) {
        return
    }
    
    func shouldSelect(_ item: View.Item) -> Bool {
        return true
    }
}

extension ItemInterfacing {
    var viewHasVariableSize: Bool {
        return View.hasVariableSize
    }
}
