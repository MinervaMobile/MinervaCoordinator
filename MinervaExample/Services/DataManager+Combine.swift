//
//  DataManager+Combine.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Combine
import Foundation
import UIKit

extension DataManager {

  func combineUsers() -> Future<[User], Error> {
    return asSingle(loadUsers(completion:))
  }

  func combineUser(withID userID: String) -> Future<User?, Error> {
    let curried = curry(loadUser(withID: completion:))
    return asSingle(curried(userID))
  }

  func combineUpdate(_ user: User) -> Future<Void, Error> {
    let curried = curry(update(user: completion:))
    return asSingle(curried(user))
  }

  func combineDeleteUser(withUserID userID: String) -> Future<Void, Error> {
    let curried = curry(delete(userID: completion:))
    return asSingle(curried(userID))
  }

  func combineCreateUser(
    withEmail email: String,
    password: String,
    dailyCalories: Int32,
    role: UserRole
  ) -> Future<Void, Error> {
    return Future { promise in
      self.create(withEmail: email, password: password, dailyCalories: dailyCalories, role: role) { error in
        if let error = error {
          promise(.failure(error))
        } else {
          promise(.success(()))
        }
      }
    }
  }

  func combineWorkouts(forUserID userID: String) -> Future<[Workout], Error> {
    let curried = curry(loadWorkouts(forUserID: completion:))
    return asSingle(curried(userID))
  }

  func combineStore(_ workout: Workout) -> Future<Void, Error> {
    let curried = curry(store(workout: completion:))
    return asSingle(curried(workout))
  }

  func combineDelete(_ workout: Workout) -> Future<Void, Error> {
    let curried = curry(delete(workout: completion:))
    return asSingle(curried(workout))
  }

  func combineImage(forWorkoutID workoutID: String) -> Future<UIImage?, Error> {
    let curried = curry(loadImage(forWorkoutID: completion:))
    return asSingle(curried(workoutID))
  }

  func combineObserveWorkouts(for userID: String) -> PassthroughSubject<Result<[Workout], Error>, Error> {
    let curried = curry(subscribeToWorkoutChanges(for: callback:))
    return observe(curried(userID))
  }

  func combineObserveUsers() -> PassthroughSubject<Result<[User], Error>, Error> {
    return observe(subscribeToUserChanges(callback:))
  }

  // MARK: - Private

  private func observe<T>(
    _ block: @escaping (@escaping (T, Error?) -> Void) -> SubscriptionID
  ) -> PassthroughSubject<Result<T, Error>, Error> {
    let subject = PassthroughSubject<Result<T, Error>, Error>()
    // TODO: This never cancels the connection. Need to update this to use the cancelID to support unsubscribe.
    _ = block() { result, error in
      if let error = error {
        subject.send(.failure(error))
      } else {
        subject.send(.success(result))
      }
    }
    return subject
  }

  private func asSingle(_ block: @escaping (@escaping (Error?) -> Void) -> Void) -> Future<Void, Error> {
    return Future { promise in
      block() { error in
        if let error = error {
          promise(.failure(error))
        } else {
          promise(.success(()))
        }
      }
    }
  }

  private func asSingle<T>(_ block: @escaping (@escaping (T, Error?) -> Void) -> Void) -> Future<T, Error> {
    return Future { promise in
      block() { result, error in
        if let error = error {
          promise(.failure(error))
        } else {
          promise(.success(result))
        }
      }
    }
  }

  private func curry<A, B, C>(
    _ f: @escaping (A, B) -> C) -> ((A) -> ((B) -> C)
  ) {
    return { (a: A) -> ((B) -> C) in { (b: B) -> C in
        f(a, b)
      }
    }
  }
}
