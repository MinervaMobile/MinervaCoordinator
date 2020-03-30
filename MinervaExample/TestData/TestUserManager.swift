//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import RxSwift

public final class TestUserManager {

  private var activeUser: UserAuthorization?
  private let testData: TestData
  private let dataManagerFactory: DataManagerFactory

  public init(testData: TestData, dataManagerFactory: DataManagerFactory) {
    self.testData = testData
    self.dataManagerFactory = dataManagerFactory
    activeUser = testData.emailToAuthorizationMap["a@a.com"]
  }
}

extension TestUserManager: UserManager {
  public func activateCachedUser() -> DataManager? {
    guard let activeUser = self.activeUser else { return nil }
    return dataManagerFactory.createDataManager(for: activeUser, userManager: self)
  }

  public func createAccount(withEmail email: String, password: String) -> Single<DataManager> {
    guard email.isEmail else {
      return .error(SystemError.invalidEmail)
    }
    guard testData.emailToAuthorizationMap[email] == nil else {
      return .error(SystemError.alreadyExists)
    }
    let userID = UUID().uuidString
    let accessToken = UUID().uuidString
    let authorization = UserAuthorizationProto(
      userID: userID,
      accessToken: accessToken,
      role: .user
    )
    testData.emailToAuthorizationMap[email] = authorization
    testData.emailToPasswordMap[email] = password
    testData.idToAuthorizationMap[userID] = authorization

    let user = UserProto(userID: userID, email: email, dailyCalories: 2_000)
    testData.idToUserMap[userID] = user
    activeUser = authorization
    return .just(dataManagerFactory.createDataManager(for: authorization, userManager: self))
  }

  public func login(withEmail email: String, password: String) -> Single<DataManager> {
    guard email.isEmail else {
      return .error(SystemError.invalidEmail)
    }
    guard let authorization = testData.emailToAuthorizationMap[email],
      let actualPassword = testData.emailToPasswordMap[email]
    else {
      return .error(SystemError.doesNotExist)
    }
    guard actualPassword == password else {
      return .error(SystemError.invalidEmailAndPassword)
    }
    activeUser = authorization
    return .just(dataManagerFactory.createDataManager(for: authorization, userManager: self))
  }

  public func logout(userID: String) -> Single<Void> {
    guard let currentUser = activeUser, currentUser.role.userEditor || userID == currentUser.userID
    else {
      return .error(SystemError.unauthorized)
    }
    guard var authorization = testData.idToAuthorizationMap[userID]?.proto else {
      return .error(SystemError.doesNotExist)
    }
    authorization.accessToken = UUID().uuidString
    testData.idToAuthorizationMap[userID] = authorization
    if userID == currentUser.userID {
      activeUser = nil
    }
    return .just(())
  }

  public func delete(userID: String) -> Single<Void> {
    guard let currentUser = activeUser, currentUser.role.userEditor || userID == currentUser.userID
    else {
      return .error(SystemError.unauthorized)
    }
    guard let user = testData.idToUserMap[userID] else {
      return .error(SystemError.doesNotExist)
    }
    testData.idToUserMap[userID] = nil
    testData.idToAuthorizationMap[userID] = nil
    testData.emailToAuthorizationMap[user.email] = nil
    testData.emailToPasswordMap[user.email] = nil
    if userID == currentUser.userID {
      activeUser = nil
    }
    return .just(())
  }
}
