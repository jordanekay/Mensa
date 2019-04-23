//
//  HostingCollectionViewCell.swift
//  Mensan
//
//  Created by Jordan Kay on 5/7/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

final class HostingCollectionViewCell: UICollectionViewCell {
    weak var viewController: UIViewController!
}

// MARK: -
extension HostingCollectionViewCell: HostingView {
    func addSizeConstraints(toHostedView hostedView: UIView) {
        let widthConstraint = NSLayoutConstraint(item: hostedView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: hostedView.bounds.width)
        let heightConstraint = NSLayoutConstraint(item: hostedView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: hostedView.bounds.height)
        let constraints = [widthConstraint, heightConstraint]
        hostedView.addConstraints(constraints)
    }
}
