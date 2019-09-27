//
//  WelcomeCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import PromiseKit
import Minerva

protocol WelcomeCoordinatorDelegate: AnyObject {
  func onboardingCoordinator(
    _ onboardingCoordinator: WelcomeCoordinator,
    activated dataManager: DataManager)
}

/// Manages the user flows for logging in and creating new accounts
final class WelcomeCoordinator: PromiseCoordinator<WelcomeDataSource, CollectionViewController> {

  weak var delegate: WelcomeCoordinatorDelegate?
  private let userManager: UserManager

  // MARK: - Lifecycle

  init(navigator: Navigator, userManager: UserManager) {
    self.userManager = userManager

    let dataSource = WelcomeDataSource()
    let welcomeVC = CollectionViewController()
    super.init(navigator: navigator, viewController: welcomeVC, dataSource: dataSource)
    self.refreshBlock = { dataSource, animated in
      dataSource.reload(animated: animated)
    }
    dataSource.delegate = self
  }

  // MARK: - Private

  private func displaySignInVC(mode: SignInDataSource.Mode) {
    let coordinator = SignInCoordinator(navigator: navigator, userManager: userManager, mode: mode)
    coordinator.delegate = self
    push(coordinator, animated: true)
  }
}

extension WelcomeCoordinator: SignInCoordinatorDelegate {
  func signInCoordinator(_ signInCoordinator: SignInCoordinator, activated dataManager: DataManager) {
    delegate?.onboardingCoordinator(self, activated: dataManager)
  }
}

// MARK: - WelcomeDataSourceDelegate
extension WelcomeCoordinator: WelcomeDataSourceDelegate {
  func welcomeDataSource(_ welcomeDataSource: WelcomeDataSource, selected action: WelcomeDataSource.Action) {
    switch action {
    case .login: displaySignInVC(mode: .login)
    case .createAccount: displaySignInVC(mode: .createAccount)
    }
  }
}
