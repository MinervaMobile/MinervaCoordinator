//
//  UserListCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva
import RxSwift

protocol UserListCoordinatorDelegate: AnyObject {
  func userListCoordinatorLogoutCurrentUser(
    _ userListCoordinator: UserListCoordinator
  )
}

final class UserListCoordinator: MainCoordinator<UserListPresenter, UserListVC> {

  weak var delegate: UserListCoordinatorDelegate?
  private let userManager: UserManager
  private let dataManager: DataManager
  private let disposeBag: DisposeBag

  // MARK: - Lifecycle

  init(navigator: Navigator, userManager: UserManager, dataManager: DataManager) {
    self.userManager = userManager
    self.dataManager = dataManager
    self.disposeBag = DisposeBag()

    let repository = UserListRepository(dataManager: dataManager)
    let presenter = UserListPresenter(repository: repository)
    let viewController = UserListVC()
    super.init(navigator: navigator, viewController: viewController, dataSource: presenter)
  }

  // MARK: - ViewControllerDelegate
  override public func viewControllerViewDidLoad(_ viewController: ViewController) {
    super.viewControllerViewDidLoad(viewController)

    dataSource.sections.subscribe(
      onNext: { [weak self] state in self?.handle(state) },
      onError: nil,
      onCompleted: nil,
      onDisposed: nil
    ).disposed(by: disposeBag)

    dataSource.actions.subscribe(
      onNext: { [weak self] action in self?.handle(action) },
      onError: nil,
      onCompleted: nil,
      onDisposed: nil
    ).disposed(by: disposeBag)

    self.viewController.actions.subscribe(
      onNext: { [weak self] action in self?.handle(action) },
      onError: nil,
      onCompleted: nil,
      onDisposed: nil
    ).disposed(by: disposeBag)
  }

  // MARK: - Private

  private func handle(_ state: PresenterState) {
    switch state {
    case .failure(let error):
      LoadingHUD.hide(from: viewController.view)
      viewController.alert(error, title: "Failed to load")
    case .loaded(let sections):
      LoadingHUD.hide(from: viewController.view)
      listController.update(with: sections, animated: true, completion: nil)
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
    dataManager.delete(userID: userID).done { [weak self] in
      guard let strongSelf = self else { return }
      guard logoutCurrentUser else { return }
      strongSelf.delegate?.userListCoordinatorLogoutCurrentUser(strongSelf)
    }.catch { [weak self] error -> Void in
      self?.viewController.alert(error, title: "Failed to delete the user")
    }.finally { [weak self] in
      LoadingHUD.hide(from: self?.viewController.view)
    }
  }

  private func logoutUser(withID userID: String) {
    LoadingHUD.show(in: viewController.view)
    let logoutCurrentUser = dataManager.userAuthorization.userID == userID
    userManager.logout(userID: userID).done { [weak self] in
      guard let strongSelf = self else { return }
      guard logoutCurrentUser else { return }
      strongSelf.delegate?.userListCoordinatorLogoutCurrentUser(strongSelf)
    }.catch { [weak self] error -> Void in
      self?.viewController.alert(error, title: "Failed to logout")
    }.finally { [weak self] in
      LoadingHUD.hide(from: self?.viewController.view)
    }
  }

  private func displayCreateUserPopup() {
    let navigator = BasicNavigator(parent: self.navigator)
    let coordinator = CreateUserCoordinator(navigator: navigator, dataManager: dataManager)
    coordinator.addCloseButton() { [weak self] child in
      self?.dismiss(child, animated: true)
    }
    present(coordinator, from: navigator, animated: true, modalPresentationStyle: .safeAutomatic)
  }

  private func displayUserUpdatePopup(for user: User) {
    let navigator = BasicNavigator(parent: self.navigator)
    let coordinator = UpdateUserCoordinator(navigator: navigator, dataManager: dataManager, user: user)
    coordinator.addCloseButton() { [weak self] child in
      self?.dismiss(child, animated: true)
    }
    present(coordinator, from: navigator, animated: true, modalPresentationStyle: .safeAutomatic)
  }

  private func save(user: User) {
    LoadingHUD.show(in: viewController.view)
    dataManager.update(user: user).catch { [weak self] error -> Void in
      self?.viewController.alert(error, title: "Failed to save the user")
    }.finally { [weak self] in
      LoadingHUD.hide(from: self?.viewController.view)
    }
  }

  private func displayWorkoutList(forUserID userID: String, title: String) {
    let coordinator = WorkoutCoordinator(
      navigator: navigator,
      dataManager: dataManager,
      userID: userID)
    coordinator.viewController.title = title
    push(coordinator, animated: true)
  }
}
