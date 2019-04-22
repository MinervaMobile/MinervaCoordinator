//
//  TestDataManagerFactory.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation

final class TestDataManagerFactory: DataManagerFactory {
  private let testData: TestData

  init(testData: TestData) {
    self.testData = testData
  }

  // MARK: - DataManagerFactory
  func createDataManager(for userAuthorization: UserAuthorization) -> DataManager {
    return TestDataManager(testData: testData, userAuthorization: userAuthorization)
  }
}

