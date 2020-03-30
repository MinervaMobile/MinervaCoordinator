//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Combine
import Foundation
import UIKit

extension DataManager {

  public func combineUsers() -> Future<[User], Error> {
    asSingle(loadUsers(completion:))
  }

  public func combineUser(withID userID: String) -> Future<User?, Error> {
    let curried = curry(loadUser(withID:completion:))
    return asSingle(curried(userID))
  }

  public func combineUpdate(_ user: User) -> Future<Void, Error> {
    let curried = curry(update(user:completion:))
    return asSingle(curried(user))
  }

  public func combineDeleteUser(withUserID userID: String) -> Future<Void, Error> {
    let curried = curry(delete(userID:completion:))
    return asSingle(curried(userID))
  }

  public func combineCreateUser(
    withEmail email: String,
    password: String,
    dailyCalories: Int32,
    role: UserRole
  ) -> Future<Void, Error> {
    Future { promise in
      self.create(withEmail: email, password: password, dailyCalories: dailyCalories, role: role) {
        error in
        if let error = error {
          promise(.failure(error))
        } else {
          promise(.success(()))
        }
      }
    }
  }

  public func combineWorkouts(forUserID userID: String) -> Future<[Workout], Error> {
    let curried = curry(loadWorkouts(forUserID:completion:))
    return asSingle(curried(userID))
  }

  public func combineStore(_ workout: Workout) -> Future<Void, Error> {
    let curried = curry(store(workout:completion:))
    return asSingle(curried(workout))
  }

  public func combineDelete(_ workout: Workout) -> Future<Void, Error> {
    let curried = curry(delete(workout:completion:))
    return asSingle(curried(workout))
  }

  public func combineImage(forWorkoutID workoutID: String) -> Future<UIImage?, Error> {
    let curried = curry(loadImage(forWorkoutID:completion:))
    return asSingle(curried(workoutID))
  }

  public func combineObserveWorkouts(for userID: String) -> PassthroughSubject<
    Result<[Workout], Error>, Error
  > {
    let curried = curry(subscribeToWorkoutChanges(for:callback:))
    return observe(curried(userID))
  }

  public func combineObserveUsers() -> PassthroughSubject<Result<[User], Error>, Error> {
    observe(subscribeToUserChanges(callback:))
  }

  // MARK: - Private

  private func observe<T>(
    _ block: @escaping (@escaping (T, Error?) -> Void) -> SubscriptionID
  ) -> PassthroughSubject<Result<T, Error>, Error> {
    let subject = PassthroughSubject<Result<T, Error>, Error>()
    // TODO: This never cancels the connection. Need to update this to use the cancelID to support unsubscribe.
    _ = block { result, error in
      if let error = error {
        subject.send(.failure(error))
      } else {
        subject.send(.success(result))
      }
    }
    return subject
  }

  private func asSingle(_ block: @escaping (@escaping (Error?) -> Void) -> Void) -> Future<
    Void, Error
  > {
    Future { promise in
      block() { error in
        if let error = error {
          promise(.failure(error))
        } else {
          promise(.success(()))
        }
      }
    }
  }

  private func asSingle<T>(_ block: @escaping (@escaping (T, Error?) -> Void) -> Void) -> Future<
    T, Error
  > {
    Future { promise in
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
    _ f: @escaping (A, B) -> C
  ) -> ((A) -> ((B) -> C)) {
    { (a: A) -> ((B) -> C) in
      { (b: B) -> C in
        f(a, b)
      }
    }
  }
}
