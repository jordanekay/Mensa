//
//  HostingCollectionView.swift
//  Mensa
//
//  Created by Jordan Kay on 5/7/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

final class HostingCollectionView: UICollectionView {
    let retainedDelegate: UIScrollViewDelegate
    
    init(frame: CGRect, layout: UICollectionViewLayout, delegate: UICollectionViewDelegate) {
        retainedDelegate = delegate
        super.init(frame: frame, collectionViewLayout: layout)
        self.delegate = delegate
        
        backgroundColor = .clear
        isPrefetchingEnabled = false
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

// MARK: -
extension HostingCollectionView: DataDisplaying {
    // MARK: DataDisplaying
    func register(_ hostingViewType: HostingView.Type, reuseIdentifier: String) {
        register(hostingViewType, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    func register(_ headerFooterViewType: HostingHeaderFooterView.Type, reuseIdentifier: String) {
        return
    }
    
    func register(_ supplementaryViewType: HostingSupplementaryView.Type, reuseIdentifier: String) {
        register(supplementaryViewType, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: reuseIdentifier)
    }
}
