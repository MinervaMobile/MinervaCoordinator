//
//  UserListRepository.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import RxSwift

public class WorkoutRepository {
  private let dataManager: DataManager

  public let workouts: Observable<Result<[Workout], Error>>
  public let user: Observable<Result<User, Error>>
  public let userID: String

  // MARK: - Lifecycle

  public init(dataManager: DataManager, userID: String) {
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

  public func image(forWorkoutID workoutID: String) -> Observable<UIImage?> {
    return dataManager.image(forWorkoutID: workoutID).asObservable()
  }
  public func delete(_ workout: Workout) -> Single<Void> {
    return dataManager.delete(workout)
  }
}
