//
//  DataManager+Promise.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation

import PromiseKit

extension DataManager {
  func loadUsers() -> Promise<[User]> {
    return Promise { seal in
      self.loadUsers(completion: seal.resolve)
    }
  }

  func loadUser(withID userID: String) -> Promise<User?> {
    return Promise { seal in
      self.loadUser(withID: userID, completion: seal.resolve)
    }
  }

  func update(user: User) -> Promise<Void> {
    return Promise { seal in
      self.update(user: user) { seal.resolve((), $0) }
    }
  }

  func delete(userID: String) -> Promise<Void> {
    return Promise { seal in
      self.delete(userID: userID) { seal.resolve((), $0) }
    }
  }

  func create(
    withEmail email: String,
    password: String,
    dailyCalories: Int32,
    role: UserRole
  ) -> Promise<Void> {
    return Promise { seal in
      self.create(withEmail: email, password: password, dailyCalories: dailyCalories, role: role) { seal.resolve((), $0) }
    }
  }

  func loadWorkouts(forUserID userID: String) -> Promise<[Workout]> {
    return Promise { seal in
      self.loadWorkouts(forUserID: userID, completion: seal.resolve)
    }
  }

  func store(workout: Workout) -> Promise<Void> {
    return Promise { seal in
      self.store(workout: workout) { seal.resolve((), $0) }
    }
  }

  func delete(workout: Workout) -> Promise<Void> {
    return Promise { seal in
      self.delete(workout: workout) { seal.resolve((), $0) }
    }
  }

  func loadImage(forWorkoutID workoutID: String) -> Promise<UIImage?> {
    return Promise { seal in
      self.loadImage(forWorkoutID: workoutID, completion: seal.resolve)
    }
  }
}
