//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxRelay
import RxSwift
import UIKit

public final class WorkoutCoordinator: MainCoordinator<WorkoutPresenter, WorkoutVC> {

  public enum Action {
    case displayViewWorkout(workout: Workout)
    case displayNewWorkout
  }

  public let actionRelay = PublishRelay<Action>()
  private let dataManager: DataManager

  // MARK: - Lifecycle

  public init(navigator: Navigator, dataManager: DataManager, userID: String) {
    self.dataManager = dataManager

    let repository = WorkoutRepository(dataManager: dataManager, userID: userID)
    let presenter = WorkoutPresenter(repository: repository)
    let listController = LegacyListController()
    let viewController = WorkoutVC(presenter: presenter, listController: listController)
    super
      .init(
        navigator: navigator,
        viewController: viewController,
        presenter: presenter,
        listController: listController
      )

    viewController.events
      .subscribe(onNext: { [weak self] event in
        self?.handle(event)
      })
      .disposed(by: disposeBag)
  }

  // MARK: - Private

  private func handle(_ event: ListViewControllerEvent) {
    guard case .viewDidLoad = event else { return }

    presenter.actions
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: handle(action:), onError: nil, onCompleted: nil, onDisposed: nil)
      .disposed(by: disposeBag)
  }

  private func handle(action: WorkoutPresenter.Action) {
    switch action {
    case .createWorkout:
      actionRelay.accept(.displayNewWorkout)
    case .editWorkout(let workout):
      actionRelay.accept(.displayViewWorkout(workout: workout))
    case .editFilter:
      displayFilterSelection()
    }
  }

  private func displayFilterSelection() {
    let navigator = BasicNavigator(parent: self.navigator)
    let coordinator = FilterCoordinator(navigator: navigator, filter: presenter.filter)
    coordinator.delegate = self
    presentWithCloseButton(coordinator, modalPresentationStyle: .safeAutomatic)
  }
}

// MARK: - FilterCoordinatorDelegate
extension WorkoutCoordinator: FilterCoordinatorDelegate {
  public func filterCoordinator(
    _ filterCoordinator: FilterCoordinator,
    updatedFilter filter: WorkoutFilter
  ) {
    presenter.apply(filter: filter)
    dismiss(filterCoordinator, animated: true)
  }
}
