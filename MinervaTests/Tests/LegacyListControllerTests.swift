//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Minerva
import RxSwift
import XCTest

public final class LegacyListControllerTests: XCTestCase {
  public func test_noIndexForModelNotInSections() {
    let listController = LegacyListController()

    let cellModel = FakeCellModel(identifier: "fake", size: .autolayout)
    XCTAssertNil(listController.indexPath(for: cellModel))
  }
}
