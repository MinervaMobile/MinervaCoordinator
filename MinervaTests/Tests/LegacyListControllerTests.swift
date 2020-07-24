//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Minerva
import RxSwift
import XCTest

public final class LegacyListControllerTests: CommonSetupTestCase {

  public func test_noIndexForModelNotInSections() {
    let cellModel = FakeCellModel(identifier: "fake", size: .autolayout)
    XCTAssertNil(listController.indexPath(for: cellModel))
  }

  public func test_scrollToCell() {
    let cellModels = FakeCellModel.createCellModels(count: 19)
    let section = ListSection(cellModels: cellModels, identifier: "Section")

    let updateExpectation = expectation(description: "Update Expectation")
    listController.update(with: [section], animated: false) { finished in
      XCTAssertTrue(finished)
      updateExpectation.fulfill()
    }
    listController.scrollTo(cellModel: cellModels.last!, scrollPosition: .top, animated: true)
    wait(for: [updateExpectation], timeout: 5)

    let update2Expectation = expectation(description: "Update2 Expectation")
    listController.update(with: [section], animated: false) { finished in
      XCTAssertTrue(finished)
      update2Expectation.fulfill()
    }
    wait(for: [update2Expectation], timeout: 5)
    XCTAssertTrue(
      collectionVC.collectionView.indexPathsForVisibleItems.contains(IndexPath(row: 18, section: 0))
    )
  }

  public func test_scrollToBottom() {
    let cellModels = FakeCellModel.createCellModels(count: 19)
    let section = ListSection(cellModels: cellModels, identifier: "Section")

    let updateExpectation = expectation(description: "Update Expectation")
    listController.update(with: [section], animated: false) { finished in
      XCTAssertTrue(finished)
      updateExpectation.fulfill()
    }
    listController.scroll(to: .bottom, animated: true)
    wait(for: [updateExpectation], timeout: 5)

    let update2Expectation = expectation(description: "Update2 Expectation")
    listController.update(with: [section], animated: false) { finished in
      XCTAssertTrue(finished)
      update2Expectation.fulfill()
    }
    wait(for: [update2Expectation], timeout: 5)
    XCTAssertTrue(
      collectionVC.collectionView.indexPathsForVisibleItems.contains(IndexPath(row: 18, section: 0))
    )
  }
}
