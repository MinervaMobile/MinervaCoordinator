//
//  UpdateFilterCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva
import RxSwift

protocol UpdateFilterCoordinatorDelegate: AnyObject {
  func updateFilterCoordinator(
    _ updateFilterCoordinator: UpdateFilterCoordinator,
    updatedFilter filter: WorkoutFilter
  )
}

final class UpdateFilterCoordinator: MainCoordinator<UpdateFilterDataSource, CollectionViewController> {

  weak var delegate: UpdateFilterCoordinatorDelegate?

  // MARK: - Lifecycle

  init(navigator: Navigator, filter: WorkoutFilter, type: FilterType) {

    let dataSource = UpdateFilterDataSource(type: type, filter: filter)
    let viewController = CollectionViewController()
    let listController = LegacyListController()
    super.init(
      navigator: navigator,
      viewController: viewController,
      dataSource: dataSource,
      listController: listController
    )
    dataSource.actions.subscribe(onNext: { [weak self] in self?.handle($0) }).disposed(by: disposeBag)
  }
  private func handle(_ action: UpdateFilterDataSource.Action) {
    switch action {
    case .update(let filter):
      delegate?.updateFilterCoordinator(self, updatedFilter: filter)
    }
  }
}
