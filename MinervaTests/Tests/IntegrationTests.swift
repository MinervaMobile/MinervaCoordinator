//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Minerva
import RxSwift
import XCTest

public final class IntegrationTests: XCTestCase {

  private var coordinator: FakeCoordinator!

  override public func setUp() {
    super.setUp()
    coordinator = FakeCoordinator()
  }

  override public func tearDown() {
    coordinator = nil
    super.tearDown()
  }

  public func testLifecycle() {
    XCTAssertNotNil(coordinator.viewController.view)
    XCTAssert(coordinator.viewDidLoad)
    coordinator.viewController.viewWillAppear(false)
    XCTAssert(coordinator.viewWillAppear)
    coordinator.viewController.viewWillDisappear(false)
    XCTAssert(coordinator.viewWillDisappear)
    coordinator.viewController.viewDidAppear(false)
    XCTAssert(coordinator.viewDidAppear)
    coordinator.viewController.viewDidDisappear(false)
    XCTAssert(coordinator.viewDidDisappear)
    coordinator.viewController.traitCollectionDidChange(nil)
    XCTAssert(coordinator.traitCollectionDidChange)
  }

  public func testUpdate() {
    let updateExpectation = expectation(description: "Update Expectation")
    let disposable = coordinator.presenter.sections
      .observeOn(MainScheduler.instance)
      .subscribe(
        onNext: { sections in
          XCTAssertEqual(sections.count, 2)
          // Force the listcontroller to update so we dont need to wait for the animations to finish
          self.coordinator.listController.update(with: sections, animated: false) { finished in
            XCTAssert(finished)
            updateExpectation.fulfill()
          }
        }
      )
    wait(for: [updateExpectation], timeout: 5)
    disposable.dispose()

    assertCellTypesMatch(coordinator.presenter.listSections)
  }

  public func testReloadAfterReorder() {
    var sections = coordinator.presenter.listSections
    let updateExpectation1 = expectation(description: "1st Update Expectation")
    self.coordinator.listController.update(with: sections, animated: false) { finished in
      XCTAssert(finished)
      updateExpectation1.fulfill()
    }
    wait(for: [updateExpectation1], timeout: 5)

    sections = sections.map { section -> ListSection in
      var section = section
      section.cellModels.reverse()
      return section
    }

    let updateExpectation2 = expectation(description: "2nd Update Expectation")
    self.coordinator.listController.update(with: sections, animated: false) { finished in
      XCTAssert(finished)
      updateExpectation2.fulfill()
    }
    wait(for: [updateExpectation2], timeout: 5)

    assertCellTypesMatch(sections)
  }

  // MARK: - Private

  private func assertCellTypesMatch(_ sections: [ListSection]) {
    for (sectionIndex, section) in sections.enumerated() {
      for (index, model) in section.cellModels.enumerated() {
        let cell = coordinator.viewController.collectionView.cellForItem(
          at: IndexPath(item: index, section: sectionIndex)
        )!
        let modelCellType = model.cellType
        let actualCellType = type(of: cell)
        XCTAssert(modelCellType === actualCellType)
      }
    }
  }
}
