//
//  UserListCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import PromiseKit
import Minerva

protocol UserListCoordinatorDelegate: AnyObject {
  func userListCoordinatorLogoutCurrentUser(
    _ userListCoordinator: UserListCoordinator
  )
}

final class UserListCoordinator: MainCoordinator<UserListDataSource, UserListVC> {

  weak var delegate: UserListCoordinatorDelegate?
  private let userManager: UserManager
  private let dataManager: DataManager

  // MARK: - Lifecycle

  init(navigator: Navigator, userManager: UserManager, dataManager: DataManager) {
    self.userManager = userManager
    self.dataManager = dataManager

    let dataSource = UserListDataSource(dataManager: dataManager)
    let welcomeVC = UserListVC()
    super.init(navigator: navigator, viewController: welcomeVC, dataSource: dataSource) { dataSource, animated in
      dataSource.reload(animated: animated)
    }
    dataSource.delegate = self
  }

  // MARK: - Private

  private func deleteUser(withID userID: String) {
    LoadingHUD.show(in: viewController.view)
    let logoutCurrentUser = dataManager.userAuthorization.userID == userID
    userManager.delete(userID: userID).done { [weak self] () -> Void in
      guard let strongSelf = self else { return }
      strongSelf.dataSource.reload(animated: true)
    }.catch { [weak self] error -> Void in
      self?.viewController.alert(error, title: "Failed to delete the user")
    }.finally { [weak self] in
      guard let strongSelf = self else { return }
      LoadingHUD.hide(from: strongSelf.viewController.view)
      if logoutCurrentUser {
        strongSelf.delegate?.userListCoordinatorLogoutCurrentUser(strongSelf)
      }
    }
  }

  private func logoutUser(withID userID: String) {
    LoadingHUD.show(in: viewController.view)
    let logoutCurrentUser = dataManager.userAuthorization.userID == userID
    userManager.logout(userID: userID).catch { [weak self] error -> Void in
      self?.viewController.alert(error, title: "Failed to logout")
    }.finally { [weak self] in
      guard let strongSelf = self else { return }
      LoadingHUD.hide(from: strongSelf.viewController.view)
      if logoutCurrentUser {
        strongSelf.delegate?.userListCoordinatorLogoutCurrentUser(strongSelf)
      }
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
    dataManager.update(user: user).done { [weak self] () -> Void in
      guard let strongSelf = self else { return }
      strongSelf.dataSource.reload(animated: true)
    }.catch { [weak self] error -> Void in
      self?.viewController.alert(error, title: "Failed to save the user")
    }.finally { [weak self] in
      LoadingHUD.hide(from: self?.viewController.view)
    }
  }

  private func create(email: String, password: String, dailyCalories: Int32, role: UserRole) {
    LoadingHUD.show(in: viewController.view)
    dataManager.create(withEmail: email, password: password, dailyCalories: dailyCalories, role: role).done { [weak self] () -> Void in
      guard let strongSelf = self else { return }
      strongSelf.dataSource.reload(animated: true)
      strongSelf.viewController.dismiss(animated: true, completion: nil)
    }.catch { [weak self] error -> Void in
      self?.viewController.alert(error, title: "Failed to save the user")
    }.finally { [weak self] in
      LoadingHUD.hide(from: self?.viewController.view)
    }
  }

  private func displayWorkoutList(forUserID userID: String, title: String) {
//    let dataSource = WorkoutDataSource(userID: userID, dataManager: dataManager)
//    dataSource.delegate = self
//    let viewController = WorkoutVC(userID: userID, dataSource: dataSource, filter: workoutFilter)
//    viewController.title = title
//    push(coordinator, animated: true)
    fatalError("Implement Me")
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

// MARK: - UserListDataSourceDelegate
extension UserListCoordinator: UserListDataSourceDelegate {
  func userListDataSource(_ userListDataSource: UserListDataSource, selected action: UserListDataSource.Action) {
    switch action {
    case .delete(let user):
      deleteUser(withID: user.userID)
    case .edit(let user):
      displayUserUpdatePopup(for: user)
    case .view(let user):
      displayWorkoutList(forUserID: user.userID, title: user.email)
    }
  }
}

// MARK: - UserListVCDelegate
extension UserListCoordinator: UserListVCDelegate {
  func userListVC(_ userListVC: UserListVC, selected action: UserListVC.Action) {
    switch action {
    case .createUser:
      displayCreateUserPopup()
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
