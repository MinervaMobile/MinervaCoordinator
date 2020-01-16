//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import UIKit

public protocol UserCoordinatorDelegate: AnyObject {
  func userCoordinatorLogoutCurrentUser(_ userCoordinator: UserCoordinator)
}

/// Manages the user flows when a user is logged in.
public final class UserCoordinator: NSObject, CoordinatorNavigator {

  public weak var delegate: UserCoordinatorDelegate?

  private let userManager: UserManager
  private let dataManager: DataManager
  public var userVC: UserVC

  private var filterPresenter: FilterPresenter?
  private var filterViewController: CollectionViewController?
  private var workoutFilter: WorkoutFilter = WorkoutFilterProto(startDate: nil, endDate: nil, startTime: nil, endTime: nil)

  // MARK: - CoordinatorNavigator
  public var parent: Coordinator?
  public var childCoordinators = [Coordinator]()
  public let navigator: Navigator

  // MARK: - Lifecycle

  public init(userManager: UserManager, dataManager: DataManager) {
    self.userManager = userManager
    self.dataManager = dataManager
    let navigator = BasicNavigator(parent: nil)
    self.navigator = navigator
    self.userVC = UserVC(
      userAuthorization: dataManager.userAuthorization,
      navigationController: navigator.navigationController)
    super.init()
    self.userVC.delegate = self
    displayWorkoutList()
  }

  // MARK: - Private

  private func displayWorkoutList() {
    let coordinator = WorkoutCoordinator(
      navigator: navigator,
      dataManager: dataManager,
      userID: dataManager.userAuthorization.userID)
    setRootCoordinator(coordinator, animated: false)
  }

  private func displayUserList() {
    let coordinator = UserListCoordinator(navigator: navigator, userManager: userManager, dataManager: dataManager)
    coordinator.delegate = self
    setRootCoordinator(coordinator, animated: false)
  }

  private func displaySettings() {
    let coordinator = SettingsCoordinator(navigator: navigator, userManager: userManager, dataManager: dataManager)
    coordinator.delegate = self
    setRootCoordinator(coordinator, animated: false)
  }

}

// MARK: - SettingsCoordinatorDelegate
extension UserCoordinator: SettingsCoordinatorDelegate {
  public func settingsCoordinatorLogoutCurrentUser(_ settingsCoordinator: SettingsCoordinator) {
    delegate?.userCoordinatorLogoutCurrentUser(self)
  }
}

// MARK: - UserListCoordinatorDelegate
extension UserCoordinator: UserListCoordinatorDelegate {
  public func userListCoordinatorLogoutCurrentUser(_ userListCoordinator: UserListCoordinator) {
    delegate?.userCoordinatorLogoutCurrentUser(self)
  }
}

// MARK: - UserVCDelegate
extension UserCoordinator: UserVCDelegate {
  public func userVC(_ userVC: UserVC, selected tab: UserVC.Tab) {
    switch tab {
    case .workouts:
      displayWorkoutList()
    case .users:
      displayUserList()
    case .settings:
      displaySettings()
    }
  }
}
