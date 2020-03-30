//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import RxSwift

public class UserListRepository {

  private let dataManager: DataManager
  public let users: Observable<Result<[User], Error>>

  // MARK: - Lifecycle

  public init(dataManager: DataManager) {
    self.dataManager = dataManager
    self.users = dataManager.observeUsers()
  }

  public var allowSelection: Bool {
    dataManager.userAuthorization.role == .admin
  }
}
