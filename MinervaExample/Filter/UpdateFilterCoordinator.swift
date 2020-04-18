//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxSwift
import UIKit

public protocol UpdateFilterCoordinatorDelegate: AnyObject {
  func updateFilterCoordinator(
    _ updateFilterCoordinator: UpdateFilterCoordinator,
    updatedFilter filter: WorkoutFilter
  )
}

public final class UpdateFilterCoordinator: MainCoordinator<
  UpdateFilterPresenter, CollectionViewController
>
{

  public weak var delegate: UpdateFilterCoordinatorDelegate?

  // MARK: - Lifecycle

  public init(navigator: Navigator, filter: WorkoutFilter, type: FilterType) {
    let presenter = UpdateFilterPresenter(type: type, filter: filter)
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
  private func handle(_ action: UpdateFilterPresenter.Action) {
    switch action {
    case .update(let filter):
      delegate?.updateFilterCoordinator(self, updatedFilter: filter)
    }
  }
}
