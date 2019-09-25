//
//  SettingsCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import PromiseKit
import Minerva

protocol SettingsCoordinatorDelegate: AnyObject {
  func settingsCoordinatorLogoutCurrentUser(
    _ settingsCoordinator: SettingsCoordinator
  )
}

final class SettingsCoordinator: MainCoordinator<SettingsDataSource, CollectionViewController> {

  weak var delegate: SettingsCoordinatorDelegate?
  private let userManager: UserManager
  private let dataManager: DataManager

  // MARK: - Lifecycle

  init(navigator: Navigator, userManager: UserManager, dataManager: DataManager) {
    self.userManager = userManager
    self.dataManager = dataManager

    let dataSource = SettingsDataSource(dataManager: dataManager)
    let welcomeVC = CollectionViewController()
    super.init(navigator: navigator, viewController: welcomeVC, dataSource: dataSource) { dataSource, animated in
      dataSource.reload(animated: animated)
    }
    viewController.title = "Settings"
    dataSource.delegate = self
  }

  // MARK: - Private

  private func deleteUser() {
    let userID = dataManager.userAuthorization.userID
    LoadingHUD.show(in: viewController.view)
    userManager.delete(userID: userID).done { [weak self] () -> Void in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.settingsCoordinatorLogoutCurrentUser(strongSelf)
    }.catch { [weak self] error -> Void in
      self?.viewController.alert(error, title: "Failed to delete the user")
    }.finally { [weak self] in
      LoadingHUD.hide(from: self?.viewController.view)
    }
  }

  private func logoutUser() {
    let userID = dataManager.userAuthorization.userID
    LoadingHUD.show(in: viewController.view)
    userManager.logout(userID: userID).done { [weak self] () -> Void in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.settingsCoordinatorLogoutCurrentUser(strongSelf)
    }.catch { [weak self] error -> Void in
      self?.viewController.alert(error, title: "Failed to logout")
    }.finally { [weak self] in
      LoadingHUD.hide(from: self?.viewController.view)
    }
  }

  private func displayUserUpdatePopup(for user: User) {
    let dataSource = UpdateUserActionSheetDataSource(user: user)
    dataSource.delegate = self
    let actionSheetVC = ActionSheetVC(dataSource: dataSource)
    actionSheetVC.transitioningDelegate = self
    actionSheetVC.present(from: viewController)
  }

  private func save(user: User) {
    LoadingHUD.show(in: viewController.view)
    dataManager.update(user: user).done { [weak self] () -> Void in
      guard let strongSelf = self else { return }
      strongSelf.dataSource.reload(animated: true)
      strongSelf.viewController.dismiss(animated: true, completion: nil)
    }.catch { [weak self] error -> Void in
      self?.viewController.alert(error, title: "Failed to save the user")
    }.finally { [weak self] in
      LoadingHUD.hide(from: self?.viewController.view)
    }
  }
}


// MARK: - SettingsDataSourceDelegate
extension SettingsCoordinator: SettingsDataSourceDelegate {
  func settingsDataSource(_ settingsDataSource: SettingsDataSource, selected action: SettingsDataSource.Action) {
    switch action {
    case .deleteAccount:
      deleteUser()
    case .logout:
      logoutUser()
    case .update(let user):
      displayUserUpdatePopup(for: user)
    }
  }
}

// MARK: - UpdateUserActionSheetDataSourceDelegate
extension SettingsCoordinator: UpdateUserActionSheetDataSourceDelegate {
  func updateUserActionSheetDataSource(
    _ updateUserActionSheetDataSource: UpdateUserActionSheetDataSource,
    selected action: UpdateUserActionSheetDataSource.Action
  ) {
    switch action {
    case .dismiss:
      viewController.dismiss(animated: true, completion: nil)
    case .save(let user):
      save(user: user)
    }
  }
}
