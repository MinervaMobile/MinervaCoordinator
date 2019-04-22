//
//  DataManagerFactory.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation

protocol DataManagerFactory {
  func createDataManager(for userAuthorization: UserAuthorization) -> DataManager
}
