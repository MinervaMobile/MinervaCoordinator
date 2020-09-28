//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import RxSwift
import UIKit

extension DataManager {

  public func users() -> Single<[User]> {
    asSingle(loadUsers(completion:))
  }

  public func user(withID userID: String) -> Single<User?> {
    let curried = curry(loadUser(withID:completion:))
    return asSingle(curried(userID))
  }

  public func update(_ user: User) -> Single<Void> {
    let curried = curry(update(user:completion:))
    return asSingle(curried(user))
  }

  public func deleteUser(withUserID userID: String) -> Single<Void> {
    let curried = curry(delete(userID:completion:))
    return asSingle(curried(userID))
  }

  public func createUser(
    withEmail email: String,
    password: String,
    dailyCalories: Int32,
    role: UserRole
  ) -> Single<Void> {
    Single.create { single in
      self.create(withEmail: email, password: password, dailyCalories: dailyCalories, role: role) {
        error in
        if let error = error {
          single(.error(error))
        } else {
          single(.success(()))
        }
      }
      return Disposables.create {}
    }
  }

  public func workouts(forUserID userID: String) -> Single<[Workout]> {
    let curried = curry(loadWorkouts(forUserID:completion:))
    return asSingle(curried(userID))
  }

  public func store(_ workout: Workout) -> Single<Void> {
    let curried = curry(store(workout:completion:))
    return asSingle(curried(workout))
  }

  public func delete(_ workout: Workout) -> Single<Void> {
    let curried = curry(delete(workout:completion:))
    return asSingle(curried(workout))
  }

  public func image(forWorkoutID workoutID: String) -> Single<UIImage?> {
    let curried = curry(loadImage(forWorkoutID:completion:))
    return asSingle(curried(workoutID))
  }

  public func observeWorkouts(for userID: String) -> Observable<Result<[Workout], Error>> {
    let curried = curry(subscribeToWorkoutChanges(for:callback:))
    return observe(curried(userID))
  }

  public func observeUsers() -> Observable<Result<[User], Error>> {
    observe(subscribeToUserChanges(callback:))
  }

  // MARK: - Private

  private func observe<T>(
    _ block: @escaping (@escaping (T, Error?) -> Void) -> SubscriptionID
  ) -> Observable<Result<T, Error>> {
    Observable<Result<T, Error>>
      .create { observer in
        let subscriptionID = block { result, error in
          if let error = error {
            observer.onNext(.failure(error))
          } else {
            observer.onNext(.success(result))
          }
        }
        return Disposables.create {
          self.unsubscribe(listenerID: subscriptionID)
        }
      }
  }

  private func asSingle(_ block: @escaping (@escaping (Error?) -> Void) -> Void) -> Single<Void> {
    Single.create { single in
      block { error in
        if let error = error {
          single(.error(error))
        } else {
          single(.success(()))
        }
      }
      return Disposables.create {}
    }
  }

  private func asSingle<T>(_ block: @escaping (@escaping (T, Error?) -> Void) -> Void) -> Single<T>
  {
    Single.create { single in
      block { result, error in
        if let error = error {
          single(.error(error))
        } else {
          single(.success(result))
        }
      }
      return Disposables.create {}
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
