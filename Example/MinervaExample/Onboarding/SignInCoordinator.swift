//
//  SignInCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva
import PromiseKit

protocol SignInCoordinatorDelegate: AnyObject {
  func signInCoordinator(
    _ signInCoordinator: SignInCoordinator,
    activated dataManager: DataManager
  )
}

final class SignInCoordinator: PromiseCoordinator<SignInDataSource, CollectionViewController> {

  weak var delegate: SignInCoordinatorDelegate?
  private let userManager: UserManager

  // MARK: - Lifecycle

  init(navigator: Navigator, userManager: UserManager, mode: SignInDataSource.Mode) {
    self.userManager = userManager

    let dataSource = SignInDataSource(mode: mode)
    let welcomeVC = CollectionViewController()
    super.init(navigator: navigator, viewController: welcomeVC, dataSource: dataSource)
    self.refreshBlock = { dataSource, animated in
      dataSource.reload(animated: animated)
    }
    dataSource.delegate = self
  }

  // MARK: - Private

  private func createAccount(withEmail email: String, password: String) {
    LoadingHUD.show(in: viewController.view)
    userManager.createAccount(withEmail: email, password: password).done { [weak self] dataManager in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.signInCoordinator(strongSelf, activated: dataManager)
    }.catch { [weak self] error -> Void in
      self?.viewController.alert(
        error,
        title: "Failed to create the account."
      )
    }.finally { [weak self] in
      LoadingHUD.hide(from: self?.viewController.view)
    }
  }

  private func login(withEmail email: String, password: String) {
    LoadingHUD.show(in: viewController.view)
    userManager.login(withEmail: email, password: password).done { [weak self] dataManager in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.signInCoordinator(strongSelf, activated: dataManager)
    }.catch { [weak self] error -> Void in
      self?.viewController.alert(
        error,
        title: "Failed to login to the account."
      )
    }.finally { [weak self] in
      LoadingHUD.hide(from: self?.viewController.view)
    }
  }
}

// MARK: - SignInDataSourceDelegate
extension SignInCoordinator: SignInDataSourceDelegate {
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
      viewController.alert(title: "Error", message: "Missing email or passworrd")
    }
  }
}
