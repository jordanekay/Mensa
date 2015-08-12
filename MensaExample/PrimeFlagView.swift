//
//  PrimeFlagView.swift
//  Mensa
//
//  Created by Jordan Kay on 8/11/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import Mensa
import UIKit.UIView

class PrimeFlagView: UIView, HostedView {
    @IBOutlet private(set) weak var textLabel: UILabel?
    private(set) var formatString: String!
    
    override func awakeFromNib() {
        formatString = textLabel?.text
    }
}
