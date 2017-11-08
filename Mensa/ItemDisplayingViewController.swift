//
//  ItemDisplayingViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 5/8/17.
//  Copyright © 2017 Jordan Kay. All rights reserved.
//

final class ItemDisplayingViewController: UIViewController {
    private let nameOfNib: String
    private let update: (Any, DisplayVariant, Bool) -> Void
    private let updateForResting: (Any) -> Void
    private let select: (Any) -> Void
    private let canSelect: (Any) -> Bool
    private let canRemove: (Any) -> Bool
    private let setHighlighted: (Any, Bool, Bool) -> Void
    private let hostsWithConstraints: (DisplayVariant) -> Bool
    private let isItemHeightBasedOnTemplate: (DisplayVariant) -> Bool
    private let itemSizingStrategy: (Any, DisplayVariant) -> ItemSizingStrategy

    private var didLoadView = false
    
    private weak var viewController: UIViewController!
    
    init<V: UIViewController>(_ viewController: V) where V: ItemDisplaying {
        self.viewController = viewController
        
        nameOfNib = String(describing: type(of: viewController)).replacingOccurrences(of: "ViewController", with: "View")
        select = { viewController.selectItem($0 as! V.Item) }
        canSelect = { viewController.canSelectItem($0 as! V.Item) }
        setHighlighted = { viewController.setItemHighlighted($0 as! V.Item, highlighted: $1, animated: $2) }
        hostsWithConstraints = { viewController.hostsWithConstraints(displayedWith: $0) }
        isItemHeightBasedOnTemplate = { viewController.isItemHeightBasedOnTemplate(displayedWith: $0) }
        itemSizingStrategy = { viewController.itemSizingStrategy(for: $0 as! V.Item, displayedWith: $1) }
        canRemove = {
            ($0 as? V.Item).map { viewController.canRemoveItem($0) } ?? false
        }
        update = {
            (viewController.view as? Preparable)?.prepare()
            viewController.update(with: $0 as! V.Item, variant: $1, displayed: $2)
        }
        updateForResting = {
            if let item = $0 as? V.Item {
                viewController.updateForResting(with: item)
            }
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    func loadViewFromNib(for variant: DisplayVariant) {
        guard !didLoadView else { return }
        view = loadNibNamed(nibName: nameOfNib, variantID: variant.rawValue)
        didLoadView = true
    }
    
    func sizeOfNib(for variant: DisplayVariant) -> CGSize {
        return sizeOfNibNamed(nibName: nameOfNib, variantID: variant.rawValue)
    }
    
    func host(_ contentView: UIView, in parentViewController: UIViewController) {
        parentViewController.addChildViewController(viewController)
        view.frame = contentView.bounds
        contentView.addSubview(viewController.view)
        viewController.didMove(toParentViewController: parentViewController)
    }
    
    // MARK: UIViewController
    override var view: UIView! {
        get {
            return viewController.view
        }
        set {
            viewController.view = newValue
            viewController.viewDidLoad()
        }
    }
    
    override var parent: UIViewController? {
        return viewController.parent
    }
    
    // MARK: NSCoding
    required init?(coder: NSCoder) {
        fatalError()
    }
}

extension ItemDisplayingViewController: ItemDisplaying {
    typealias Item = Any
    typealias View = UIView
    
    func update(with item: Item, variant: DisplayVariant, displayed: Bool) {
        update(item, variant, displayed)
    }
    
    func updateForResting(with item: Item) {
        updateForResting(item)
    }
    
    func selectItem(_ item: Item) {
        select(item)
    }
    
    func canSelectItem(_ item: Item) -> Bool {
        return canSelect(item)
    }
    
    func canRemoveItem(_ item: Item) -> Bool {
        return canRemove(item)
    }
    
    func setItemHighlighted(_ item: Item, highlighted: Bool, animated: Bool) {
        setHighlighted(item, highlighted, animated)
    }
    
    func hostsWithConstraints(displayedWith variant: DisplayVariant) -> Bool {
        return hostsWithConstraints(variant)
    }
    
    func isItemHeightBasedOnTemplate(displayedWith variant: DisplayVariant) -> Bool {
        return isItemHeightBasedOnTemplate(variant)
    }
    
    func itemSizingStrategy(for item: Item, displayedWith variant: DisplayVariant) -> ItemSizingStrategy {
        return itemSizingStrategy(item, variant)
    }
}