//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxSwift
import UIKit

public final class EditWorkoutCoordinator: MainCoordinator<
  EditWorkoutPresenter, CollectionViewController
> {
  private let dataManager: DataManager

  // MARK: - Lifecycle

  public init(navigator: Navigator, dataManager: DataManager, workout: Workout, editing: Bool) {
    self.dataManager = dataManager
    let presenter = EditWorkoutPresenter(workout: workout)
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
    viewController.title = editing ? "Update Workout" : "Add Workout"
  }

  // MARK: - Private

  private func save(workout: Workout) {
    LoadingHUD.show(in: viewController.view)
    dataManager.store(workout)
      .observeOn(MainScheduler.instance)
      .subscribe(
        onSuccess: { [weak self] () -> Void in
          guard let strongSelf = self else { return }
          LoadingHUD.hide(from: strongSelf.viewController.view)
          strongSelf.navigator.dismiss(strongSelf.viewController, animated: true)
        },
        onError: { [weak self] error -> Void in
          guard let strongSelf = self else { return }
          LoadingHUD.hide(from: strongSelf.viewController.view)
          strongSelf.viewController.alert(error, title: "Failed to store the workout")
        }
      )
      .disposed(by: disposeBag)
  }

  private func handle(_ action: EditWorkoutPresenter.Action) {
    switch action {
    case let .save(workout):
      save(workout: workout)
    }
  }
}
