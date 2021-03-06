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
    var selectedIndexPath: IndexPath?
    
    private var defaultDisplayVariants: [ItemTypeIdentifier: Variant] = [:]
    private var itemMediators: [ItemTypeVariantIdentifier: ItemMediator] = [:]
    private var viewControllerTypes: [ItemTypeVariantIdentifier: UIViewController.Type] = [:]
    private var registeredSupplementaryViewIdentifiers: Set<ItemTypeVariantIdentifier> = []
    private var headerHeightCache: [Int: CGFloat] = [:]
    
    private weak var dataInterface: DataInterface!
    
    init(dataInterface: DataInterface) {
        self.dataInterface = dataInterface
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dataInterface.handle(.didScroll, for: scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let scrollEvent = ScrollEvent.willEndDragging(velocity: velocity, targetContentOffset: targetContentOffset.pointee)
        dataInterface.handle(scrollEvent, for: scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        dataInterface.handle(.didEndDecelerating, for: scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        dataInterface.handle(.didEndScrollingAnimation, for: scrollView)
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
        let viewController = cell.viewController ?? hostContent(in: cell, for: identifier)
        
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
        let viewController = cell.viewController ?? hostContent(in: cell, for: identifier)
        
        itemMediator.interface(viewController, item)
        return cell as! UICollectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let (identifier, itemMediator, header) = headerInfo(for: indexPath.section) else { return (nil as UICollectionReusableView?)! }
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier.value, for: indexPath) as! HostingView
            let viewController = headerView.viewController ?? hostContent(in: headerView, for: identifier)
            
            itemMediator.interface(viewController, header)
            return headerView as! UICollectionReusableView
        default:
            return (nil as UICollectionReusableView?)!
        }
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let (viewController, itemMediator, item) = viewControllerInfo(for: indexPath, in: collectionView)
        return itemMediator.shouldSelect(viewController, item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let (viewController, itemMediator, item) = viewControllerInfo(for: indexPath, in: collectionView)
        
        itemMediator.prepareToSelect(viewController, item)
        selectedIndexPath = indexPath
        itemMediator.setSelected(viewController, item, true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let (viewController, itemMediator, _) = viewControllerInfo(for: indexPath, in: collectionView)
        let highlighted = true
        let animated = false
        
        itemMediator.highlight(viewController, highlighted, animated)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let (viewController, itemMediator, _) = viewControllerInfo(for: indexPath, in: collectionView)
        let highlighted = false
        let animated = !collectionView.isDragging
        
        itemMediator.highlight(viewController, highlighted, animated)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let (identifier, itemMediator, _) = headerInfo(for: section) else { return .zero }
        
        let height = headerHeightCache[section] ?? {
            let viewControllerType = viewControllerTypes[identifier]!
            let viewType = self.viewType(for: viewControllerType)
            let displayVariant = itemMediator.displayVariant
            let view = viewType.hostedView(of: displayVariant)
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
    
    func supportInterfacing<Interface: ItemInterfacing>(with itemType: Any.Type, using interfaceType: Interface.Type) {
        let variants = Interface.View.itemDisplayVariants
        for variant in variants {
            let itemTypeIdentifier = ItemTypeIdentifier(itemType: itemType)
            let itemTypeVariantIdentifier = ItemTypeVariantIdentifier(itemTypeIdentifier: itemTypeIdentifier, variant: variant)
            
            defaultDisplayVariants[itemTypeIdentifier] = Interface.View.defaultVariant
            itemMediators[itemTypeVariantIdentifier] = .init(interfaceType: interfaceType, displayVariant: variant, dataInterface: dataInterface)
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
        let itemType = type(of: item as Any)
        let itemTypeIdentifier = ItemTypeIdentifier(itemType: itemType)
        let itemCount = self.itemCount(forSection: indexPath.section)
        let itemPosition = ItemPosition(indexPath: indexPath, itemCount: itemCount)
        let displayVariant = dataInterface.displayVariant(for: item, at: itemPosition) ?? defaultDisplayVariants[itemTypeIdentifier] ?? Invariant()
        let itemTypeVariantIdentifier = ItemTypeVariantIdentifier(itemTypeIdentifier: itemTypeIdentifier, variant: displayVariant)
        let itemMediator = itemMediators[itemTypeVariantIdentifier]!
        return (itemTypeVariantIdentifier, itemMediator, item)
    }
    
    func headerInfo(for section: Int) -> (ItemTypeVariantIdentifier, ItemMediator, Header)? {
        guard let header = dataSource!.header(for: section) else { return nil }
        
        let itemType = type(of: header)
        let itemTypeIdentifier = ItemTypeIdentifier(itemType: itemType)
        let displayVariant = dataInterface.displayVariant(for: header) ?? defaultDisplayVariants[itemTypeIdentifier] ?? Invariant()
        let itemTypeVariantIdentifier = ItemTypeVariantIdentifier(itemTypeIdentifier: itemTypeIdentifier, variant: displayVariant)
        let itemMediator = itemMediators[itemTypeVariantIdentifier]!
        return (itemTypeVariantIdentifier, itemMediator, header)
    }

    func viewControllerInfo(for indexPath: IndexPath, in tableView: UITableView) -> (UIViewController, ItemMediator, Item) {
        let (_, itemMediator, item) = info(for: indexPath)
        let cell = tableView.cellForRow(at: indexPath) as! HostingView
        let viewController = cell.viewController!
        return (viewController, itemMediator, item)
    }
    
    func viewControllerInfo(for indexPath: IndexPath, in collectionView: UICollectionView) -> (UIViewController, ItemMediator, Item) {
        let (_, itemMediator, item) = info(for: indexPath)
        let cell = collectionView.cellForItem(at: indexPath) as! HostingView
        let viewController = cell.viewController!
        return (viewController, itemMediator, item)
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
    
    func hostContent(in hostingView: HostingView, for identifier: ItemTypeVariantIdentifier) -> UIViewController {
        let viewControllerType = viewControllerTypes[identifier]!
        let viewController = viewControllerType.init()
        let viewType = self.viewType(for: viewControllerType)
        let hostingViewController = dataInterface as UIViewController
        let mediator = itemMediators[identifier]!
        let displayVariant = mediator.displayVariant
        
        hostingView.hostContent(of: viewType, from: viewController, with: displayVariant)
        hostingViewController.addChild(viewController)
        viewController.didMove(toParent: hostingViewController)

        return viewController
    }
}

// MARK: -
extension IndexPath: SectionIndexPath {}

private extension CGSize {
    static let defaultItemSize: CGSize = .init(width: 50, height: 50)
}
