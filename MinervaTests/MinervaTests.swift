//
//  MinervaTests.swift
//  MinervaTests
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Minerva
import XCTest

class MinervaTests: XCTestCase {

  private var listController: ListController!

  override func setUp() {
    listController = LegacyListController()
  }

  override func tearDown() {
    listController = nil
  }

  func testCreation() {
    XCTAssertNotNil(listController)
  }

}
