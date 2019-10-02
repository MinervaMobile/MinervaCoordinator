//
//  UserListRepository.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation

import RxSwift

class WorkoutRepository {
  private let dataManager: DataManager

  let workouts: Observable<Result<[Workout], Error>>
  let user: Observable<Result<User, Error>>
  let userID: String

  // MARK: - Lifecycle

  init(dataManager: DataManager, userID: String) {
    self.dataManager = dataManager
    self.userID = userID
    self.workouts = dataManager.observeWorkouts(for: userID)
    self.user = dataManager.observeUsers().compactMap { changeResult -> Result<User, Error>? in
      switch changeResult {
      case .success(let users):
        guard let user = users.first(where: { $0.userID == userID }) else {
          return nil
        }
        return .success(user)
      case .failure(let error):
        return .failure(error)
      }
    }
  }

  func delete(_ workout: Workout) -> Single<Void> {
    return dataManager.delete(workout)
  }
}
