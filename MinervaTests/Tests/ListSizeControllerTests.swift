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

    let containerSize = collectionVC.view.frame.size
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

    let containerSize = collectionVC.view.frame.size
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

    let containerSize = collectionVC.view.frame.size
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

    let containerSize = collectionVC.view.frame.size

    let size = listController.size(of: section, containerSize: containerSize)
    XCTAssertEqual(size, CGSize(width: 1_425, height: 500))
  }

  /* MarginCell tests */

  public func testSectionSizing_marginCell_expandsToFillHeight() {
    let sizeManager = FakeSizeManagerForMarginCells()
    listController.sizeDelegate = sizeManager

    let cellModels: [ListCellModel] = createCellModels(count: 1) + [MarginCellModel()]
    let section = ListSection(cellModels: cellModels, identifier: "Section")

    let updateExpectation = expectation(description: "Update Expectation")
    listController.update(with: [section], animated: false) { finished in
      XCTAssertTrue(finished)
      updateExpectation.fulfill()
    }
    wait(for: [updateExpectation], timeout: 5)

    let marginCellIndex = IndexPath(item: 1, section: 0)
    verifySizeOfCell(at: marginCellIndex, matches: CGSize(width: 200, height: 400))
  }

  public func testSectionSizing_multipleMarginCells_expandEquallyToFillHeight() {
    let sizeManager = FakeSizeManagerForMarginCells()
    listController.sizeDelegate = sizeManager

    let marginCellAbove = MarginCellModel()
    let marginCellBelow = MarginCellModel()

    let cellModels: [ListCellModel] = [marginCellAbove] + createCellModels(count: 1) + [marginCellBelow]
    let section = ListSection(cellModels: cellModels, identifier: "Section")

    let updateExpectation = expectation(description: "Update Expectation")
    listController.update(with: [section], animated: false) { finished in
      XCTAssertTrue(finished)
      updateExpectation.fulfill()
    }
    wait(for: [updateExpectation], timeout: 5)

    let marginCellSize = CGSize(width: 200, height: 200)

    let marginCellAboveIndexPath = IndexPath(item: 0, section: 0)
    verifySizeOfCell(at: marginCellAboveIndexPath, matches: marginCellSize)

    let marginCellBelowIndexPath = IndexPath(item: 2, section: 0)
    verifySizeOfCell(at: marginCellBelowIndexPath, matches: marginCellSize)
  }

  public func testSectionSizing_multipleMarginCells_expandEquallyToFillHeight_evenInDifferentSections() {
    let sizeManager = FakeSizeManagerForMarginCells()
    listController.sizeDelegate = sizeManager

    let section0models: [ListCellModel] = createCellModels(count: 2, idPrefix: "section0") + [MarginCellModel()]
    let section0 = ListSection(cellModels: section0models, identifier: "section0")

    let section1models: [ListCellModel] = createCellModels(count: 2, idPrefix: "section1") + [MarginCellModel()]
    let section1 = ListSection(cellModels: section1models, identifier: "section1")

    let updateExpectation = expectation(description: "Update Expectation")
    listController.update(with: [section0, section1], animated: false) { finished in
      XCTAssertTrue(finished)
      updateExpectation.fulfill()
    }
    wait(for: [updateExpectation], timeout: 5)

    let marginCellSize = CGSize(width: 200, height: 100)
    let marginCellSection0IndexPath = IndexPath(item: 0, section: 0)
    let marginCellSection1IndexPath = IndexPath(item: 0, section: 1)

    verifySizeOfCell(at: marginCellSection0IndexPath, matches: marginCellSize)
    verifySizeOfCell(at: marginCellSection1IndexPath, matches: marginCellSize)
  }

  public func testSectionSizing_marginCells_shrinkToHeightOf1_whenContentHeightExceedsFrame() {
    let sizeManager = FakeSizeManagerForMarginCells()
    listController.sizeDelegate = sizeManager

    let section0models: [ListCellModel] = createCellModels(count: 10, idPrefix: "section0") + [MarginCellModel()]
    let section0 = ListSection(cellModels: section0models, identifier: "section0")

    let section1models: [ListCellModel] = createCellModels(count: 10, idPrefix: "section1") + [MarginCellModel()]
    let section1 = ListSection(cellModels: section1models, identifier: "section1")

    let updateExpectation = expectation(description: "Update Expectation")
    listController.update(with: [section0, section1], animated: false) { finished in
      XCTAssertTrue(finished)
      updateExpectation.fulfill()
    }
    wait(for: [updateExpectation], timeout: 5)

    let marginCellSize = CGSize(width: 200, height: 1)
    let marginCellInSection0IndexPath = IndexPath(item: 10, section: 0)
    let marginCellInSection1IndexPath = IndexPath(item: 10, section: 1)

    verifySizeOfCell(at: marginCellInSection0IndexPath, matches: marginCellSize)
    verifySizeOfCell(at: marginCellInSection1IndexPath, matches: marginCellSize)
  }

  public func testSectionSizing_marginCells_whenDistributionIs_proportionallyWithLastCellFillingWidth() {
    // A more complicated layout since both MarginCells and proportionallyWithLastCellFillingWidth use
    // .relative cell sizing. The extra space should only be divided between the MarginCells.
    let sizeManager = FakeSizeManagerForMarginCells()
    listController.sizeDelegate = sizeManager

    // section 0 with proportionallyWithLastCellFillingWidth
    let section0models: [ListCellModel] = createCellModelsWithRelativeLastCell(count: 3)
    var section0 = ListSection(cellModels: section0models, identifier: "section-0")
    section0.constraints.distribution = .proportionallyWithLastCellFillingWidth(minimumWidth: 100)

    // section 1 with a margin cell
    let section1models: [ListCellModel] = createCellModels(count: 1) + [MarginCellModel()]
    let section1 = ListSection(cellModels: section1models, identifier: "section-1")

    let updateExpectation = expectation(description: "Update Expectation")
    listController.update(with: [section0, section1], animated: false) { finished in
      XCTAssertTrue(finished)
      updateExpectation.fulfill()
    }
    wait(for: [updateExpectation], timeout: 5)

    let marginCellIndexPath = IndexPath(item: 1, section: 1)
    let marginCellSize = CGSize(width: 200, height: 350)
    verifySizeOfCell(at: marginCellIndexPath, matches: marginCellSize)
  }

  public func testSectionSizing_marginCellsAtMinimum_whenDistributionIs_proportionallyWithLastCellFillingWidth() {
    // Same as previous test, except with enough cells that the MarginCell shrinks to it's minimum height.
    let sizeManager = FakeSizeManagerForMarginCells()
    listController.sizeDelegate = sizeManager

    // section 0 with proportionallyWithLastCellFillingWidth
    let section0models: [ListCellModel] = createCellModelsWithRelativeLastCell(count: 5)
    var section0 = ListSection(cellModels: section0models, identifier: "section-0")
    section0.constraints.distribution = .proportionallyWithLastCellFillingWidth(minimumWidth: 100)

    // section 1 with a margin cell
    let section1models: [ListCellModel] = createCellModels(count: 5) + [MarginCellModel()]
    let section1 = ListSection(cellModels: section1models, identifier: "section-1")

    let updateExpectation = expectation(description: "Update Expectation")
    listController.update(with: [section0, section1], animated: false) { finished in
      XCTAssertTrue(finished)
      updateExpectation.fulfill()
    }
    wait(for: [updateExpectation], timeout: 5)

    let marginCellIndexPath = IndexPath(item: 5, section: 1)
    let marginCellSize = CGSize(width: 200, height: 1)
    verifySizeOfCell(at: marginCellIndexPath, matches: marginCellSize)
  }
}
