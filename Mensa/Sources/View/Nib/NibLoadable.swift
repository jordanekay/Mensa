//
//  NibLoadable.swift
//  Mensa
//
//  Created by Jordan Kay on 4/3/19.
//  Copyright © 2019 Jordan Kay. All rights reserved.
//

public protocol NibLoadable: UIView {
    func setupOutletContent()
}

public extension NibLoadable {
    func setupOutletContent() {
        return
    }
    
    static var hostedView: UIView? {
        let hostedView = nibLoadedView
        hostedView?.setupOutletContent()
        hostedView?.translatesAutoresizingMaskIntoConstraints = false
        return hostedView
    }
}

extension NibLoadable {
    static var nibLoadedView: NibLoadable? {
        let resource = String(describing: self)
        let bundle = Bundle(for: self)
        let path = bundle.path(forResource: resource, ofType: "nib")
        let nib = path.map { _ in UINib(nibName: resource, bundle: bundle) }
        let topLevelObjects = nib?.instantiate(withOwner: nil, options: nil)
        return topLevelObjects?.lazy.compactMap { $0 as? Self }.first
    }
    
    func setupContent(from view: UIView, displayedInInterfaceBuilder: Bool) {
        if !displayedInInterfaceBuilder {
            setupOutletContent()
        }
        
        if let inspectable = self as? NibInspectable {
            if !displayedInInterfaceBuilder {
                inspectable.setupInspectableContent()
            }
            inspectable.setInspectableProperties(from: view)
        }
    }
}
