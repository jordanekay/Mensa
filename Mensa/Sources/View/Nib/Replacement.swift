//
//  Replacement.swift
//  Mensa
//
//  Created by Jordan Kay on 4/3/19.
//  Copyright © 2019 Jordan Kay. All rights reserved.
//

extension UIView {
    // MARK: NSObject
    override open func awakeAfter(using coder: NSCoder) -> Any? {
        // For display in app, return the replacement view instead if it exists
        return replacementView(displayedInInterfaceBuilder: false) ?? super.awakeAfter(using: coder)
    }
    
    override open func prepareForInterfaceBuilder() {
        // For display in Interface Builder using IBDesignable, remove this view and add the replacement view instead
        guard let replacementView = replacementView(displayedInInterfaceBuilder: true) else { return }
        replacementView.frame = bounds
        addSubview(replacementView)
    }
}

// MARK: -
private extension UIView {
    func replacementView(displayedInInterfaceBuilder: Bool) -> UIView? {
        // This view only needs to be replaced if it is nib-loadable and has no content yet
        guard let nibLoadableType = type(of: self) as? NibLoadable.Type, subviews.count == 0 else { return nil }
        
        let view = nibLoadableType.nibLoadedView
        view?.setupContent(from: self, displayedInInterfaceBuilder: displayedInInterfaceBuilder)
        // Interface Builder display requires translated constraints from autoresizing mask
        view?.translatesAutoresizingMaskIntoConstraints = displayedInInterfaceBuilder
        return view
    }
}
