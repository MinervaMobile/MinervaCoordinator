//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxSwift
import UIKit

public final class WorkoutDetailsCoordinator: MainCoordinator<
  WorkoutDetailsPresenter, CollectionViewController
>
{

  private let dataManager: DataManager

  // MARK: - Lifecycle

  public init(navigator: Navigator, dataManager: DataManager, workout: Workout, editing: Bool) {
    self.dataManager = dataManager
    let presenter = WorkoutDetailsPresenter(workout: workout)
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
    viewController.title = "Workout Details"
  }

  // MARK: - Private

  private func edit(workout: Workout) {
    let coordinator = EditWorkoutCoordinator(
      navigator: navigator,
      dataManager: dataManager,
      workout: workout,
      editing: true
    )
    push(coordinator)
  }
  private func handle(_ action: WorkoutDetailsPresenter.Action) {
    switch action {
    case .edit(let workout):
      edit(workout: workout)
    }
  }
}
