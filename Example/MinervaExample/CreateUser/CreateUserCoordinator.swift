//
//  CreateUserCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva
import PromiseKit

final class CreateUserCoordinator: PromiseCoordinator<CreateUserDataSource, CollectionViewController> {

  private let dataManager: DataManager

  // MARK: - Lifecycle

  init(navigator: Navigator, dataManager: DataManager) {
    self.dataManager = dataManager
    let dataSource = CreateUserDataSource()
    let viewController = CollectionViewController()
    super.init(navigator: navigator, viewController: viewController, dataSource: dataSource)
    self.refreshBlock = { dataSource, animated in
      dataSource.reload(animated: animated)
    }
    dataSource.delegate = self
    viewController.title = "Create User"
  }

  private func create(email: String, password: String, dailyCalories: Int32, role: UserRole) {
    LoadingHUD.show(in: viewController.view)
    dataManager.create(
      withEmail: email,
      password: password,
      dailyCalories: dailyCalories,
      role: role
    ).done { [weak self] () -> Void in
      guard let strongSelf = self else { return }
      strongSelf.navigator.dismiss(strongSelf.viewController, animated: true, completion: nil)
    }.catch { [weak self] error -> Void in
      self?.viewController.alert(error, title: "Failed to save the user")
    }.finally { [weak self] in
      LoadingHUD.hide(from: self?.viewController.view)
    }
  }
}

// MARK: - CreateUserDataSourceDelegate
extension CreateUserCoordinator: CreateUserDataSourceDelegate {

  func createUserActionSheetDataSource(
    _ createUserActionSheetDataSource: CreateUserDataSource,
    selected action: CreateUserDataSource.Action
  ) {
    switch action {
    case let .create(email, password, dailyCalories, role):
      create(email: email, password: password, dailyCalories: dailyCalories, role: role)
    }
  }
}
