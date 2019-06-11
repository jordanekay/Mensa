//
//  DataInterfacing.swift
//  Mensa
//
//  Created by Jordan Kay on 4/10/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public protocol DataInterfacing: UIViewController, UIScrollViewDelegate {
    typealias Item = DataSourceType.Item
    typealias Header = DataSourceType.Header
    
    associatedtype DataSourceType: DataSource
    associatedtype ItemViewController: UIViewController = UIViewController
    associatedtype HeaderViewController: UIViewController = UIViewController
    
    var displayContext: DataDisplayContext { get }
    
    func displayVariant(for item: Item, at position: ItemPosition) -> Variant?
    func displayVariant(for header: Header) -> Variant?
    func prepareAndAddDataView(_ dataView: UIScrollView)
    func supportInterfacingWithData()
    func handleDisplayingItem(_ item: Item, using viewController: ItemViewController)
    func handleDisplayingHeader(_ header: Header, using viewController: HeaderViewController)
    func handle(_ scrollEvent: ScrollEvent, for scrollView: UIScrollView)
}

public extension DataInterfacing {
    var dataSource: DataSourceType? {
        return dataMediator?.dataSource
    }
    
    var scrollView: UIScrollView? {
        return dataView
    }
    
    var selectedItem: Item? {
        return dataMediator?.selectedIndexPath.flatMap { dataSource?.item(at: $0) }
    }
    
    func useData(from dataSource: DataSourceType, reload: Bool = true) {
        if let dataView = dataView {
            dataMediator.dataSource = dataSource
            if reload {
                dataView.reloadData()
            }
        } else {
            setupDataView()
            supportInterfacingWithData()
            
            dataView!.registerIdentifiers(for: displayContext, using: dataMediator)
            dataMediator.dataSource = dataSource
        }
    }
    
    // MARK: DataInterfacing
    func displayVariant(for item: Item, at position: ItemPosition) -> Variant? {
        return nil
    }
    
    func displayVariant(for header: Header) -> Variant? {
        return nil
    }
    
    func prepareAndAddDataView(_ dataView: UIScrollView) {
        dataView.alwaysBounceVertical = true
        view.addSubview(dataView)
    }
    
    func supportInterfacing<Interface: ItemInterfacing>(with itemType: Interface.View.Item.Type, conformedToBy conformingTypes: Any.Type..., using interfaceType: Interface.Type) {
        if conformingTypes.count > 0 {
            conformingTypes.forEach {
                dataMediator.supportInterfacing(with: $0, using: interfaceType)
            }
        } else {
            dataMediator.supportInterfacing(with: itemType, using: interfaceType)
        }
    }
    
    func handleDisplayingItem(_ item: Item, using viewController: ItemViewController) {
        return  
    }
    
    func handleDisplayingHeader(_ header: Header, using viewController: HeaderViewController) {
        return
    }
    
    func handle(_ scrollEvent: ScrollEvent, for scrollView: UIScrollView) {
        return
    }
}

public extension DataInterfacing where Item: Equatable {
    func select(_ item: Item) {
        guard let indexPath = dataSource?.indexPath(for: item) else { return }
        
        dataMediator?.selectedIndexPath = indexPath
    }
    
    func select(_ item: Item, scrollPosition: UICollectionView.ScrollPosition, animated: Bool)  {
        guard let indexPath = dataSource?.indexPath(for: item) else { return }
        
        position(item, at: scrollPosition, animated: animated)
        dataMediator?.selectedIndexPath = indexPath
    }

    func position(_ item: Item, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        guard let indexPath = dataSource?.indexPath(for: item), let collectionView = collectionView else { return }
        
        collectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }
}

public extension DataInterfacing where DataSourceType: MutableDataSource {
    func replace(_ item: Item, with replacementItem: Item) {
        guard let indexPath = dataSource?.indexPath(for: item) else { return }

        dataMediator?.dataSource?.setItem(replacementItem, at: indexPath)
        if let collectionView = collectionView {
            UIView.performWithoutAnimation {
                collectionView.reloadItems(at: [indexPath])
            }
        }
    }
}

private extension DataInterfacing {
    var dataView: DataDisplaying? {
        get {
            return objc_getAssociatedObject(self, &key) as? DataDisplaying
        }
        set {
            objc_setAssociatedObject(self, &key, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var tableView: UITableView? {
        return dataView as? UITableView
    }
    
    var collectionView: UICollectionView? {
        return dataView as? UICollectionView
    }
    
    var dataMediator: DataMediator<Self>! {
        return tableView?.delegate as? DataMediator<Self> ?? collectionView?.delegate as? DataMediator<Self>
    }

    func setupDataView() {
        let dataMediator = DataMediator(dataInterface: self)
        
        switch displayContext {
        case .tableView:
            setupTableView(with: dataMediator)
        case let .collectionView(layout):
            setupCollectionViewWith(dataMediator: dataMediator, layout: layout)
        }
    }
    
    func setupTableView(with dataMediator: DataMediator<Self>) {
        let tableView = HostingTableView(frame: view.bounds, delegate: dataMediator)
        tableView.dataSource = dataMediator
        dataView = tableView
        prepareAndAddDataView(tableView)
    }
    
    func setupCollectionViewWith(dataMediator: DataMediator<Self>, layout: UICollectionViewLayout) {
        let collectionView = HostingCollectionView(frame: view.bounds, layout: layout, delegate: dataMediator)
        collectionView.dataSource = dataMediator
        dataView = collectionView
        prepareAndAddDataView(collectionView)
    }
}

private extension DataDisplaying {
    func registerIdentifiers<T>(for displayContext: DataDisplayContext, using dataMediator: DataMediator<T>) {
        let identifiers = dataMediator.itemTypeVariantIdentifiers
        identifiers.forEach { register($0, for: displayContext) }
    }
    
    func register(_ identifier: ItemTypeVariantIdentifier, for displayContext: DataDisplayContext) {
        let reuseIdentifier = identifier.value
        switch displayContext {
        case .tableView:
            register(HostingTableViewCell.self, reuseIdentifier: reuseIdentifier)
            register(HostingHeaderFooterView.self, reuseIdentifier: reuseIdentifier)
        case .collectionView:
            register(HostingCollectionViewCell.self, reuseIdentifier: reuseIdentifier)
            register(HostingSupplementaryView.self, reuseIdentifier: reuseIdentifier)
        }
    }
}

// MARK: -
private var key: Void?
