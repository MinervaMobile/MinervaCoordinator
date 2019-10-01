//
//  SettingsCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva
import PromiseKit

protocol SettingsCoordinatorDelegate: AnyObject {
  func settingsCoordinatorLogoutCurrentUser(
    _ settingsCoordinator: SettingsCoordinator
  )
}

final class SettingsCoordinator: PromiseCoordinator<SettingsDataSource, CollectionViewController> {

  weak var delegate: SettingsCoordinatorDelegate?
  private let userManager: UserManager
  private let dataManager: DataManager

  // MARK: - Lifecycle

  init(navigator: Navigator, userManager: UserManager, dataManager: DataManager) {
    self.userManager = userManager
    self.dataManager = dataManager

    let dataSource = SettingsDataSource(dataManager: dataManager)
    let welcomeVC = CollectionViewController()
    super.init(navigator: navigator, viewController: welcomeVC, dataSource: dataSource)
    self.refreshBlock = { dataSource, animated in
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
    let navigator = BasicNavigator(parent: self.navigator)
    let coordinator = UpdateUserCoordinator(navigator: navigator, dataManager: dataManager, user: user)
    coordinator.addCloseButton() { [weak self] child in
      self?.dismiss(child, animated: true)
    }
    present(coordinator, from: navigator, animated: true, modalPresentationStyle: .safeAutomatic)
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
