//
//  UserCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

protocol UserCoordinatorDelegate: class {
  func userCoordinatorLogoutCurrentUser(_ userCoordinator: UserCoordinator)
}

/// Manages the user flows when a user is logged in.
final class UserCoordinator: NSObject {

  weak var delegate: UserCoordinatorDelegate?

  private let userManager: UserManager
  private let dataManager: DataManager
  private let userVC: UserVC

  private lazy var settingsVC: CollectionViewController = {
    let dataSource = SettingsDataSource(dataManager: dataManager)
    dataSource.delegate = self
    let viewController = CollectionViewController(dataSource: dataSource)
    viewController.title = "Settings"
    viewController.hasLargeTitle = true
    return viewController
  }()
  private lazy var userListVC: UserListVC = {
    let dataSource = UserListDataSource(dataManager: dataManager)
    dataSource.delegate = self
    let viewController = UserListVC(dataSource: dataSource)
    viewController.delegate = self
    return viewController
  }()

  private var filterDataSource: FilterDataSource?
  private var filterViewController: CollectionViewController?
  private var workoutFilter: WorkoutFilter = WorkoutFilterProto(startDate: nil, endDate: nil, startTime: nil, endTime: nil)

  // MARK: - Lifecycle

  init(userManager: UserManager, dataManager: DataManager) {
    self.userManager = userManager
    self.dataManager = dataManager
    self.userVC = UserVC(userAuthorization: dataManager.userAuthorization)
    super.init()
    self.userVC.delegate = self
  }

  // MARK: - Public

  func launch(in window: UIWindow) {
    window.rootViewController = userVC
  }

  // MARK: - Private

  private func displayWorkoutPopup(with workout: Workout?, forUserID userID: String) {
    let editing = workout != nil
    let workout = workout ?? WorkoutProto(workoutID: UUID().uuidString, userID: userID, text: "", calories: 0, date: Date())
    let dataSource = WorkoutActionSheetDataSource(workout: workout, editing: editing)
    dataSource.delegate = self
    let actionSheet = ActionSheetVC(dataSource: dataSource)
    display(actionSheet, from: userVC)
  }

  private func delete(workout: Workout) {
    LoadingHUD.show(in: userVC.view)
    dataManager.delete(workout: workout).done { [weak self] in
      guard let workoutVC = self?.workoutVC(forUserID: workout.userID) else {
        return
      }
      workoutVC.updateModels()
    }.catch { [weak self] error -> Void in
      UIAlertController.display(error, defaultTitle: "Failed to delete the workout", parentVC: self?.userVC)
    }.finally { [weak self] in
      LoadingHUD.hide(from: self?.userVC.view)
    }
  }

  private func displayFilterPopup(with filter: WorkoutFilter, type: FilterType) {
    let dataSource = FilterActionSheetDataSource(type: type, filter: filter)
    dataSource.delegate = self
    let actionSheet = ActionSheetVC(dataSource: dataSource)
    display(actionSheet, from: userVC)
  }

  private func displayFilterSelection(with filter: WorkoutFilter) {
    let dataSource = FilterDataSource(filter: filter)
    dataSource.delegate = self
    filterDataSource = dataSource
    let viewController = CollectionViewController(dataSource: dataSource)
    viewController.isTabBarHidden = true
    filterViewController = viewController
    userVC.navigationVC.pushViewController(viewController, animated: true)
  }

  private func deleteUser(withID userID: String) {
    LoadingHUD.show(in: userVC.view)
    let logoutCurrentUser = dataManager.userAuthorization.userID == userID
    userManager.delete(userID: userID).done { [weak self] () -> Void in
      guard let strongSelf = self else { return }
      strongSelf.userListVC.updateModels()
    }.catch { [weak self] error -> Void in
      UIAlertController.display(error, defaultTitle: "Failed to delete the user", parentVC: self?.userVC)
    }.finally { [weak self] in
      guard let strongSelf = self else { return }
      LoadingHUD.hide(from: strongSelf.userVC.view)
      if logoutCurrentUser {
        strongSelf.delegate?.userCoordinatorLogoutCurrentUser(strongSelf)
      }
    }
  }

  private func logoutUser(withID userID: String) {
    LoadingHUD.show(in: userVC.view)
    let logoutCurrentUser = dataManager.userAuthorization.userID == userID
    userManager.logout(userID: userID).done { [weak self] () -> Void in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.userCoordinatorLogoutCurrentUser(strongSelf)
    }.catch { [weak self] error -> Void in
      UIAlertController.display(error, defaultTitle: "Failed to logout", parentVC: self?.userVC)
    }.finally { [weak self] in
      guard let strongSelf = self else { return }
      LoadingHUD.hide(from: strongSelf.userVC.view)
      if logoutCurrentUser {
        strongSelf.delegate?.userCoordinatorLogoutCurrentUser(strongSelf)
      }
    }
  }

