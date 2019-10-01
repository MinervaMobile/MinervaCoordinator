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
  private let repository: WorkoutRepository
  private let interactor: WorkoutInteractor
  private let userID: String
  private let disposeBag: DisposeBag

  // MARK: - Lifecycle

  init(navigator: Navigator, dataManager: DataManager, userID: String) {
    self.userID = userID
    self.dataManager = dataManager
    self.disposeBag = DisposeBag()

    self.repository = WorkoutRepository(dataManager: dataManager, userID: userID)
    self.interactor = WorkoutInteractor(repository: repository)
    let presenter = WorkoutPresenter(interactor: interactor)
    let viewController = WorkoutVC()
    super.init(navigator: navigator, viewController: viewController, dataSource: presenter)

  }

  // MARK: - ViewControllerDelegate
  override public func viewControllerViewDidLoad(_ viewController: ViewController) {
    super.viewControllerViewDidLoad(viewController)

    repository.user
      .subscribe(onNext: updated(user:), onError: nil, onCompleted: nil, onDisposed: nil)
      .disposed(by: disposeBag)
    dataSource.actions
      .subscribe(onNext: handle(action:), onError: nil, onCompleted: nil, onDisposed: nil)
      .disposed(by: disposeBag)

    dataSource.sections
      .subscribe(onNext: handle(state:), onError: nil, onCompleted: nil, onDisposed: nil)
      .disposed(by: disposeBag)
    self.viewController.actions
      .subscribe(onNext: handle(action:), onError: nil, onCompleted: nil, onDisposed: nil)
      .disposed(by: disposeBag)
  }

  // MARK: - Private

  private func handle(state: PresenterState) {
    switch state {
    case .failure(let error):
      LoadingHUD.hide(from: viewController.view)
      viewController.alert(error, title: "Failed to load")
    case .loaded(let sections):
      LoadingHUD.hide(from: viewController.view)
      listController.update(with: sections, animated: true, completion: nil)
    case .loading:
      LoadingHUD.show(in: viewController.view)
    }
  }

  private func handle(action: WorkoutPresenter.Action) {
    switch action {
    case .delete(let workout):
      delete(workout: workout)
    case .edit(let workout):
      displayWorkoutPopup(with: workout, forUserID: workout.userID)
    }
  }

  private func handle(action: WorkoutVC.Action) {
    switch action {
    case .createWorkout:
      displayWorkoutPopup(with: nil, forUserID: userID)
    case .updateFilter:
//      displayFilterSelection()
      break
    case .toggleAll:
//      interactor.showFailuresOnly()
      break
    }
  }

  private func updated(user: Result<User, Error>) {
    switch user {
    case .success(let user):
      viewController.title = user.email
    case .failure(let error):
      viewController.alert(error, title: "Failed to load users data")
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

  private func delete(workout: Workout) {
    LoadingHUD.show(in: viewController.view)
    dataManager.delete(workout: workout).catch { [weak self] error -> Void in
      self?.viewController.alert(error, title: "Failed to delete the workout")
    }.finally { [weak self] in
      LoadingHUD.hide(from: self?.viewController.view)
    }
  }

  private func displayFilterSelection(with filter: WorkoutFilter) {
    let coordinator = FilterCoordinator(navigator: navigator, filter: filter)
    coordinator.delegate = self
    push(coordinator, animated: true)
  }
}

// MARK: - FilterCoordinatorDelegate
extension WorkoutCoordinator: FilterCoordinatorDelegate {
  func filterCoordinator(_ filterCoordinator: FilterCoordinator, updatedFilter filter: WorkoutFilter) {
    interactor.apply(filter: filter)
    dismiss(filterCoordinator, animated: true)
  }
}
