//
//  WorkoutCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva
import PromiseKit

final class WorkoutCoordinator: PromiseCoordinator<WorkoutDataSource, WorkoutVC> {

  private let dataManager: DataManager
  private let userID: String

  // MARK: - Lifecycle

  init(navigator: Navigator, dataManager: DataManager, userID: String) {
    self.userID = userID
    self.dataManager = dataManager

    let dataSource = WorkoutDataSource(userID: userID, dataManager: dataManager)
    let viewController = WorkoutVC()
    super.init(navigator: navigator, viewController: viewController, dataSource: dataSource)
    self.refreshBlock = { dataSource, animated in
      dataSource.reload(animated: animated)
    }
    dataSource.delegate = self
    viewController.delegate = self

    dataSource.loadTitle().map { [weak self] title -> Void in
      self?.viewController.title = title
    }.catch { [weak self] error -> Void in
      self?.viewController.alert(error, title: "Failed to load users data")
    }
  }

  // MARK: - Private

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
    dataManager.delete(workout: workout).done { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.dataSource.reload(animated: true)
    }.catch { [weak self] error -> Void in
      self?.viewController.alert(error, title: "Failed to delete the workout")
    }.finally { [weak self] in
      LoadingHUD.hide(from: self?.viewController.view)
    }
  }

  private func displayFilterSelection() {
    let coordinator = FilterCoordinator(navigator: navigator, filter: dataSource.filter)
    coordinator.delegate = self
    push(coordinator, animated: true)
  }

  private func apply(filter: WorkoutFilter) {
    dataSource.filter = filter
    dataSource.reload(animated: true)
    viewController.dismiss(animated: true, completion: nil)
  }
}

// MARK: - FilterCoordinatorDelegate
extension WorkoutCoordinator: FilterCoordinatorDelegate {
  func filterCoordinator(_ filterCoordinator: FilterCoordinator, updatedFilter filter: WorkoutFilter) {
    apply(filter: filter)
  }
}

// MARK: - WorkoutDataSourceDelegate
extension WorkoutCoordinator: WorkoutDataSourceDelegate {
  func workoutDataSource(_ workoutDataSource: WorkoutDataSource, selected action: WorkoutDataSource.Action) {
    switch action {
    case .delete(let workout):
      delete(workout: workout)
    case .edit(let workout):
      displayWorkoutPopup(with: workout, forUserID: workout.userID)
    }
  }
}

// MARK: - WorkoutVCDelegate
extension WorkoutCoordinator: WorkoutVCDelegate {
  func workoutVC(_ workoutVC: WorkoutVC, selected action: WorkoutVC.Action) {
    switch action {
    case .createWorkout:
      displayWorkoutPopup(with: nil, forUserID: userID)
    case .updateFilter:
      displayFilterSelection()
    }
  }
}
