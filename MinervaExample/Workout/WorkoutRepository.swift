//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
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
    self.user = dataManager.observeUsers()
      .compactMap { changeResult -> Result<User, Error>? in
        switch changeResult {
        case let .success(users):
          guard let user = users.first(where: { $0.userID == userID }) else {
            return nil
          }
          return .success(user)
        case let .failure(error):
          return .failure(error)
        }
      }
  }

  public func image(forWorkoutID workoutID: String) -> Observable<UIImage?> {
    dataManager.image(forWorkoutID: workoutID).asObservable()
  }

  public func delete(_ workout: Workout) -> Single<Void> {
    dataManager.delete(workout)
  }
}
