//
//  DataManagerFactory.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation

public protocol DataManagerFactory {
	func createDataManager(for userAuthorization: UserAuthorization, userManager: UserManager) -> DataManager
}
