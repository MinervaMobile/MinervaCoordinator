//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxSwift
import UIKit

public protocol FilterCoordinatorDelegate: AnyObject {
  func filterCoordinator(
    _ filterCoordinator: FilterCoordinator,
    updatedFilter filter: WorkoutFilter
  )
}

public final class FilterCoordinator: MainCoordinator<FilterPresenter, CollectionViewController> {

  public weak var delegate: FilterCoordinatorDelegate?

  // MARK: - Lifecycle

  public init(navigator: Navigator, filter: Observable<WorkoutFilter>) {
    let presenter = FilterPresenter(filter: filter)
    let viewController = CollectionViewController()
    let listController = LegacyListController()
    super
      .init(
        navigator: navigator,
        viewController: viewController,
        presenter: presenter,
        listController: listController
      )
    presenter.actions
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] in self?.handle($0) })
      .disposed(
        by: disposeBag
      )
  }

  // MARK: - Private

  private func displayFilterPopup(with filter: WorkoutFilter, type: FilterType) {
    let coordinator = UpdateFilterCoordinator(navigator: navigator, filter: filter, type: type)
    coordinator.delegate = self
    push(coordinator, animated: true)
  }
  private func handle(_ action: FilterPresenter.Action) {
    switch action {
    case let .edit(filter, type):
      displayFilterPopup(with: filter, type: type)
    }
  }
}

// MARK: - UpdateFilterPresenterDelegate
extension FilterCoordinator: UpdateFilterCoordinatorDelegate {
  public func updateFilterCoordinator(
    _ updateFilterCoordinator: UpdateFilterCoordinator,
    updatedFilter filter: WorkoutFilter
  ) {
    delegate?.filterCoordinator(self, updatedFilter: filter)
  }
}
