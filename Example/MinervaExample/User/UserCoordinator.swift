//
//  UserCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva

protocol UserCoordinatorDelegate: AnyObject {
  func userCoordinatorLogoutCurrentUser(_ userCoordinator: UserCoordinator)
}

/// Manages the user flows when a user is logged in.
final class UserCoordinator: NSObject, CoordinatorNavigator {

  weak var delegate: UserCoordinatorDelegate?

  private let userManager: UserManager
  private let dataManager: DataManager
  public var userVC: UserVC

  private var filterDataSource: FilterDataSource?
  private var filterViewController: CollectionViewController?
  private var workoutFilter: WorkoutFilter = WorkoutFilterProto(startDate: nil, endDate: nil, startTime: nil, endTime: nil)

  // MARK: - CoordinatorNavigator
  public var parent: Coordinator?
  public var childCoordinators = [Coordinator]()
  public let navigator: Navigator

  // MARK: - Lifecycle

  init(userManager: UserManager, dataManager: DataManager) {
    self.userManager = userManager
    self.dataManager = dataManager
    let navigator = BasicNavigator()
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
  func settingsCoordinatorLogoutCurrentUser(_ settingsCoordinator: SettingsCoordinator) {
    delegate?.userCoordinatorLogoutCurrentUser(self)
  }
}

// MARK: - UserListCoordinatorDelegate
extension UserCoordinator: UserListCoordinatorDelegate {
  func userListCoordinatorLogoutCurrentUser(_ userListCoordinator: UserListCoordinator) {
    delegate?.userCoordinatorLogoutCurrentUser(self)
  }
}

// MARK: - UserVCDelegate
extension UserCoordinator: UserVCDelegate {
  func userVC(_ userVC: UserVC, selected tab: UserVC.Tab) {
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

// MARK: - UIViewControllerTransitioningDelegate
extension UserCoordinator: UIViewControllerTransitioningDelegate {
  public func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController,
    source: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    let transition = ActionSheetPresentAnimator()
    return transition
  }
  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    let transition = ActionSheetDismissAnimator()
    return transition
  }
}
