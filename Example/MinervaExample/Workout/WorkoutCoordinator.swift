//
//  WorkoutCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva
import RxSwift

final class WorkoutCoordinator: MainCoordinator<WorkoutPresenter, WorkoutVC> {

  private let dataManager: DataManager
  private let interactor: WorkoutInteractor
  private let disposeBag = DisposeBag()

  // MARK: - Lifecycle

  init(navigator: Navigator, dataManager: DataManager, userID: String) {
    self.dataManager = dataManager

    let repository = WorkoutRepository(dataManager: dataManager, userID: userID)
    self.interactor = WorkoutInteractor(repository: repository)
    let presenter = WorkoutPresenter(interactor: interactor)
    let listController = ListController()
    let viewController = WorkoutVC(interactor: interactor, presenter: presenter, listController: listController)
    super.init(
      navigator: navigator,
      viewController: viewController,
      dataSource: presenter,
      listController: listController)

  }

  // MARK: - ViewControllerDelegate
  override public func viewControllerViewDidLoad(_ viewController: ViewController) {
    super.viewControllerViewDidLoad(viewController)

    interactor.actions
      .subscribe(onNext: handle(action:), onError: nil, onCompleted: nil, onDisposed: nil)
      .disposed(by: disposeBag)
  }

  // MARK: - Private

  private func handle(action: WorkoutInteractor.Action) {
    switch action {
    case .createWorkout(let userID):
      displayWorkoutPopup(with: nil, forUserID: userID)
    case .edit(let workout):
      displayWorkoutPopup(with: workout, forUserID: workout.userID)
    case .update(let filter):
      displayFilterSelection(with: filter)
    }
  }

  private func displayWorkoutPopup(with workout: Workout?, forUserID userID: String) {
    let editing = workout != nil
    let workout = workout
      ?? WorkoutProto(workoutID: UUID().uuidString, userID: userID, text: "", calories: 0, date: Date())

    let navigator = BasicNavigator(parent: self.navigator)
    let coordinator = EditWorkoutCoordinator(
      navigator: navigator,
      dataManager: dataManager,
      workout: workout,
      editing: editing)
    coordinator.addCloseButton() { [weak self] child in
      self?.dismiss(child, animated: true)
    }
    present(coordinator, from: navigator, animated: true, modalPresentationStyle: .safeAutomatic)
  }

  private func displayFilterSelection(with filter: WorkoutFilter) {
    let navigator = BasicNavigator(parent: self.navigator)
    let coordinator = FilterCoordinator(navigator: navigator, filter: filter)
    coordinator.delegate = self
    coordinator.addCloseButton() { [weak self] child in
      self?.dismiss(child, animated: true)
    }
    present(coordinator, from: navigator, animated: true, modalPresentationStyle: .safeAutomatic)
  }
}

// MARK: - FilterCoordinatorDelegate
extension WorkoutCoordinator: FilterCoordinatorDelegate {
  func filterCoordinator(_ filterCoordinator: FilterCoordinator, updatedFilter filter: WorkoutFilter) {
    interactor.apply(filter: filter)
    dismiss(filterCoordinator, animated: true)
  }
}
