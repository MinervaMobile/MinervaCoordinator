//
//  OnboardingCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import PromiseKit

protocol OnboardingCoordinatorDelegate: AnyObject {
  func onboardingCoordinator(
    _ onboardingCoordinator: OnboardingCoordinator,
    activated dataManager: DataManager)
}

/// Manages the user flows for logging in and creating new accounts
final class OnboardingCoordinator {

  weak var delegate: OnboardingCoordinatorDelegate?

  private let navigationController: UINavigationController = {
    let navigationController = UINavigationController(nibName: nil, bundle: nil)
    navigationController.navigationBar.tintColor = .black
    return navigationController
  }()
  private let userManager: UserManager

  // MARK: - Lifecycle

  init(userManager: UserManager) {
    self.userManager = userManager
  }

  // MARK: - Public

  func launch(in window: UIWindow) {
    let dataSource = WelcomeDataSource()
    dataSource.delegate = self
    let welcomeVC = CollectionViewController(dataSource: dataSource)
    welcomeVC.isNavigationBarHidden = true
    navigationController.setViewControllers([welcomeVC], animated: false)
    window.rootViewController = navigationController
  }

  // MARK: - Private

  private func displaySignInVC(mode: SignInDataSource.Mode) {
    let dataSource = SignInDataSource(mode: mode)
    dataSource.delegate = self
    let viewController = CollectionViewController(dataSource: dataSource)
    viewController.isNavigationBarHidden = false
    navigationController.pushViewController(viewController, animated: true)
  }

  private func createAccount(withEmail email: String, password: String) {
    LoadingHUD.show(in: navigationController.topViewController?.view)
    userManager.createAccount(withEmail: email, password: password).done { [weak self] dataManager in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.onboardingCoordinator(strongSelf, activated: dataManager)
    }.catch { [weak self] error -> Void in
      UIAlertController.display(
        error,
        defaultTitle: "Failed to create the account.",
        parentVC: self?.navigationController)
    }.finally { [weak self] in
      LoadingHUD.hide(from: self?.navigationController.topViewController?.view)
    }
  }

  private func login(withEmail email: String, password: String) {
    LoadingHUD.show(in: navigationController.topViewController?.view)
    userManager.login(withEmail: email, password: password).done { [weak self] dataManager in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.onboardingCoordinator(strongSelf, activated: dataManager)
    }.catch { [weak self] error -> Void in
      UIAlertController.display(
        error,
        defaultTitle: "Failed to login to the account.",
        parentVC: self?.navigationController)
    }.finally { [weak self] in
      LoadingHUD.hide(from: self?.navigationController.topViewController?.view)
    }
  }
}

// MARK: - SignInDataSourceDelegate
extension OnboardingCoordinator: SignInDataSourceDelegate {
  func signInDataSource(_ signInDataSource: SignInDataSource, selected action: SignInDataSource.Action) {
    switch action {
    case let .signIn(email, password):
      switch signInDataSource.mode {
      case .createAccount:
        createAccount(withEmail: email, password: password)
      case .login:
        login(withEmail: email, password: password)
      }
    case .invalidInput:
      UIAlertController.display(title: "Error", message: "Missing email or passworrd", parentVC: navigationController)
    }
  }
}

// MARK: - WelcomeDataSourceDelegate
extension OnboardingCoordinator: WelcomeDataSourceDelegate {
  func welcomeDataSource(_ welcomeDataSource: WelcomeDataSource, selected action: WelcomeDataSource.Action) {
    switch action {
    case .login: displaySignInVC(mode: .login)
    case .createAccount: displaySignInVC(mode: .createAccount)
    }
  }
}
