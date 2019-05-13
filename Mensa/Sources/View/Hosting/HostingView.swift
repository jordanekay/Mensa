//
//  Hosting.swift
//  Mensa
//
//  Created by Jordan Kay on 4/10/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

protocol HostingView: UIView {
    var contentView: UIView { get }
    var viewController: UIViewController! { get set }
    
    func addSizeConstraints(toHostedView hostedView: UIView)
}

// MARK: -
extension HostingView {
    func hostContent(of type: NibLoadable.Type, from viewController: UIViewController, with variant: Variant, variableSize: Bool) {
        let hostedView = type.hostedView(of: variant)
        hostedView.backgroundColor = .clear
        hostedView.frame.size.width = contentView.bounds.width
        viewController.view = hostedView
        self.viewController = viewController

        contentView.addSubview(hostedView)
        addEdgeConstraints(toHostedView: hostedView)
//        if !variableSize {
//            addSizeConstraints(toHostedView: hostedView)
//        }
    }
}

// MARK: -
private extension HostingView {
    func addEdgeConstraints(toHostedView hostedView: UIView) {
        for attribute: NSLayoutConstraint.Attribute in [.top, .left, .bottom, .right] {
            let constraint = NSLayoutConstraint(item: contentView, attribute: attribute, relatedBy: .equal, toItem: hostedView, attribute: attribute, multiplier: 1, constant: 0)
            if attribute == .bottom {
                constraint.priority -= 1
            }
            contentView.addConstraint(constraint)
        }
    }    
}
