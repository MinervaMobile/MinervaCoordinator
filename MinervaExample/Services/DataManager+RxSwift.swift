//
//  DataManager+RxSwift.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import RxSwift

extension DataManager {

  func users() -> Single<[User]> {
    return asSingle(loadUsers(completion:))
  }

  func user(withID userID: String) -> Single<User?> {
    let curried = curry(loadUser(withID: completion:))
    return asSingle(curried(userID))
  }

  func update(_ user: User) -> Single<Void> {
    let curried = curry(update(user: completion:))
    return asSingle(curried(user))
  }

  func deleteUser(withUserID userID: String) -> Single<Void> {
    let curried = curry(delete(userID: completion:))
    return asSingle(curried(userID))
  }

  func createUser(
    withEmail email: String,
    password: String,
    dailyCalories: Int32,
    role: UserRole
  ) -> Single<Void> {
    return Single.create() { single in
      self.create(withEmail: email, password: password, dailyCalories: dailyCalories, role: role) { error in
        if let error = error {
          single(.error(error))
        } else {
          single(.success(()))
        }
      }
      return Disposables.create { }
    }
  }

  func workouts(forUserID userID: String) -> Single<[Workout]> {
    let curried = curry(loadWorkouts(forUserID: completion:))
    return asSingle(curried(userID))
  }

  func store(_ workout: Workout) -> Single<Void> {
    let curried = curry(store(workout: completion:))
    return asSingle(curried(workout))
  }

  func delete(_ workout: Workout) -> Single<Void> {
    let curried = curry(delete(workout: completion:))
    return asSingle(curried(workout))
  }

  func image(forWorkoutID workoutID: String) -> Single<UIImage?> {
    let curried = curry(loadImage(forWorkoutID: completion:))
    return asSingle(curried(workoutID))
  }

  func observeWorkouts(for userID: String) -> Observable<Result<[Workout], Error>> {
    let curried = curry(subscribeToWorkoutChanges(for: callback:))
    return observe(curried(userID))
  }

  func observeUsers() -> Observable<Result<[User], Error>> {
    return observe(subscribeToUserChanges(callback:))
  }

  // MARK: - Private

  private func observe<T>(
    _ block: @escaping (@escaping (T, Error?) -> Void) -> SubscriptionID
  ) -> Observable<Result<T, Error>> {
    return Observable<Result<T, Error>>.create { observer in
      let subscriptionID = block() { result, error in
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
    return Single.create() { single in
      block() { error in
        if let error = error {
          single(.error(error))
        } else {
          single(.success(()))
        }
      }
      return Disposables.create { }
    }
  }

  private func asSingle<T>(_ block: @escaping (@escaping (T, Error?) -> Void) -> Void) -> Single<T> {
    return Single.create() { single in
      block() { result, error in
        if let error = error {
          single(.error(error))
        } else {
          single(.success(result))
        }
      }
      return Disposables.create { }
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
