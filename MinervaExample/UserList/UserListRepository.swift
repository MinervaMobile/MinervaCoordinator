//
//  UserListRepository.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
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
		return dataManager.userAuthorization.role == .admin
	}
}
