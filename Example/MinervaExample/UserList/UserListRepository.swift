//
//  UserListRepository.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation

import RxSwift

class UserListRepository {

  private let dataManager: DataManager
  let users: Observable<Result<[User], Error>>

  // MARK: - Lifecycle

  init(dataManager: DataManager) {
    self.dataManager = dataManager
    self.users = dataManager.observeUsers()
  }

  var allowSelection: Bool {
    return dataManager.userAuthorization.role == .admin
  }
}
