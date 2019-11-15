//
//  MinervaTests.swift
//  MinervaTests
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Minerva
import XCTest

public final class MinervaTests: XCTestCase {

  private var listController: ListController!

  override public func setUp() {
    super.setUp()
    listController = LegacyListController()
  }

  override public func tearDown() {
    listController = nil
    super.tearDown()
  }

  public func testCreation() {
    XCTAssertNotNil(listController)
  }

}
