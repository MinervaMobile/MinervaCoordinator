//
//  LifecycleCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

/// Responsible for launching, and transitioning between, the onboarding and active user flows.
final class LifecycleCoordinator {
  private let window: UIWindow
  private let userManager: UserManager
  private var onboardingCoordinator: OnboardingCoordinator?
  private var userCoordinator: UserCoordinator?

  // MARK: - Lifecycle

  init(window: UIWindow, userManager: UserManager) {
    self.window = window
    self.userManager = userManager
  }

  // MARK: - Public

  func launch() {
    guard let dataManager = userManager.activateCachedUser() else {
      launchOnboardingCoordinator()
      return
    }
    launchUserCoordinator(with: dataManager)
  }

  // MARK: - Private

  private func launchOnboardingCoordinator() {
    let onboardingCoordinator = OnboardingCoordinator(userManager: userManager)
    onboardingCoordinator.delegate = self
    onboardingCoordinator.launch(in: window)
    self.onboardingCoordinator = onboardingCoordinator
    userCoordinator = nil
  }

  private func launchUserCoordinator(with dataManager: DataManager) {
    let userCoordinator = UserCoordinator(userManager: userManager, dataManager: dataManager)
    userCoordinator.delegate = self
    userCoordinator.launch(in: window)
    self.userCoordinator = userCoordinator
    onboardingCoordinator = nil
  }
}

// MARK: - OnboardingCoordinatorDelegate
extension LifecycleCoordinator: OnboardingCoordinatorDelegate {
  func onboardingCoordinator(
    _ onboardingCoordinator: OnboardingCoordinator,
    activated dataManager: DataManager
  ) {
    launchUserCoordinator(with: dataManager)
  }
}

// MARK: - UserCoordinatorDelegate
extension LifecycleCoordinator: UserCoordinatorDelegate {
  func userCoordinatorLogoutCurrentUser(_ userCoordinator: UserCoordinator) {
    launchOnboardingCoordinator()
  }
}
