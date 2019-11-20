//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxSwift
import XCTest

public final class ListTests: XCTestCase {

  private var listController: ListController!
  private var collectionVC: UICollectionViewController!

  override public func setUp() {
    super.setUp()
    collectionVC = UICollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
    listController = LegacyListController()
    listController.collectionView = collectionVC.collectionView
    listController.viewController = collectionVC
    collectionVC.view.frame = CGRect(x: 0, y: 0, width: 200, height: 500)
  }

  override public func tearDown() {
    listController = nil
    super.tearDown()
  }

  public func testDynamicSizing() {
    let sizeManager = SizeManager()
    listController.sizeDelegate = sizeManager
    let marginCellModel = MarginCellModel(location: .bottom)
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

  public func testBinding() {
    var cellModel = FakeCellModel(identifier: "FakeCellModel1", size: .explicit(size: CGSize(width: 100, height: 100)))
    var bound = false
    cellModel.willBindAction = { _ in
      bound = true
    }
    let section = ListSection(cellModels: [cellModel], identifier: "Section")

    let updateExpectation = expectation(description: "Update Expectation")
    listController.update(with: [section], animated: false) { finished in
      XCTAssertTrue(finished)
      updateExpectation.fulfill()
    }
    wait(for: [updateExpectation], timeout: 5)
    XCTAssertTrue(bound)
  }

  public func testSelection() {
    var cellModel = FakeCellModel(identifier: "FakeCellModel1", size: .explicit(size: CGSize(width: 100, height: 100)))

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
      didSelectItemAt: IndexPath(row: 0, section: 0))
    XCTAssertTrue(selected)
  }

  public func testDisplay() {
    let cellModel = FakeCellModel(identifier: "FakeCellModel1", size: .explicit(size: CGSize(width: 100, height: 100)))
    let section = ListSection(cellModels: [cellModel], identifier: "Section")

    let updateExpectation = expectation(description: "Update Expectation")
    listController.update(with: [section], animated: false) { finished in
      XCTAssertTrue(finished)
      updateExpectation.fulfill()
    }
    wait(for: [updateExpectation], timeout: 5)
    guard let cell = listController.cell(for: cellModel) as? FakeCell else {
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
    let cellModel = FakeCellModel(identifier: "FakeCellModel1", size: .explicit(size: CGSize(width: 100, height: 100)))
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
    listController.removeCellModel(at: IndexPath(row: 0, section: 0), animated: false) { finished in
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

    XCTAssertNotEqual(collectionVC.collectionView.indexPathsForVisibleItems.map { $0.row }.max(), cellModels.count - 1)
    listController.scroll(to: .bottom, animated: false)

    let updateExpectation2 = expectation(description: "Update Expectation2")
    listController.update(with: [section], animated: false) { finished in
      XCTAssertTrue(finished)
      updateExpectation2.fulfill()
    }
    wait(for: [updateExpectation2], timeout: 5)

    XCTAssertEqual(collectionVC.collectionView.indexPathsForVisibleItems.map { $0.row }.max(), cellModels.count - 1)
  }

  // MARK: - Private

  private func createCellModels(count: Int) -> [FakeCellModel] {
    return (1...count).map {
      FakeCellModel(identifier: "FakeCellModel\($0)", size: .explicit(size: CGSize(width: 100, height: 100)))
    }
  }
}

// MARK: - ListControllerSizeDelegate
public final class SizeManager: ListControllerSizeDelegate {
  public var handledSizeRequest = false

  public func listController(
    _ listController: ListController,
    sizeFor model: ListCellModel,
    at indexPath: IndexPath,
    constrainedTo sizeConstraints: ListSizeConstraints
  ) -> CGSize? {
    handledSizeRequest = true
    return .init(width: 24, height: 24)
  }

}
