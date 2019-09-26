//
//  BaseCoordinator.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

open class BaseCoordinator<T: DataSource, U: UIViewController & ViewController>:
  NSObject,
  CoordinatorNavigator,
  CoordinatorPresentable,
  DataSourceUpdateDelegate,
  ListControllerSizeDelegate,
  ViewControllerDelegate
{
  public typealias CoordinatorVC = U

  public weak var parent: Coordinator?
  public var childCoordinators = [Coordinator]()
  public let listController = ListController()

  public let viewController: U
  public let dataSource: T
  public let navigator: Navigator

  public init(navigator: Navigator, viewController: U, dataSource: T) {
    self.navigator = navigator
    self.viewController = viewController
    self.dataSource = dataSource

    super.init()

    listController.collectionView = viewController.collectionView
    listController.viewController = viewController
    listController.sizeDelegate = self
    dataSource.updateDelegate = self
    viewController.lifecycleDelegate = self
  }

  // MARK: - DataSourceUpdateDelegate
  open func dataSource(_ dataSource: DataSource, encountered error: Error) {
  }

  open func dataSource(
    _ dataSource: DataSource,
    update sections: [ListSection],
    animated: Bool,
    completion: DataSourceUpdateDelegate.Completion?
  ) {
    listController.update(with: sections, animated: animated, completion: completion)
  }
  open func dataSourceStartedUpdate(_ dataSource: DataSource) {
  }
  open func dataSourceCompletedUpdate(_ dataSource: DataSource) {
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
  open func viewController(_ viewController: ViewController, viewWillAppear animated: Bool) {
    listController.willDisplay()
  }
  open func viewController(_ viewController: ViewController, viewWillDisappear animated: Bool) {

  }
  open func viewController(_ viewController: ViewController, viewDidDisappear animated: Bool) {
    listController.didEndDisplaying()
  }
}
