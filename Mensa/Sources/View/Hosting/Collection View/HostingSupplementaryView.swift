//
//  SupplementaryView.swift
//  Mensa
//
//  Created by Jordan Kay on 5/10/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

class HostingSupplementaryView: UICollectionReusableView {
    weak var viewController: UIViewController!
}

// MARK: -
extension HostingSupplementaryView: HostingView {
    var contentView: UIView {
        return self
    }
    
    func addSizeConstraints(toHostedView hostedView: UIView) {
        return
    }
}
