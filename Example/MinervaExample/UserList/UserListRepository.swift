//
//  UserListRepository.swift
//  MinervaExample
//
//  Created by Joe Laws on 9/27/19.
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation

import RxSwift

class UserListRepository {

  private let dataManager: DataManager

  // MARK: - Lifecycle

  init(dataManager: DataManager) {
    self.dataManager = dataManager
  }

  var users: Observable<Result<[User], Error>> {
    return dataManager.observeUsers()
  }

  var allowSelection: Bool {
    return dataManager.userAuthorization.role == .admin
  }
}
