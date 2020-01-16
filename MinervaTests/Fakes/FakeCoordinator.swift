//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxSwift

public final class FakeCoordinator: BaseCoordinator<FakePresenter, CollectionViewController> {

  public var viewDidLoad = false
  public var viewWillAppear = false
  public var viewWillDisappear = false
  public var viewDidDisappear = false
  public var traitCollectionDidChange = false

  public init(navigator: Navigator? = nil) {
    let layout = ListViewLayout(stickyHeaders: false, topContentInset: 0, stretchToEdge: false)
    let collectionVC = CollectionViewController(layout: layout)
    collectionVC.backgroundImage = UIImage()
    let listController = LegacyListController()
    let navigator = navigator ?? BasicNavigator(parent: nil)
    let presenter = FakePresenter()
    super.init(
      navigator: navigator,
      viewController: collectionVC,
      presenter: presenter,
      listController: listController)
    collectionVC.view.frame = CGRect(x: 0, y: 0, width: 500, height: 10_000)
  }

  // MARK: - ListControllerSizeDelegate

  override public func listController(
    _ listController: ListController,
    sizeFor model: ListCellModel,
    at indexPath: IndexPath,
    constrainedTo sizeConstraints: ListSizeConstraints
  ) -> CGSize? {
    return CGSize(width: sizeConstraints.adjustedContainerSize.width, height: 24)
  }

  // MARK: - ViewControllerDelegate
  override public func viewControllerViewDidLoad(_ viewController: ViewController) {
    super.viewControllerViewDidLoad(viewController)
    viewDidLoad = true
  }
  override public func viewController(_ viewController: ViewController, viewWillAppear animated: Bool) {
    super.viewController(viewController, viewWillAppear: animated)
    viewWillAppear = true
  }
  override public func viewController(_ viewController: ViewController, viewWillDisappear animated: Bool) {
    super.viewController(viewController, viewWillAppear: animated)
    viewWillDisappear = true
  }
  override public func viewController(_ viewController: ViewController, viewDidDisappear animated: Bool) {
    super.viewController(viewController, viewWillDisappear: animated)
    viewDidDisappear = true
  }
  override public func viewController(
    _ viewController: ViewController,
    traitCollectionDidChangeFrom previousTraitCollection: UITraitCollection?
  ) {
    super.viewController(viewController, traitCollectionDidChangeFrom: previousTraitCollection)
    traitCollectionDidChange = true
  }
}
