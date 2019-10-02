//
//  FilterCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva
import PromiseKit

protocol FilterCoordinatorDelegate: AnyObject {
  func filterCoordinator(
    _ filterCoordinator: FilterCoordinator,
    updatedFilter filter: WorkoutFilter
  )
}

final class FilterCoordinator: PromiseCoordinator<FilterDataSource, CollectionViewController> {

  weak var delegate: FilterCoordinatorDelegate?

  // MARK: - Lifecycle

  init(navigator: Navigator, filter: WorkoutFilter) {

    let dataSource = FilterDataSource(filter: filter)
    let viewController = CollectionViewController()
    super.init(navigator: navigator, viewController: viewController, dataSource: dataSource)
    self.refreshBlock = { dataSource, animated in
      dataSource.reload(animated: animated)
    }
    dataSource.delegate = self
  }

  // MARK: - Private

  private func displayFilterPopup(with filter: WorkoutFilter, type: FilterType) {
    let coordinator = UpdateFilterCoordinator(navigator: navigator, filter: filter, type: type)
    coordinator.delegate = self
    push(coordinator, animated: true)
  }
}

// MARK: - UpdateFilterDataSourceDelegate
extension FilterCoordinator: UpdateFilterCoordinatorDelegate {
  func updateFilterCoordinator(
    _ updateFilterCoordinator: UpdateFilterCoordinator,
    updatedFilter filter: WorkoutFilter
  ) {
    dataSource.filter = filter
    dataSource.reload(animated: true)
    delegate?.filterCoordinator(self, updatedFilter: filter)
  }
}

// MARK: - FilterDataSourceDelegate
extension FilterCoordinator: FilterDataSourceDelegate {
  func filterDataSource(_ filterDataSource: FilterDataSource, selected action: FilterDataSource.Action) {
    switch action {
    case let .edit(filter, type):
      displayFilterPopup(with: filter, type: type)
    }
  }
}
