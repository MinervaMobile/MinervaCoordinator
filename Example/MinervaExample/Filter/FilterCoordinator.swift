//
//  FilterCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import PromiseKit
import Minerva

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

  private func apply(filter: WorkoutFilter) {
    delegate?.filterCoordinator(self, updatedFilter: filter)
  }

  private func displayFilterPopup(with filter: WorkoutFilter, type: FilterType) {
    let dataSource = FilterActionSheetDataSource(type: type, filter: filter)
    dataSource.delegate = self
    let actionSheetVC = ActionSheetVC(dataSource: dataSource)
    actionSheetVC.transitioningDelegate = self
    actionSheetVC.present(from: viewController)
  }
}

// MARK: - FilterActionSheetDataSourceDelegate
extension FilterCoordinator: FilterActionSheetDataSourceDelegate {
  func filterActionSheetDataSource(
    _ filterActionSheetDataSource: FilterActionSheetDataSource,
    selected action: FilterActionSheetDataSource.Action
  ) {
    switch action {
    case .update(let filter):
      apply(filter: filter)
    }
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