  private func displayUserUpdatePopup(for user: User) {
    let dataSource = UpdateUserActionSheetDataSource(user: user)
    dataSource.delegate = self
    let actionSheet = ActionSheetVC(dataSource: dataSource)
    display(actionSheet, from: userVC)
  }

  private func displayCreateUserPopup() {
    let dataSource = CreateUserActionSheetDataSource()
    dataSource.delegate = self
    let actionSheet = ActionSheetVC(dataSource: dataSource)
    display(actionSheet, from: userVC)
  }

  private func displayWorkoutList(forUserID userID: String, title: String?, replaceRootVC: Bool) {
    let dataSource = WorkoutDataSource(userID: userID, dataManager: dataManager)
    dataSource.delegate = self
    let viewController = WorkoutVC(userID: userID, dataSource: dataSource, filter: workoutFilter)
    viewController.isTabBarHidden = !replaceRootVC
    viewController.title = title
    viewController.delegate = self
    if replaceRootVC {
      userVC.navigationVC.setViewControllers([viewController], animated: false)
    } else {
      userVC.navigationVC.pushViewController(viewController, animated: true)
    }
  }

  private func displayUserList() {
    userVC.navigationVC.setViewControllers([userListVC], animated: false)
  }

  private func displaySettings() {
    userVC.navigationVC.setViewControllers([settingsVC], animated: false)
  }

  private func workoutVC(forUserID userID: String) -> WorkoutVC? {
    return userVC.navigationVC.viewControllers.compactMap { $0 as? WorkoutVC }.first { $0.userID == userID }
  }

  private func create(email: String, password: String, dailyCalories: Int32, role: UserRole) {
    LoadingHUD.show(in: userVC.view)
    dataManager.create(withEmail: email, password: password, dailyCalories: dailyCalories, role: role).done { [weak self] () -> Void in
      guard let strongSelf = self else { return }
      strongSelf.userListVC.updateModels()
      strongSelf.userVC.dismiss(animated: true, completion: nil)
    }.catch { [weak self] error -> Void in
      UIAlertController.display(error, defaultTitle: "Failed to save the user", parentVC: self?.userVC)
    }.finally { [weak self] in
      LoadingHUD.hide(from: self?.userVC.view)
    }
  }

  private func save(user: User) {
    LoadingHUD.show(in: userVC.view)
    dataManager.update(user: user).done { [weak self] () -> Void in
      guard let strongSelf = self else { return }
      strongSelf.userListVC.updateModels()
      strongSelf.settingsVC.loadModels(animated: true, completion: nil)
      strongSelf.userVC.dismiss(animated: true, completion: nil)
    }.catch { [weak self] error -> Void in
      UIAlertController.display(error, defaultTitle: "Failed to save the user", parentVC: self?.userVC)
    }.finally { [weak self] in
      LoadingHUD.hide(from: self?.userVC.view)
    }
  }

  private func save(workout: Workout) {
    LoadingHUD.show(in: userVC.view)
    dataManager.store(workout: workout).done { [weak self] () -> Void in
      guard let strongSelf = self else { return }
      guard let workoutVC = strongSelf.workoutVC(forUserID: workout.userID) else { return }
      workoutVC.updateModels()
      strongSelf.userVC.dismiss(animated: true, completion: nil)
    }.catch { [weak self] error -> Void in
      UIAlertController.display(error, defaultTitle: "Failed to store the workout", parentVC: self?.userVC)
    }.finally { [weak self] in
      LoadingHUD.hide(from: self?.userVC.view)
    }
  }

  private func display(_ actionSheetVC: ActionSheetVC, from viewController: UIViewController) {
    actionSheetVC.transitioningDelegate = self
    actionSheetVC.present(from: viewController)
  }

  private func apply(filter: WorkoutFilter) {
    workoutFilter = filter
    filterDataSource?.filter = filter
    filterViewController?.loadModels(animated: true, completion: nil)
    userVC.navigationVC.viewControllers.compactMap {
      $0 as? WorkoutVC
    }.forEach {
      $0.update(filter: filter)
    }
    userVC.dismiss(animated: true, completion: nil)
  }
}

// MARK: - CreateUserActionSheetDataSourceDelegate
extension UserCoordinator: CreateUserActionSheetDataSourceDelegate {
  func createUserActionSheetDataSource(_ createUserActionSheetDataSource: CreateUserActionSheetDataSource, selected action: CreateUserActionSheetDataSource.Action) {
    switch action {
    case .dismiss:
      userVC.dismiss(animated: true, completion: nil)
    case let .create(email, password, dailyCalories, role):
      create(email: email, password: password, dailyCalories: dailyCalories, role: role)
    }
  }
}

