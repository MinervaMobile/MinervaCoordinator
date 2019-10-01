//
//  UserListRepository.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation

import RxSwift

class WorkoutRepository {

  let workouts: Observable<Result<[Workout], Error>>
  let user: Observable<Result<User, Error>>

  // MARK: - Lifecycle

  init(dataManager: DataManager, userID: String) {
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
}
