//
//  DataDisplaying.swift
//  Mensa
//
//  Created by Jordan Kay on 4/10/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

protocol DataDisplaying: UIScrollView {
    var retainedDelegate: UIScrollViewDelegate { get }
    
    func reloadData()
    
    func register(_ hostingViewType: HostingView.Type, reuseIdentifier: String)
}
