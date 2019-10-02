//
//  BaseCoordinator.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

open class BaseCoordinator<T: DataSource, U: ViewController>: NSObject, CoordinatorNavigator, CoordinatorPresentable, ListControllerSizeDelegate, ViewControllerDelegate {

  public typealias CoordinatorVC = U

  public weak var parent: Coordinator?
  public var childCoordinators = [Coordinator]()
  public let listController: ListController

  public let viewController: U
  public let dataSource: T
  public let navigator: Navigator

  public init(
    navigator: Navigator,
    viewController: U,
    dataSource: T,
    listController: ListController
  ) {
    self.navigator = navigator
    self.viewController = viewController
    self.dataSource = dataSource
    self.listController = listController

    super.init()

    listController.collectionView = viewController.collectionView
    listController.viewController = viewController
    listController.sizeDelegate = self
    viewController.lifecycleDelegate = self
  }

  // MARK: - ListControllerSizeDelegate

  open func listController(
    _ listController: ListController,
    sizeFor model: ListCellModel,
    at indexPath: IndexPath,
    constrainedTo sizeConstraints: ListSizeConstraints
  ) -> CGSize? {
    return nil
  }

  // MARK: - ViewControllerDelegate
  open func viewControllerViewDidLoad(_ viewController: ViewController) {

  }
  open func viewController(_ viewController: ViewController, viewWillAppear animated: Bool) {
    listController.willDisplay()
  }
  open func viewController(_ viewController: ViewController, viewWillDisappear animated: Bool) {

  }
  open func viewController(_ viewController: ViewController, viewDidDisappear animated: Bool) {
    listController.didEndDisplaying()
  }
  open func viewController(
    _ viewController: ViewController,
    traitCollectionDidChangeFrom previousTraitCollection: UITraitCollection?
  ) {
    listController.reloadData()
  }
}
