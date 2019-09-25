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
    self.userVC = UserVC(userAuthorization: dataManager.userAuthorization)
    self.navigator = BasicNavigator()
    super.init()
    self.userVC.delegate = self
  }

  // MARK: - Private

  private func displayWorkoutList() {
    fatalError("Implement Me")
  }

  private func displayUserList() {
    fatalError("Implement Me")
  }

  private func displaySettings() {
    fatalError("Implement Me")
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
