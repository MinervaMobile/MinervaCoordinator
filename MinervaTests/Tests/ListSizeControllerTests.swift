//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxSwift
import XCTest

public final class ListSizeControllerTests: CommonSetupTestCase {
  public func testSectionSizing_verticalScrolling() {
    let cellModels = createCellModels(count: 19)
    let section = ListSection(cellModels: cellModels, identifier: "Section")

    let updateExpectation = expectation(description: "Update Expectation")
    listController.update(with: [section], animated: false) { finished in
      XCTAssertTrue(finished)
      updateExpectation.fulfill()
    }
    wait(for: [updateExpectation], timeout: 5)

    let containerSize = CGSize(
      width: collectionVC.view.frame.width,
      height: collectionVC.view.frame.height
    )
    let size = listController.size(of: section, containerSize: containerSize)
    XCTAssertEqual(size, CGSize(width: collectionVC.view.frame.width, height: 1_900))
  }

  public func testSectionSizing_verticalScrolling_equalDistribution() {
    let cellModels = createCellModels(count: 19)
    var section = ListSection(cellModels: cellModels, identifier: "Section")
    section.constraints.distribution = .equally(cellsInRow: 3)

    let updateExpectation = expectation(description: "Update Expectation")
    listController.update(with: [section], animated: false) { finished in
      XCTAssertTrue(finished)
      updateExpectation.fulfill()
    }
    wait(for: [updateExpectation], timeout: 5)

    let containerSize = CGSize(
      width: collectionVC.view.frame.width,
      height: collectionVC.view.frame.height
    )
    let size = listController.size(of: section, containerSize: containerSize)
    XCTAssertEqual(size, CGSize(width: collectionVC.view.frame.width, height: 700))
  }

  public func testSectionSizing_verticalScrolling_proportionalDistribution() {
    let cellModels = createCellModels(count: 19)
    var section = ListSection(cellModels: cellModels, identifier: "Section")
    section.constraints.distribution = .proportionally

    let updateExpectation = expectation(description: "Update Expectation")
    listController.update(with: [section], animated: false) { finished in
      XCTAssertTrue(finished)
      updateExpectation.fulfill()
    }
    wait(for: [updateExpectation], timeout: 5)

    let containerSize = CGSize(
      width: collectionVC.view.frame.width,
      height: collectionVC.view.frame.height
    )
    let size = listController.size(of: section, containerSize: containerSize)
    XCTAssertEqual(size, CGSize(width: collectionVC.view.frame.width, height: 1_000))
  }

  public func testSectionSizing_verticalScrolling_proportionalDistributionWithLastCellFillingWidth() {

    func runTest(totalCells: Int, minimumWidth: CGFloat, expectLastCellSize: CGSize, expectSectionSize: CGSize) {
      let cellModels = createCellModelsWithRelativeLastCell(count: totalCells)
      var section = ListSection(cellModels: cellModels, identifier: "Section")
      section.constraints.distribution = .proportionallyWithLastCellFillingWidth(minimumWidth: minimumWidth)

      let updateExpectation = expectation(description: "Update Expectation")
      listController.update(with: [section], animated: false) { finished in
        XCTAssertTrue(finished)
        updateExpectation.fulfill()
      }
      wait(for: [updateExpectation], timeout: 5)

      let containerSize = collectionVC.view.frame.size
      let size = listController.size(of: section, containerSize: containerSize)
      let sizeConstraints = ListSizeConstraints(containerSize: containerSize, sectionConstraints: section.constraints)
      let lastCellSize = listController.size(of: section.cellModels.last!, with: sizeConstraints)
      XCTAssertEqual(lastCellSize, expectLastCellSize)
      XCTAssertEqual(size, expectSectionSize)
    }

    // collection view is width 200. text input has height 45. cells are height 50.
    runTest(totalCells: 1, minimumWidth: 100, expectLastCellSize: CGSize(width: 200, height: 45), expectSectionSize: CGSize(width: 200, height: 45))
    // add a cell, forces row to be height 50
    runTest(totalCells: 2, minimumWidth: 100, expectLastCellSize: CGSize(width: 150, height: 45), expectSectionSize: CGSize(width: 200, height: 50))
    // add another cell. last cell shrinks in width.
    runTest(totalCells: 3, minimumWidth: 100, expectLastCellSize: CGSize(width: 100, height: 45), expectSectionSize: CGSize(width: 200, height: 50))
    // last cell is pushed onto new row, so it is full width (200)
    runTest(totalCells: 4, minimumWidth: 100, expectLastCellSize: CGSize(width: 200, height: 45), expectSectionSize: CGSize(width: 200, height: 95))
  }

  public func testSectionSizing_horizontalScrolling() {
    let cellModels = createCellModels(count: 19)
    var section = ListSection(cellModels: cellModels, identifier: "Section")
    section.constraints.scrollDirection = .horizontal

    let updateExpectation = expectation(description: "Update Expectation")
    listController.update(with: [section], animated: false) { finished in
      XCTAssertTrue(finished)
      updateExpectation.fulfill()
    }
    wait(for: [updateExpectation], timeout: 5)

    let containerSize = CGSize(
      width: collectionVC.view.frame.width,
      height: collectionVC.view.frame.height
    )
    let size = listController.size(of: section, containerSize: containerSize)
    XCTAssertEqual(size, CGSize(width: 1_425, height: 500))
  }
}
