//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import UIKit

/// Responsible for launching, and transitioning between, the onboarding and active user flows.
public final class LifecycleCoordinator {
  private let window: UIWindow
  private let userManager: UserManager

  // MARK: - Coordinator
  public var activeCoordinator: Coordinator?

  // MARK: - Lifecycle

  public init(window: UIWindow, userManager: UserManager) {
    self.window = window
    self.userManager = userManager
  }

  // MARK: - Public

  public func launch() {
    guard let dataManager = userManager.activateCachedUser() else {
      launchWelcomeCoordinator(animated: false)
      return
    }
    launchUserCoordinator(with: dataManager, animated: true)
  }

  // MARK: - Private

  private func launchWelcomeCoordinator(animated: Bool) {
    let navigator = BasicNavigator(parent: nil)
    let onboardingCoordinator = WelcomeCoordinator(navigator: navigator, userManager: userManager)
    navigator.setViewControllers([onboardingCoordinator.viewController], animated: animated, completion: nil)
    onboardingCoordinator.delegate = self
    window.rootViewController = navigator.navigationController
    activeCoordinator = onboardingCoordinator
  }

  private func launchUserCoordinator(with dataManager: DataManager, animated: Bool) {
    let userCoordinator = UserCoordinator(userManager: userManager, dataManager: dataManager)
    userCoordinator.delegate = self
    window.rootViewController = userCoordinator.userVC
    activeCoordinator = userCoordinator
  }
}

// MARK: - WelcomeCoordinatorDelegate
extension LifecycleCoordinator: WelcomeCoordinatorDelegate {
  public func onboardingCoordinator(
    _ onboardingCoordinator: WelcomeCoordinator,
    activated dataManager: DataManager
  ) {
    launchUserCoordinator(with: dataManager, animated: true)
  }
}

// MARK: - UserCoordinatorDelegate
extension LifecycleCoordinator: UserCoordinatorDelegate {
  public func userCoordinatorLogoutCurrentUser(_ userCoordinator: UserCoordinator) {
    launchWelcomeCoordinator(animated: true)
  }
}
