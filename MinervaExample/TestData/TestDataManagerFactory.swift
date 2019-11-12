//
//  TestDataManagerFactory.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation

public final class TestDataManagerFactory: DataManagerFactory {
	private let testData: TestData

	public init(testData: TestData) {
		self.testData = testData
	}

	// MARK: - DataManagerFactory
	public func createDataManager(for userAuthorization: UserAuthorization, userManager: UserManager) -> DataManager {
		return TestDataManager(testData: testData, userAuthorization: userAuthorization, userManager: userManager)
	}
}
