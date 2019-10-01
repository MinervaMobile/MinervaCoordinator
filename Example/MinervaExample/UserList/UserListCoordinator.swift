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
    let dataSource = CreateUserActionSheetDataSource()
    dataSource.delegate = self
    let actionSheetVC = ActionSheetVC(dataSource: dataSource)
    actionSheetVC.transitioningDelegate = self
    actionSheetVC.present(from: viewController)
  }

  private func displayUserUpdatePopup(for user: User) {
    let dataSource = UpdateUserActionSheetDataSource(user: user)
    dataSource.delegate = self
    let actionSheetVC = ActionSheetVC(dataSource: dataSource)
    actionSheetVC.transitioningDelegate = self
    actionSheetVC.present(from: viewController)
  }

  private func save(user: User) {
    LoadingHUD.show(in: viewController.view)
    dataManager.update(user: user).catch { [weak self] error -> Void in
      self?.viewController.alert(error, title: "Failed to save the user")
    }.finally { [weak self] in
      LoadingHUD.hide(from: self?.viewController.view)
    }
  }

  private func create(email: String, password: String, dailyCalories: Int32, role: UserRole) {
    LoadingHUD.show(in: viewController.view)
    dataManager.create(withEmail: email, password: password, dailyCalories: dailyCalories, role: role).done { [weak self] () -> Void in
      guard let strongSelf = self else { return }
      strongSelf.viewController.dismiss(animated: true, completion: nil)
    }.catch { [weak self] error -> Void in
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

// MARK: - CreateUserActionSheetDataSourceDelegate
extension UserListCoordinator: CreateUserActionSheetDataSourceDelegate {
  func createUserActionSheetDataSource(
    _ createUserActionSheetDataSource: CreateUserActionSheetDataSource,
    selected action: CreateUserActionSheetDataSource.Action
  ) {
    switch action {
    case .dismiss:
      viewController.dismiss(animated: true, completion: nil)
    case let .create(email, password, dailyCalories, role):
      create(email: email, password: password, dailyCalories: dailyCalories, role: role)
    }
  }
}

// MARK: - UpdateUserActionSheetDataSourceDelegate
extension UserListCoordinator: UpdateUserActionSheetDataSourceDelegate {
  func updateUserActionSheetDataSource(
    _ updateUserActionSheetDataSource: UpdateUserActionSheetDataSource,
    selected action: UpdateUserActionSheetDataSource.Action
  ) {
    viewController.dismiss(animated: true, completion: nil)
    switch action {
    case .dismiss:
      break
    case .save(let user):
      save(user: user)
    }
  }
}
