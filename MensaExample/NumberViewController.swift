//
//  NumberViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 6/21/16.
//  Copyright © 2016 Jordan Kay. All rights reserved.
//

import Mensa

final class NumberViewController: UIViewController, ItemDisplaying {
    typealias Item = Number
    typealias View = NumberView
    typealias DisplayVariantType = DisplayInvariant
    
    func update(with number: Number, variant: DisplayInvariant, displayed: Bool) {
        view.valueLabel.text = "\(number.value)"
    }

    func selectItem(_ number: Number) {
        var number = number
        let factorsString = number.factors.map { "\($0)" }.joined(separator: ", ")
        let message = "The factors of \(number.value) are \(factorsString)."
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func canRemoveItem(_ item: Number) -> Bool {
        return true
    }
}
