//
//  HostingTableViewCell.swift
//  Mensa
//
//  Created by Jordan Kay on 4/10/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

final class HostingTableViewCell: UITableViewCell {
    weak var viewController: UIViewController!
}

// MARK: -
extension HostingTableViewCell: HostingView {
    func addSizeConstraints(toHostedView hostedView: UIView) {
        let heightConstraint = NSLayoutConstraint(item: hostedView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: hostedView.bounds.height)
        hostedView.addConstraint(heightConstraint)
    }
}
