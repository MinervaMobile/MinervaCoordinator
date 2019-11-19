//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation

public final class TestData {

  public var emailToPasswordMap = [String: String]()
  public var emailToAuthorizationMap = [String: UserAuthorization]()
  public var idToAuthorizationMap = [String: UserAuthorization]()
  public var idToUserMap = [String: User]()
  public var idToWorkoutIDMap = [String: [String: Workout]]()

  public init() {
    setupTestUsers()
    setupTestManager()
    setupTestAdmin()
  }

  private func setupTestUsers() {
    for n in 1...20 {
      let testUserAuthorization = UserAuthorizationProto(
        userID: UUID().uuidString,
        accessToken: UUID().uuidString,
        role: .user)
      let testUser = UserProto(
        userID: testUserAuthorization.userID,
        email: "u\(n)@u.com",
        dailyCalories: Int32.random(in: 1_250...2_500))
      emailToPasswordMap[testUser.email] = "\(n)"
      emailToAuthorizationMap[testUser.email] = testUserAuthorization
      idToAuthorizationMap[testUser.userID] = testUserAuthorization
      idToUserMap[testUser.userID] = testUser
      idToWorkoutIDMap[testUser.userID] = randomWorkouts(forUserID: testUserAuthorization.userID).asMap { $0.workoutID }
    }
  }

  private func setupTestManager() {
    let testUserAuthorization = UserAuthorizationProto(
      userID: UUID().uuidString,
      accessToken: UUID().uuidString,
      role: .userManager)
    let testUser = UserProto(userID: testUserAuthorization.userID, email: "m@m.com", dailyCalories: 2_000)
    emailToPasswordMap[testUser.email] = "m"
    emailToAuthorizationMap[testUser.email] = testUserAuthorization
    idToAuthorizationMap[testUser.userID] = testUserAuthorization
    idToUserMap[testUser.userID] = testUser
    idToWorkoutIDMap[testUser.userID] = randomWorkouts(forUserID: testUserAuthorization.userID).asMap { $0.workoutID }
  }

  private func setupTestAdmin() {
    let testUserAuthorization = UserAuthorizationProto(
      userID: UUID().uuidString,
      accessToken: UUID().uuidString,
      role: .admin)
    let testUser = UserProto(userID: testUserAuthorization.userID, email: "a@a.com", dailyCalories: 2_000)
    emailToPasswordMap[testUser.email] = "a"
    emailToAuthorizationMap[testUser.email] = testUserAuthorization
    idToAuthorizationMap[testUser.userID] = testUserAuthorization
    idToUserMap[testUser.userID] = testUser
    idToWorkoutIDMap[testUser.userID] = randomWorkouts(forUserID: testUserAuthorization.userID).asMap { $0.workoutID }
  }
  private func randomWorkouts(forUserID userID: String) -> [Workout] {
    var workouts = [Workout]()
    for workoutNumber in 1...50 {
      let workout = WorkoutProto(
        workoutID: UUID().uuidString,
        userID: userID,
        text: "\(workoutNumber)",
        calories: Int32.random(in: 1...1_250),
        date: Date().addingTimeInterval(-60 * 60 * 8 * Double(workoutNumber)))
      workouts.append(workout)
    }
    return workouts
  }
}
