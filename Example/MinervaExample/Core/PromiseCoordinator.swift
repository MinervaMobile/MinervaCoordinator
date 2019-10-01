//
//  PromiseCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva

public class PromiseCoordinator<T: PromiseDataSource, U: ViewController>: MainCoordinator<T, U>, DataSourceUpdateDelegate {

  public typealias RefreshBlock = (_ dataSource: T, _ animated: Bool) -> Void

  public var refreshBlock: RefreshBlock?

  override public init(navigator: Navigator, viewController: U, dataSource: T) {
    super.init(navigator: navigator, viewController: viewController, dataSource: dataSource)
    dataSource.updateDelegate = self
  }

  // MARK: - DataSourceUpdateDelegate
  public func dataSource(_ dataSource: DataSource, encountered error: Error) {
    viewController.alert(error, title: "Failed to load your data")
  }
  public func dataSource(
    _ dataSource: DataSource,
    update sections: [ListSection],
    animated: Bool,
    completion: DataSourceUpdateDelegate.Completion?
  ) {
    listController.update(with: sections, animated: animated, completion: completion)
  }
  public func dataSourceStartedUpdate(_ dataSource: DataSource) {
    LoadingHUD.show(in: viewController.view)
  }
  public func dataSourceCompletedUpdate(_ dataSource: DataSource) {
    LoadingHUD.hide(from: viewController.view)
  }

  // MARK: - ViewControllerDelegate
  override public func viewController(_ viewController: ViewController, viewWillAppear animated: Bool) {
    super.viewController(viewController, viewWillAppear: animated)
    refreshBlock?(dataSource, animated)
  }
}
