//
//  DataManager.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation

import PromiseKit

/// Manages user and workout information.
protocol DataManager {

  // MARK: - Account

  /// The users authentication
  var userAuthorization: UserAuthorization { get }

  // MARK: - Users

  /// Obtains a list of all the users if the current user is authorized.
  func loadUsers() -> Promise<[User]>

  /// Loads the user with the specified ID.
  func loadUser(withID userID: String) -> Promise<User?>

  /// Stores the users information, overwriting the previous value
  func update(user: User) -> Promise<Void>

  /// Creates a new user with the specified information
  func create(
    withEmail email: String,
    password: String,
    dailyCalories: Int32,
    role: UserRole
  ) -> Promise<Void>

  // MARK: - Workouts

  /// Loads all the workouts for the specified user.
  func loadWorkouts(forUserID userID: String) -> Promise<[Workout]>

  /// Saves a workout and overwrites any that exist with the same ID.
  func store(workout: Workout) -> Promise<Void>

  /// Deletes a workout with a matching ID if one exists.
  func delete(workout: Workout) -> Promise<Void>
}
