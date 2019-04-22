//
//  TestDataManager.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation

import PromiseKit

final class TestDataManager {
  let userAuthorization: UserAuthorization
  private let testData: TestData

  init(testData: TestData, userAuthorization: UserAuthorization) {
    self.testData = testData
    self.userAuthorization = userAuthorization
  }
}

extension TestDataManager: DataManager {
  func loadUsers() -> Promise<[User]> {
    guard userAuthorization.role.userEditor else {
      return .init(error: SystemError.unauthorized)
    }
    return .value(Array(testData.idToUserMap.values))
  }

  func loadUser(withID userID: String) -> Promise<User?> {
    guard userID == userAuthorization.userID || userAuthorization.role.userEditor else {
      return .init(error: SystemError.unauthorized)
    }
    return .value(testData.idToUserMap[userID])
  }

  func update(user: User) -> Promise<Void> {
    guard user.userID == userAuthorization.userID || userAuthorization.role.userEditor else {
      return .init(error: SystemError.unauthorized)
    }
    testData.idToUserMap[user.userID] = user
    return .value(())
  }

  func create(
    withEmail email: String,
    password: String,
    dailyCalories: Int32,
    role: UserRole
  ) -> Promise<Void> {
    guard userAuthorization.role.userEditor else {
      return .init(error: SystemError.unauthorized)
    }
    guard userAuthorization.role == .admin || role != .admin else {
      return .init(error: SystemError.unauthorized)
    }
    guard email.isEmail else {
      return .init(error: SystemError.invalidEmail)
    }
    guard testData.emailToAuthorizationMap[email] == nil else {
      return .init(error: SystemError.alreadyExists)
    }
    let userID = UUID().uuidString
    let accessToken = UUID().uuidString
    let authorization = UserAuthorizationProto(userID: userID, accessToken: accessToken, role: role)
    testData.emailToAuthorizationMap[email] = authorization
    testData.emailToPasswordMap[email] = password
    testData.idToAuthorizationMap[userID] = authorization

    let user = UserProto(userID: userID, email: email, dailyCalories: dailyCalories)
    testData.idToUserMap[userID] = user
    return .value(())
  }

  func loadWorkouts(forUserID userID: String) -> Promise<[Workout]> {
    guard userID == userAuthorization.userID || userAuthorization.role == .admin else {
      return .init(error: SystemError.unauthorized)
    }
    let workoutMap = testData.idToWorkoutIDMap[userID] ?? [:]
    let workouts = workoutMap.values
    return .value(Array(workouts))
  }

  func store(workout: Workout) -> Promise<Void> {
    guard workout.userID == userAuthorization.userID || userAuthorization.role == .admin else {
      return .init(error: SystemError.unauthorized)
    }
    var workoutIDMap = testData.idToWorkoutIDMap[workout.userID] ?? [:]
    workoutIDMap[workout.workoutID] = workout
    testData.idToWorkoutIDMap[workout.userID] = workoutIDMap
    return .value(())
  }

  func delete(workout: Workout) -> Promise<Void> {
    guard workout.userID == userAuthorization.userID || userAuthorization.role == .admin else {
      return .init(error: SystemError.unauthorized)
    }
    var workoutIDMap = testData.idToWorkoutIDMap[workout.userID] ?? [:]
    workoutIDMap[workout.workoutID] = nil
    testData.idToWorkoutIDMap[workout.userID] = workoutIDMap
    return .value(())
  }
}
