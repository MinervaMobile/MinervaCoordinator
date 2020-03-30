//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import UIKit

/// Manages user and workout information.
public protocol DataManager {
  typealias SubscriptionID = String
  typealias ImageCompletion = (UIImage?, Error?) -> Void
  typealias WorkoutsCompletion = ([Workout], Error?) -> Void
  typealias UsersCompletion = ([User], Error?) -> Void
  typealias UserCompletion = (User?, Error?) -> Void
  typealias Completion = (Error?) -> Void

  // MARK: - Account

  /// The users authentication
  var userAuthorization: UserAuthorization { get }

  // MARK: - Users

  /// Obtains a list of all the users if the current user is authorized.
  func loadUsers(completion: @escaping UsersCompletion)

  /// Loads the user with the specified ID.
  func loadUser(withID userID: String, completion: @escaping UserCompletion)

  /// Stores the users information, overwriting the previous value
  func update(user: User, completion: @escaping Completion)

  /// Deletes the user with the specified ID
  func delete(userID: String, completion: @escaping Completion)

  /// Creates a new user with the specified information
  func create(
    withEmail email: String,
    password: String,
    dailyCalories: Int32,
    role: UserRole,
    completion: @escaping Completion
  )

  // MARK: - Workouts

  /// Loads all the workouts for the specified user.
  func loadWorkouts(forUserID userID: String, completion: @escaping WorkoutsCompletion)

  /// Saves a workout and overwrites any that exist with the same ID.
  func store(workout: Workout, completion: @escaping Completion)

  /// Deletes a workout with a matching ID if one exists.
  func delete(workout: Workout, completion: @escaping Completion)

  func loadImage(forWorkoutID workoutID: String, completion: @escaping ImageCompletion)

  func subscribeToWorkoutChanges(
    for userID: String,
    callback: @escaping WorkoutsCompletion
  ) -> SubscriptionID

  func subscribeToUserChanges(
    callback: @escaping UsersCompletion
  ) -> SubscriptionID

  func unsubscribe(listenerID: SubscriptionID)
}
