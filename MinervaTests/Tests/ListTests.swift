//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxSwift
import XCTest

public final class ListTests: CommonSetupTestCase {

  public func testDynamicSizing() {
    let sizeManager = FakeSizeManager()
    listController.sizeDelegate = sizeManager
    let marginCellModel = MarginCellModel()
    let section = ListSection(cellModels: [marginCellModel], identifier: "Section")

    let updateExpectation = expectation(description: "Update Expectation")
    listController.update(with: [section], animated: false) { finished in
      XCTAssertTrue(finished)
      XCTAssertTrue(sizeManager.handledSizeRequest)
      updateExpectation.fulfill()
    }
    wait(for: [updateExpectation], timeout: 5)
  }

  public func testEqualDistribution() {
    let cellModels = createCellModels(count: 9)
    var section = ListSection(cellModels: cellModels, identifier: "Section")
    section.constraints.distribution = .equally(cellsInRow: 3)

    let updateExpectation = expectation(description: "Update Expectation")
    listController.update(with: [section], animated: false) { finished in
      XCTAssertTrue(finished)
      updateExpectation.fulfill()
    }
    wait(for: [updateExpectation], timeout: 5)
  }

  public func testCenterCellModel() {
    let cellModels = createCellModels(count: 9)
    let section = ListSection(cellModels: cellModels, identifier: "Section")

    let updateExpectation = expectation(description: "Update Expectation")
    listController.update(with: [section], animated: false) { finished in
      XCTAssertTrue(finished)
      updateExpectation.fulfill()
    }
    wait(for: [updateExpectation], timeout: 5)

    let updateExpectation2 = expectation(description: "Update Expectation2")
    listController.update(with: [section], animated: false) { finished in
      XCTAssertTrue(finished)
      updateExpectation2.fulfill()
    }
    wait(for: [updateExpectation2], timeout: 5)
    XCTAssertTrue(listController.centerCellModel!.identical(to: cellModels[4]))
  }

  public func testConstraints() {
    var section1 = ListSection(cellModels: createCellModels(count: 9), identifier: "Section1")
    section1.constraints.distribution = .equally(cellsInRow: 3)
    var section2 = ListSection(cellModels: createCellModels(count: 9), identifier: "Section2")
    section2.constraints.distribution = .equally(cellsInRow: 3)
    XCTAssertEqual(section1.constraints.hashValue, section2.constraints.hashValue)
  }

  public func testProportionalDistribution() {
    let cellModels = createCellModels(count: 9)
    var section = ListSection(cellModels: cellModels, identifier: "Section")
    section.constraints.distribution = .proportionally

    let updateExpectation = expectation(description: "Update Expectation")
    listController.update(with: [section], animated: false) { finished in
      XCTAssertTrue(finished)
      updateExpectation.fulfill()
    }
    wait(for: [updateExpectation], timeout: 5)
  }

  public func testSelection() {
    var cellModel = FakeCellModel(
      identifier: "FakeCellModel1",
      size: .explicit(size: CGSize(width: 100, height: 100))
    )

    var selected = false
    cellModel.selectionAction = { _, _ in
      selected = true
    }
    let section = ListSection(cellModels: [cellModel], identifier: "Section")

    let updateExpectation = expectation(description: "Update Expectation")
    listController.update(with: [section], animated: false) { finished in
      XCTAssertTrue(finished)
      updateExpectation.fulfill()
    }
    wait(for: [updateExpectation], timeout: 5)
    collectionVC.collectionView.delegate?.collectionView?(
      collectionVC.collectionView,
      didSelectItemAt: IndexPath(item: 0, section: 0)
    )
    XCTAssertTrue(selected)
  }

  public func testHighlighting() {
    var cellModel = FakeCellModel(
      identifier: "FakeCellModel1",
      size: .explicit(size: CGSize(width: 100, height: 100))
    )
    var highlighted = false
    cellModel.highlightedAction = { _, _ in
      highlighted = true
    }
    cellModel.unhighlightedAction = { _, _ in
      highlighted = false
    }

    cellModel.highlightEnabled = true
    let section = ListSection(cellModels: [cellModel], identifier: "Section")

    let updateExpectation = expectation(description: "Update Expectation")
    listController.update(with: [section], animated: false) { finished in
      XCTAssertTrue(finished)
      updateExpectation.fulfill()
    }
    wait(for: [updateExpectation], timeout: 5)
    collectionVC.collectionView.delegate?.collectionView?(
      collectionVC.collectionView,
      didHighlightItemAt: IndexPath(item: 0, section: 0)
    )
    XCTAssertTrue(highlighted)
    collectionVC.collectionView.delegate?.collectionView?(
      collectionVC.collectionView,
      didUnhighlightItemAt: IndexPath(item: 0, section: 0)
    )
    XCTAssertFalse(highlighted)
  }