// MARK: - FilterActionSheetDataSourceDelegate
extension UserCoordinator: FilterActionSheetDataSourceDelegate {
  func filterActionSheetDataSource(
    _ filterActionSheetDataSource: FilterActionSheetDataSource,
    selected action: FilterActionSheetDataSource.Action
  ) {
    switch action {
    case .update(let filter):
      apply(filter: filter)
    }
  }
}

// MARK: - FilterDataSourceDelegate
extension UserCoordinator: FilterDataSourceDelegate {
  func filterDataSource(_ filterDataSource: FilterDataSource, selected action: FilterDataSource.Action) {
    switch action {
    case let .edit(filter, type):
      displayFilterPopup(with: filter, type: type)
    }
  }
}

// MARK: - WorkoutActionSheetDataSourceDelegate
extension UserCoordinator: WorkoutActionSheetDataSourceDelegate {
  func workoutActionSheetDataSource(_ workoutActionSheetDataSource: WorkoutActionSheetDataSource, selected action: WorkoutActionSheetDataSource.Action) {
    switch action {
    case .dismiss:
      userVC.dismiss(animated: true, completion: nil)
    case .save(let workout):
      save(workout: workout)
    }
  }
}

// MARK: - WorkoutDataSourceDelegate
extension UserCoordinator: WorkoutDataSourceDelegate {
  func workoutDataSource(_ workoutDataSource: WorkoutDataSource, selected action: WorkoutDataSource.Action) {
    switch action {
    case .delete(let workout):
      delete(workout: workout)
    case .edit(let workout):
      displayWorkoutPopup(with: workout, forUserID: workout.userID)
    }
  }
}

// MARK: - WorkoutVCDelegate
extension UserCoordinator: WorkoutVCDelegate {
  func workoutVC(_ workoutVC: WorkoutVC, selected action: WorkoutVC.Action) {
    switch action {
    case .createWorkout(let userID):
      displayWorkoutPopup(with: nil, forUserID: userID)
    case .update(let filter):
      displayFilterSelection(with: filter)
    }
  }
}

// MARK: - SettingsDataSourceDelegate
extension UserCoordinator: SettingsDataSourceDelegate {
  func settingsDataSource(_ settingsDataSource: SettingsDataSource, selected action: SettingsDataSource.Action) {
    let userID = dataManager.userAuthorization.userID
    switch action {
    case .deleteAccount:
      deleteUser(withID: userID)
    case .logout:
      logoutUser(withID: userID)
    case .update(let user):
      displayUserUpdatePopup(for: user)
    }
  }
}

// MARK: - UserVCDelegate
extension UserCoordinator: UserVCDelegate {
  func userVC(_ userVC: UserVC, selected tab: UserVC.Tab) {
    switch tab {
    case .workouts:
      displayWorkoutList(forUserID: dataManager.userAuthorization.userID, title: nil, replaceRootVC: true)
    case .users:
      displayUserList()
    case .settings:
      displaySettings()
    }
  }
}

// MARK: - UserListDataSourceDelegate
extension UserCoordinator: UserListDataSourceDelegate {
  func userListDataSource(_ userListDataSource: UserListDataSource, selected action: UserListDataSource.Action) {
    switch action {
    case .delete(let user):
      deleteUser(withID: user.userID)
    case .edit(let user):
      displayUserUpdatePopup(for: user)
    case .view(let user):
      displayWorkoutList(forUserID: user.userID, title: user.email, replaceRootVC: false)
    }
  }
}

// MARK: - UserListVCDelegate
extension UserCoordinator: UserListVCDelegate {
  func userListVC(_ userListVC: UserListVC, selected action: UserListVC.Action) {
    switch action {
    case .createUser:
      displayCreateUserPopup()
    }
  }
}

// MARK: - UpdateUserActionSheetDataSourceDelegate
extension UserCoordinator: UpdateUserActionSheetDataSourceDelegate {
  func updateUserActionSheetDataSource(
    _ updateUserActionSheetDataSource: UpdateUserActionSheetDataSource,
    selected action: UpdateUserActionSheetDataSource.Action
  ) {
    switch action {
    case .dismiss:
      userVC.dismiss(animated: true, completion: nil)
    case .save(let user):
      save(user: user)
    }
  }
}


// MARK: - UIViewControllerTransitioningDelegate
extension UserCoordinator: UIViewControllerTransitioningDelegate {
  public func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController,
    source: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    let transition = ActionSheetPresentAnimator()
    return transition
  }
  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    let transition = ActionSheetDismissAnimator()
    return transition
  }
}
