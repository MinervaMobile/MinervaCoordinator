//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxSwift
import UIKit

public protocol SignInCoordinatorDelegate: AnyObject {
  func signInCoordinator(
    _ signInCoordinator: SignInCoordinator,
    activated dataManager: DataManager
  )
}

public final class SignInCoordinator: MainCoordinator<SignInPresenter, CollectionViewController> {

  public weak var delegate: SignInCoordinatorDelegate?
  private let userManager: UserManager

  // MARK: - Lifecycle

  public init(navigator: Navigator, userManager: UserManager, mode: SignInPresenter.Mode) {
    self.userManager = userManager

    let presenter = SignInPresenter(mode: mode)
    let viewController = CollectionViewController()
    let listController = LegacyListController()
    super
      .init(
        navigator: navigator,
        viewController: viewController,
        presenter: presenter,
        listController: listController
      )
    presenter.actions
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] in self?.handle($0) })
      .disposed(
        by: disposeBag
      )
  }

  // MARK: - Private

  private func createAccount(withEmail email: String, password: String) {
    LoadingHUD.show(in: viewController.view)
    userManager.createAccount(withEmail: email, password: password)
      .observeOn(MainScheduler.instance)
      .subscribe(
        onSuccess: { [weak self] dataManager in
          guard let strongSelf = self else { return }
          LoadingHUD.hide(from: strongSelf.viewController.view)
          strongSelf.delegate?.signInCoordinator(strongSelf, activated: dataManager)
        },
        onError: { [weak self] error -> Void in
          guard let strongSelf = self else { return }
          LoadingHUD.hide(from: strongSelf.viewController.view)
          strongSelf.viewController.alert(
            error,
            title: "Failed to create the account."
          )
        }
      )
      .disposed(by: disposeBag)
  }

  private func login(withEmail email: String, password: String) {
    LoadingHUD.show(in: viewController.view)
    userManager.login(withEmail: email, password: password)
      .observeOn(MainScheduler.instance)
      .subscribe(
        onSuccess: { [weak self] dataManager in
          guard let strongSelf = self else { return }
          LoadingHUD.hide(from: strongSelf.viewController.view)
          strongSelf.delegate?.signInCoordinator(strongSelf, activated: dataManager)
        },
        onError: { [weak self] error -> Void in
          guard let strongSelf = self else { return }
          LoadingHUD.hide(from: strongSelf.viewController.view)
          strongSelf.viewController.alert(
            error,
            title: "Failed to login to the account."
          )
        }
      )
      .disposed(by: disposeBag)
  }
  private func handle(_ action: SignInPresenter.Action) {
    switch action {
    case let .signIn(email, password, mode):
      switch mode {
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
