//
//  EditWorkoutCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva
import PromiseKit

final class EditWorkoutCoordinator: PromiseCoordinator<EditWorkoutDataSource, CollectionViewController> {

  private let dataManager: DataManager

  // MARK: - Lifecycle

  init(navigator: Navigator, dataManager: DataManager, workout: Workout, editing: Bool) {
    self.dataManager = dataManager
    let dataSource = EditWorkoutDataSource(workout: workout, editing: editing)
    let viewController = CollectionViewController()
    super.init(navigator: navigator, viewController: viewController, dataSource: dataSource)
    self.refreshBlock = { dataSource, animated in
      dataSource.reload(animated: animated)
    }
    dataSource.delegate = self
    viewController.title = editing ? "Update Workout" : "Add Workout"
  }

  private func save(workout: Workout) {
    LoadingHUD.show(in: viewController.view)
    dataManager.store(workout: workout).done { [weak self] () -> Void in
      guard let strongSelf = self else { return }
      strongSelf.navigator.dismiss(strongSelf.viewController, animated: true, completion: nil)
    }.catch { [weak self] error -> Void in
      self?.viewController.alert(error, title: "Failed to store the workout")
    }.finally { [weak self] in
      LoadingHUD.hide(from: self?.viewController.view)
    }
  }
}

// MARK: - EditWorkoutDataSourceDelegate
extension EditWorkoutCoordinator: EditWorkoutDataSourceDelegate {
  func workoutActionSheetDataSource(
    _ workoutActionSheetDataSource: EditWorkoutDataSource,
    selected action: EditWorkoutDataSource.Action
  ) {
    switch action {
    case .save(let workout):
      save(workout: workout)
    }
  }
}
