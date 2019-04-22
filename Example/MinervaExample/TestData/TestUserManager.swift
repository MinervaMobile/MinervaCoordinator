//
//  TestUserManager.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation

import PromiseKit

final class TestUserManager {

  private var activeUser: UserAuthorization?
  private let testData: TestData
  private let dataManagerFactory: DataManagerFactory

  init(testData: TestData, dataManagerFactory: DataManagerFactory) {
    self.testData = testData
    self.dataManagerFactory = dataManagerFactory
    activeUser = testData.emailToAuthorizationMap["a@a.com"]
  }
}

extension TestUserManager: UserManager {
  func activateCachedUser() -> DataManager? {
    guard let activeUser = self.activeUser else { return nil }
    return dataManagerFactory.createDataManager(for: activeUser)
  }

  func createAccount(withEmail email: String, password: String) -> Promise<DataManager> {
    guard email.isEmail else {
      return .init(error: SystemError.invalidEmail)
    }
    guard testData.emailToAuthorizationMap[email] == nil else {
      return .init(error: SystemError.alreadyExists)
    }
    let userID = UUID().uuidString
    let accessToken = UUID().uuidString
    let authorization = UserAuthorizationProto(userID: userID, accessToken: accessToken, role: .user)
    testData.emailToAuthorizationMap[email] = authorization
    testData.emailToPasswordMap[email] = password
    testData.idToAuthorizationMap[userID] = authorization

    let user = UserProto(userID: userID, email: email, dailyCalories: 2000)
    testData.idToUserMap[userID] = user
    activeUser = authorization
    return .value(dataManagerFactory.createDataManager(for: authorization))
  }

  func login(withEmail email: String, password: String) -> Promise<DataManager> {
    guard email.isEmail else {
      return .init(error: SystemError.invalidEmail)
    }
    guard let authorization = testData.emailToAuthorizationMap[email],
      let actualPassword = testData.emailToPasswordMap[email] else {
        return .init(error: SystemError.doesNotExist)
    }
    guard actualPassword == password else {
      return .init(error: SystemError.invalidEmailAndPassword)
    }
    activeUser = authorization
    return .value(dataManagerFactory.createDataManager(for: authorization))
  }

  func logout(userID: String) -> Promise<Void> {
    guard let currentUser = activeUser, currentUser.role.userEditor || userID == currentUser.userID else {
      return .init(error: SystemError.unauthorized)
    }
    guard var authorization = testData.idToAuthorizationMap[userID]?.proto else {
      return .init(error: SystemError.doesNotExist)
    }
    authorization.accessToken = UUID().uuidString
    testData.idToAuthorizationMap[userID] = authorization
    if userID == currentUser.userID {
      activeUser = nil
    }
    return .value(())
  }

  func delete(userID: String) -> Promise<Void> {
    guard let currentUser = activeUser, currentUser.role.userEditor || userID == currentUser.userID else {
      return .init(error: SystemError.unauthorized)
    }
    guard let user = testData.idToUserMap[userID] else {
      return .init(error: SystemError.doesNotExist)
    }
    testData.idToUserMap[userID] = nil
    testData.idToAuthorizationMap[userID] = nil
    testData.emailToAuthorizationMap[user.email] = nil
    testData.emailToPasswordMap[user.email] = nil
    if userID == currentUser.userID {
      activeUser = nil
    }
    return .value(())
  }
}
