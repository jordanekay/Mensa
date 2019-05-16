//
//  DataInterfacing.swift
//  Mensa
//
//  Created by Jordan Kay on 4/10/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public protocol DataInterfacing: UIViewController {
    typealias Item = DataSourceType.Item
    typealias Header = DataSourceType.Header
    
    associatedtype DataSourceType: DataSource
    associatedtype ItemViewController: ItemInterfacing
    associatedtype HeaderViewController: ItemInterfacing
    
    var displayContext: DataDisplayContext { get }
    
    func displayVariant(for item: Item, at position: ItemPosition) -> Variant?
    func displayVariant(for header: Header) -> Variant?
    func prepareAndAddDataView(_ dataView: UIScrollView)
    func supportInterfacingWithData()
    func handleDisplayingItem(_ item: Item, using viewController: ItemViewController, with view: ItemViewController.View)
    func handleDisplayingHeader(_ header: Header, using viewController: HeaderViewController, with view: HeaderViewController.View)
}

public extension DataInterfacing {
    func useData(from dataSource: DataSourceType) {
        if let dataView = dataView {
            dataMediator.dataSource = dataSource
            dataView.reloadData()
        } else {
            setupDataView()
            supportInterfacingWithData()
            
            dataView!.registerIdentifiers(for: displayContext, using: dataMediator)
            dataMediator.dataSource = dataSource
        }
    }
    
    func displayVariant(for item: Item, at position: ItemPosition) -> Variant? {
        return nil
    }
    
    func displayVariant(for header: Header) -> Variant? {
        return nil
    }
    
    func supportInterfacing<Item, Interface: ItemInterfacing>(with itemType: Item.Type, conformedToBy conformingTypes: Any.Type..., using interfaceType: Interface.Type) where Item == Interface.View.Item {
        if conformingTypes.count > 0 {
            conformingTypes.forEach {
                dataMediator.supportInterfacing(with: $0, using: interfaceType)
            }
        } else {
            dataMediator.supportInterfacing(with: itemType, using: interfaceType)
        }
    }
    
    func handleDisplayingItem(_ item: Item, using viewController: ItemViewController, with view: ItemViewController.View) {
        return  
    }
    
    func handleDisplayingHeader(_ header: Header, using viewController: HeaderViewController, with view: HeaderViewController.View) {
        return
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
    
    var dataMediator: DataMediator<Self>! {
        return (dataView as? UITableView)?.delegate as? DataMediator<Self> ?? (dataView as? UICollectionView)?.delegate as? DataMediator<Self>
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
        collectionView.backgroundColor = .clear
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
