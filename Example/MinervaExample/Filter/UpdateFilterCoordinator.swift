//
//  UpdateFilterCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva
import PromiseKit

protocol UpdateFilterCoordinatorDelegate: AnyObject {
  func updateFilterCoordinator(
    _ updateFilterCoordinator: UpdateFilterCoordinator,
    updatedFilter filter: WorkoutFilter
  )
}

final class UpdateFilterCoordinator: PromiseCoordinator<UpdateFilterDataSource, CollectionViewController> {

  weak var delegate: UpdateFilterCoordinatorDelegate?

  // MARK: - Lifecycle

  init(navigator: Navigator, filter: WorkoutFilter, type: FilterType) {

    let dataSource = UpdateFilterDataSource(type: type, filter: filter)
    let viewController = CollectionViewController()
    super.init(navigator: navigator, viewController: viewController, dataSource: dataSource)
    self.refreshBlock = { dataSource, animated in
      dataSource.reload(animated: animated)
    }
    dataSource.delegate = self
  }
}

// MARK: - UpdateFilterDataSourceDelegate
extension UpdateFilterCoordinator: UpdateFilterDataSourceDelegate {
  func updateFilterDataSource(
    _ updateFilterDataSource: UpdateFilterDataSource,
    selected action: UpdateFilterDataSource.Action
  ) {
    switch action {
    case .update(let filter):
      delegate?.updateFilterCoordinator(self, updatedFilter: filter)
    }
  }
}
