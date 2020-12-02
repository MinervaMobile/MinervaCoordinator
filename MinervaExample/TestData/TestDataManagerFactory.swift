//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation

public final class TestDataManagerFactory: DataManagerFactory {
  private let testData: TestData

  public init(testData: TestData) {
    self.testData = testData
  }

  // MARK: - DataManagerFactory

  public func createDataManager(for userAuthorization: UserAuthorization, userManager: UserManager)
    -> DataManager
  {
    TestDataManager(
      testData: testData,
      userAuthorization: userAuthorization,
      userManager: userManager
    )
  }
}
