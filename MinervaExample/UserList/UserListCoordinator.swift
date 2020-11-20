//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxSwift
import UIKit

public protocol UserListCoordinatorDelegate: AnyObject {
  func userListCoordinatorLogoutCurrentUser(
    _ userListCoordinator: UserListCoordinator
  )
}

public final class UserListCoordinator: MainCoordinator<UserListPresenter, UserListVC> {

  public weak var delegate: UserListCoordinatorDelegate?
  private let userManager: UserManager
  private let dataManager: DataManager

  // MARK: - Lifecycle

  public init(navigator: Navigator, userManager: UserManager, dataManager: DataManager) {
    self.userManager = userManager
    self.dataManager = dataManager

    let repository = UserListRepository(dataManager: dataManager)
    let presenter = UserListPresenter(repository: repository)
    let viewController = UserListVC()
    let listController = LegacyListController()
    super
      .init(
        navigator: navigator,
        viewController: viewController,
        presenter: presenter,
        listController: listController
      )
    viewController.events
      .subscribe(onNext: { [weak self] event in
        self?.handle(event)
      })
      .disposed(by: disposeBag)
  }

  // MARK: - Private

  private func handle(_ event: ListViewControllerEvent) {
    guard case .viewDidLoad = event else { return }

    presenter.state
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: handle(_:))
      .disposed(by: disposeBag)

    presenter.actions
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: handle(_:))
      .disposed(by: disposeBag)

    viewController.actions
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: handle(_:))
      .disposed(by: disposeBag)
  }

  private func handle(_ state: UserListPresenter.State) {
    switch state {
    case .failure(let error):
      LoadingHUD.hide(from: viewController.view)
      viewController.alert(error, title: "Failed to load")
    case .loaded:
      LoadingHUD.hide(from: viewController.view)
    case .loading:
      LoadingHUD.show(in: viewController.view)
    }
  }

  private func handle(_ action: UserListPresenter.Action) {
    switch action {
    case .delete(let user):
      deleteUser(withID: user.userID)
    case .edit(let user):
      displayUserUpdatePopup(for: user)
    case .view(let user):
      displayWorkoutList(forUserID: user.userID, title: user.email)
    }
  }

  private func handle(_ action: UserListVC.Action) {
    switch action {
    case .createUser:
      displayCreateUserPopup()
    }
  }

  private func deleteUser(withID userID: String) {
    LoadingHUD.show(in: viewController.view)
    let logoutCurrentUser = dataManager.userAuthorization.userID == userID
    dataManager.deleteUser(withUserID: userID)
      .observeOn(MainScheduler.instance)
      .subscribe(
        onSuccess: { [weak self] in
          guard let strongSelf = self else { return }
          LoadingHUD.hide(from: strongSelf.viewController.view)
          guard logoutCurrentUser else { return }
          strongSelf.delegate?.userListCoordinatorLogoutCurrentUser(strongSelf)
        },
        onError: { [weak self] error -> Void in
          guard let strongSelf = self else { return }
          LoadingHUD.hide(from: strongSelf.viewController.view)
          strongSelf.viewController.alert(error, title: "Failed to delete the user")
        }
      )
      .disposed(by: disposeBag)
  }

  private func logoutUser(withID userID: String) {
    LoadingHUD.show(in: viewController.view)
    let logoutCurrentUser = dataManager.userAuthorization.userID == userID
    userManager.logout(userID: userID)
      .observeOn(MainScheduler.instance)
      .subscribe(
        onSuccess: { [weak self] in
          guard let strongSelf = self else { return }
          LoadingHUD.hide(from: strongSelf.viewController.view)
          guard logoutCurrentUser else { return }
          strongSelf.delegate?.userListCoordinatorLogoutCurrentUser(strongSelf)
        },
        onError: { [weak self] error -> Void in
          guard let strongSelf = self else { return }
          LoadingHUD.hide(from: strongSelf.viewController.view)
          strongSelf.viewController.alert(error, title: "Failed to logout")
        }
      )
      .disposed(by: disposeBag)
  }

  private func displayCreateUserPopup() {
    let navigator = BasicNavigator(parent: self.navigator)
    let coordinator = CreateUserCoordinator(navigator: navigator, dataManager: dataManager)
    presentWithCloseButton(coordinator, modalPresentationStyle: .safeAutomatic)
  }

  private func displayUserUpdatePopup(for user: User) {
    let coordinator = UpdateUserCoordinator(
      navigator: navigator,
      dataManager: dataManager,
      user: user
    )

    presentPanModal(coordinator)
  }

  private func save(user: User) {
    LoadingHUD.show(in: viewController.view)
    dataManager.update(user)
      .observeOn(MainScheduler.instance)
      .subscribe(
        onSuccess: { [weak self] in
          guard let strongSelf = self else { return }
          LoadingHUD.hide(from: strongSelf.viewController.view)
        },
        onError: { [weak self] error -> Void in
          guard let strongSelf = self else { return }
          LoadingHUD.hide(from: strongSelf.viewController.view)
          strongSelf.viewController.alert(error, title: "Failed to save the user")
        }
      )
      .disposed(by: disposeBag)
  }

  private func displayWorkoutList(forUserID userID: String, title: String) {
    let navigator = BasicNavigator(parent: self.navigator)
    let coordinator = WorkoutSplitCoordinator(
      navigator: navigator,
      dataManager: dataManager,
      userID: userID
    )

    coordinator.viewController.title = title
    coordinator.masterCoordinator.addCloseButton { [weak self, weak coordinator] _ in
      guard let coordinator = coordinator else { return }
      self?.dismiss(coordinator)
    }
    present(
      coordinator,
      modalPresentationStyle: .fullScreen,
      animated: true,
      animationCompletion: nil
    )
  }
}
