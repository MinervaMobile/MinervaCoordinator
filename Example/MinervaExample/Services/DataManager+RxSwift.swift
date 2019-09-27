//
//  DataManager+RxSwift.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation

import RxSwift

extension DataManager {

  func users() -> Single<[User]> {
    return Single.create() { single in
      self.loadUsers { users, error in
        if let error = error {
          single(.error(error))
        } else {
          single(.success(users))
        }
      }
      return Disposables.create { }
    }
  }

  func user(withID userID: String) -> Single<User?> {
    return Single.create() { single in
      self.loadUser(withID: userID) { user, error in
        if let error = error {
          single(.error(error))
        } else {
          single(.success(user))
        }
      }
      return Disposables.create { }
    }
  }

  func update(_ user: User) -> Single<Void> {
    return Single.create() { single in
      self.update(user: user) { error in
        if let error = error {
          single(.error(error))
        } else {
          single(.success(()))
        }
      }
      return Disposables.create { }
    }
  }

  func deleteUser(withUserID userID: String) -> Single<Void> {
    return Single.create() { single in
      self.delete(userID: userID) { error in
        if let error = error {
          single(.error(error))
        } else {
          single(.success(()))
        }
      }
      return Disposables.create { }
    }
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
    return Single.create() { single in
      self.loadWorkouts(forUserID: userID) { workouts, error in
        if let error = error {
          single(.error(error))
        } else {
          single(.success(workouts))
        }
      }
      return Disposables.create { }
    }
  }

  func store(_ workout: Workout) -> Single<Void> {
    return Single.create() { single in
      self.store(workout: workout) { error in
        if let error = error {
          single(.error(error))
        } else {
          single(.success(()))
        }
      }
      return Disposables.create { }
    }
  }

  func delete(_ workout: Workout) -> Single<Void> {
    return Single.create() { single in
      self.delete(workout: workout) { error in
        if let error = error {
          single(.error(error))
        } else {
          single(.success(()))
        }
      }
      return Disposables.create { }
    }
  }

  func observeWorkouts(for userID: String) -> Observable<Result<[Workout], Error>> {
    return Observable<Result<[Workout], Error>>.create { observer in
      let subscriptionID = self.subscribeToWorkoutChanges(for: userID) { workouts, error in
        if let error = error {
          observer.on(.next(.failure(error)))
        } else {
          observer.on(.next(.success(workouts)))
        }
      }
      return Disposables.create {
        self.unsubscribe(listenerID: subscriptionID)
      }
    }
  }

  func observeUsers() -> Observable<Result<[User], Error>> {
    return Observable<Result<[User], Error>>.create { observer in
      let subscriptionID = self.subscribeToUserChanges() { users, error in
        if let error = error {
          observer.on(.next(.failure(error)))
        } else {
          observer.on(.next(.success(users)))
        }
      }
      return Disposables.create {
        self.unsubscribe(listenerID: subscriptionID)
      }
    }
  }
}
