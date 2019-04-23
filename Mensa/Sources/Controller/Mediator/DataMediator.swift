//
//  DataMediator.swift
//  Mensa
//
//  Created by Jordan Kay on 4/10/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

final class DataMediator<DataInterface: DataInterfacing>: NSObject, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    typealias Item = DataInterface.DataSourceType.Item
    typealias Header = DataInterface.DataSourceType.Header
    
    var dataSource: DataInterface.DataSourceType?

    private var defaultDisplayVariants: [ItemTypeIdentifier: Variant] = [:]
    private var itemMediators: [ItemTypeVariantIdentifier: ItemMediator] = [:]
    private var viewControllerTypes: [ItemTypeVariantIdentifier: UIViewController.Type] = [:]
    private var registeredSupplementaryViewIdentifiers: Set<ItemTypeVariantIdentifier> = []
    private var headerHeightCache: [Int: CGFloat] = [:]
    
    private weak var dataInterface: DataInterface!
    
    init(dataInterface: DataInterface) {
        self.dataInterface = dataInterface
    }
    
    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemCount(forSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let (identifier, itemMediator, item) = info(for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier.value, for: indexPath) as! HostingView
        let viewController = cell.viewController ?? hostContent(in: cell, for: item, with: identifier)
        
        itemMediator.interface(viewController, item)
        return cell as! UITableViewCell
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionCount
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount(forSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let (identifier, itemMediator, item) = info(for: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier.value, for: indexPath) as! HostingView
        let viewController = cell.viewController ?? hostContent(in: cell, for: item, with: identifier)
        
        itemMediator.interface(viewController, item)
        return cell as! UICollectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let identifier = headerIdentifier(for: indexPath.section) else { return (nil as UICollectionReusableView?)! }
            
            if !registeredSupplementaryViewIdentifiers.contains(identifier) {
                let nib = self.nib(for: identifier)
                collectionView.register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier.value)
                registeredSupplementaryViewIdentifiers.insert(identifier)
            }
            
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier.value, for: indexPath)
            return view
        default:
            return (nil as UICollectionReusableView?)!
        }
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let identifier = headerIdentifier(for: section) else { return .zero }
        
        let height = headerHeightCache[section] ?? {
            let nib = self.nib(for: identifier)
            let view = nib.instantiate(withOwner: nil, options: nil).first as! UICollectionReusableView
            let height = view.bounds.height
            headerHeightCache[section] = height
            return height
        }()
        
        return .init(width: collectionView.bounds.width, height: height)
    }
}

// MARK: -
extension DataMediator {
    var itemTypeVariantIdentifiers: [ItemTypeVariantIdentifier] {
        return Array(viewControllerTypes.keys)
    }
    
    func supportInterfacing<Item, Interface: ItemInterfacing>(with itemType: Item.Type, using interfaceType: Interface.Type) where Item == Interface.View.Item {
        let variants = Interface.View.itemDisplayVariants
        for variant in variants {
            let itemTypeIdentifier = ItemTypeIdentifier(itemType: itemType)
            let itemTypeVariantIdentifier = ItemTypeVariantIdentifier(itemTypeIdentifier: itemTypeIdentifier, variant: variant)
            
            defaultDisplayVariants[itemTypeIdentifier] = Interface.View.defaultVariant
            itemMediators[itemTypeVariantIdentifier] = .init(interfaceType: interfaceType, displayVariant: variant)
            viewControllerTypes[itemTypeVariantIdentifier] = interfaceType
        }
    }
}

// MARK: -
private extension DataMediator {
    var sectionCount: Int {
        let sections = dataSource?.sections
        return sections?.count ?? 0
    }
    
    func itemCount(forSection section: Int) -> Int {
        let section = dataSource?.sections[section]
        return section?.itemCount ?? 0
    }
    
    func info(for indexPath: IndexPath) -> (ItemTypeVariantIdentifier, ItemMediator, Item) {
        let item = dataSource!.item(at: indexPath)
        let itemType = type(of: item)
        let itemTypeIdentifier = ItemTypeIdentifier(itemType: itemType)
        let displayVariant = dataInterface.displayVariant(for: item) ?? defaultDisplayVariants[itemTypeIdentifier] ?? Invariant()
        let itemTypeVariantIdentifier = ItemTypeVariantIdentifier(itemTypeIdentifier: itemTypeIdentifier, variant: displayVariant)
        let itemMediator = itemMediators[itemTypeVariantIdentifier]!
        return (itemTypeVariantIdentifier, itemMediator, item)
    }
    
    func viewType(for viewControllerType: UIViewController.Type) -> NibLoadable.Type {
        let viewControllerName = String(describing: viewControllerType)
        let viewName = viewControllerName.replacingOccurrences(of: "Controller", with: "")
        return NSClassFromString("View.\(viewName)") as! NibLoadable.Type
    }
    
    func headerIdentifier(for section: Int) -> ItemTypeVariantIdentifier? {
        guard let header = dataSource?.sections[section].header else { return nil }
        
        let headerTypeIdentifier = ItemTypeIdentifier(itemType: type(of: header))
        return .init(itemTypeIdentifier: headerTypeIdentifier, variant: Invariant())
    }
    
    func nib(for identifier: ItemTypeVariantIdentifier) -> UINib {
        let nibName = "\(identifier.value)View"
        let viewClass: AnyClass = NSClassFromString("View.\(nibName)")!
        let bundle = Bundle(for: viewClass)
        return .init(nibName: nibName, bundle: bundle)
    }
    
    func hostContent(in hostingView: HostingView, for item: Item, with identifier: ItemTypeVariantIdentifier) -> UIViewController {
        let viewControllerType = viewControllerTypes[identifier]!
        let viewController = viewControllerType.init()
        let viewType = self.viewType(for: viewControllerType)
        let hostingViewController = dataInterface as UIViewController
        let mediator = itemMediators[identifier]!
        let displayVariant = mediator.displayVariant
        let variableSize = mediator.variableSize(viewController)
        
        hostingView.hostContent(of: viewType, from: viewController, with: displayVariant, variableSize: variableSize)
        hostingViewController.addChild(viewController)
        viewController.didMove(toParent: hostingViewController)

        return viewController
    }
}

// MARK: -
extension IndexPath: SectionIndexPath {}