  public func testDisplay() {
    let cellModel = FakeCellModel(
      identifier: "FakeCellModel1",
      size: .explicit(size: CGSize(width: 100, height: 100))
    )
    let section = ListSection(cellModels: [cellModel], identifier: "Section")

    let updateExpectation = expectation(description: "Update Expectation")
    listController.update(with: [section], animated: false) { finished in
      XCTAssertTrue(finished)
      updateExpectation.fulfill()
    }
    wait(for: [updateExpectation], timeout: 5)
    guard let indexPath = listController.indexPath(for: cellModel),
      let cell = collectionVC.collectionView.cellForItem(at: indexPath) as? FakeCell
    else {
      XCTFail("Missing the cell")
      return
    }
    XCTAssertTrue(cell.displaying)
    listController.didEndDisplaying()
    XCTAssertFalse(cell.displaying)
    listController.willDisplay()
    XCTAssertTrue(cell.displaying)
  }

  public func testRemoveCellModel() {
    let cellModel0 = FakeCellModel(
      identifier: "FakeCellModel0",
      size: .explicit(size: CGSize(width: 100, height: 100))
    )
    let cellModel1 = FakeCellModel(
      identifier: "FakeCellModel1",
      size: .explicit(size: CGSize(width: 100, height: 100))
    )

    let section = ListSection(cellModels: [cellModel0, cellModel1], identifier: "Section")

    let updateExpectation = expectation(description: "Update Expectation")
    listController.update(with: [section], animated: false) { finished in
      XCTAssertTrue(finished)
      updateExpectation.fulfill()
    }
    wait(for: [updateExpectation], timeout: 5)
    XCTAssertEqual(collectionVC.collectionView.numberOfSections, 1)
    XCTAssertEqual(collectionVC.collectionView.numberOfItems(inSection: 0), 2)

    let removeExpectation = expectation(description: "Remove Expectation")
    listController.removeCellModel(at: IndexPath(item: 0, section: 0), animated: false) {
      finished in
      XCTAssertTrue(finished)
      removeExpectation.fulfill()
    }
    wait(for: [removeExpectation], timeout: 5)
    XCTAssertEqual(collectionVC.collectionView.numberOfSections, 1)
    XCTAssertEqual(collectionVC.collectionView.numberOfItems(inSection: 0), 1)
  }

  public func testRemoveLastCellModelInSection() {
    let cellModel = FakeCellModel(
      identifier: "FakeCellModel1",
      size: .explicit(size: CGSize(width: 100, height: 100))
    )
    let section = ListSection(cellModels: [cellModel], identifier: "Section")

    let updateExpectation = expectation(description: "Update Expectation")
    listController.update(with: [section], animated: false) { finished in
      XCTAssertTrue(finished)
      updateExpectation.fulfill()
    }
    wait(for: [updateExpectation], timeout: 5)
    XCTAssertEqual(collectionVC.collectionView.numberOfSections, 1)
    XCTAssertEqual(collectionVC.collectionView.numberOfItems(inSection: 0), 1)

    let removeExpectation = expectation(description: "Remove Expectation")
    listController.removeCellModel(at: IndexPath(item: 0, section: 0), animated: false) {
      finished in
      XCTAssertTrue(finished)
      removeExpectation.fulfill()
    }
    wait(for: [removeExpectation], timeout: 5)
    XCTAssertEqual(collectionVC.collectionView.numberOfSections, 0)
  }

  public func testScrollToBottom() {
    let cellModels = createCellModels(count: 19)
    let section = ListSection(cellModels: cellModels, identifier: "Section")

    let updateExpectation = expectation(description: "Update Expectation")
    listController.update(with: [section], animated: false) { finished in
      XCTAssertTrue(finished)
      updateExpectation.fulfill()
    }
    wait(for: [updateExpectation], timeout: 5)

    XCTAssertNotEqual(
      collectionVC.collectionView.indexPathsForVisibleItems.map { $0.row }.max(),
      cellModels.count - 1
    )
    listController.scroll(to: .bottom, animated: false)

    let updateExpectation2 = expectation(description: "Update Expectation2")
    listController.update(with: [section], animated: false) { finished in
      XCTAssertTrue(finished)
      updateExpectation2.fulfill()
    }
    wait(for: [updateExpectation2], timeout: 5)

    XCTAssertEqual(
      collectionVC.collectionView.indexPathsForVisibleItems.map { $0.row }.max(),
      cellModels.count - 1
    )
  }
}
