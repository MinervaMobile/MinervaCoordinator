//
//  EditWorkoutCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva
import RxSwift

final class EditWorkoutCoordinator: MainCoordinator<EditWorkoutPresenter, CollectionViewController> {

  private let dataManager: DataManager

  // MARK: - Lifecycle

  init(navigator: Navigator, dataManager: DataManager, workout: Workout, editing: Bool) {
    self.dataManager = dataManager
    let dataSource = EditWorkoutPresenter(workout: workout)
    let viewController = CollectionViewController()
    let listController = LegacyListController()
    super.init(
      navigator: navigator,
      viewController: viewController,
      dataSource: dataSource,
      listController: listController
    )
    dataSource.actions.subscribe(onNext: { [weak self] in self?.handle($0) }).disposed(by: disposeBag)
    viewController.title = editing ? "Update Workout" : "Add Workout"
  }

  private func save(workout: Workout) {
    LoadingHUD.show(in: viewController.view)
    dataManager.store(workout)
      .observeOn(MainScheduler.instance)
      .subscribe(
        onSuccess: { [weak self] () -> Void in
          guard let strongSelf = self else { return }
          LoadingHUD.hide(from: strongSelf.viewController.view)
          strongSelf.navigator.dismiss(strongSelf.viewController, animated: true, completion: nil)
        },
        onError: { [weak self] error -> Void in
          guard let strongSelf = self else { return }
          LoadingHUD.hide(from: strongSelf.viewController.view)
          strongSelf.viewController.alert(error, title: "Failed to store the workout")
        }
      ).disposed(by: disposeBag)
  }
  private func handle(_ action: EditWorkoutPresenter.Action) {
    switch action {
    case .save(let workout):
      save(workout: workout)
    }
  }
}
