//
//  ItemInterfacing.swift
//  Mensa
//
//  Created by Jordan Kay on 4/10/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public protocol ItemInterfacing: UIViewController {
    associatedtype View: ItemDisplaying
    
    func interface(with item: View.Item, displayedWith variant: View.DisplayVariant)
}

public extension ItemInterfacing {
    var view: View {
        return view as! View
    }

    func interface(with item: View.Item, displayedWith variant: View.DisplayVariant) {
        view.display(item, with: variant)
    }
}

extension ItemInterfacing {
    var viewHasVariableSize: Bool {
        return View.hasVariableSize
    }
}
