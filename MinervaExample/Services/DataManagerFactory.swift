//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation

public protocol DataManagerFactory {
  func createDataManager(for userAuthorization: UserAuthorization, userManager: UserManager)
    -> DataManager
}
