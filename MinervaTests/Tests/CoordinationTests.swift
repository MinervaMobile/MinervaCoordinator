//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxSwift
import XCTest

public final class CoordinationTests: XCTestCase {

  private var rootCoordinator: FakeCoordinator!
  private var navigator: BasicNavigator!

  override public func setUp() {
    super.setUp()
    navigator = BasicNavigator(parent: nil)
    rootCoordinator = FakeCoordinator(navigator: navigator)
    navigator.setViewControllers([rootCoordinator.viewController], animated: false, completion: nil)
    UIApplication.shared.windows.first?.rootViewController = navigator.navigationController
  }

  override public func tearDown() {
    rootCoordinator = nil
    UIApplication.shared.windows.first?.rootViewController = nil
    super.tearDown()
  }

  public func testPresentation() {
    XCTAssertNotNil(rootCoordinator.viewController.view)
    let childCoordinator = FakeCoordinator()
    let presentationExpectation = expectation(description: "Presentation")
    rootCoordinator.present(childCoordinator, animated: false) {
      presentationExpectation.fulfill()
    }
    wait(for: [presentationExpectation], timeout: 5)

    XCTAssertTrue(rootCoordinator.childCoordinators.contains { $0 === childCoordinator })

    let dismissalExpectation = expectation(description: "Dismissal")
    rootCoordinator.dismiss(childCoordinator) {
      dismissalExpectation.fulfill()
    }
    wait(for: [dismissalExpectation], timeout: 5)
    XCTAssertTrue(rootCoordinator.childCoordinators.isEmpty)
  }

  public func testPresentationFromNavigator() {
    XCTAssertNotNil(rootCoordinator.viewController.view)
    let navigator = BasicNavigator(parent: nil)
    let childCoordinator = FakeCoordinator()
    let presentationExpectation = expectation(description: "Presentation")
    navigator.setViewControllers([childCoordinator.baseViewController], animated: false)
    rootCoordinator.present(childCoordinator, animated: false) {
      presentationExpectation.fulfill()
    }
    wait(for: [presentationExpectation], timeout: 5)

    XCTAssertTrue(rootCoordinator.childCoordinators.contains { $0 === childCoordinator })

    let dismissalExpectation = expectation(description: "Dismissal")
    rootCoordinator.dismiss(childCoordinator) {
      dismissalExpectation.fulfill()
    }
    wait(for: [dismissalExpectation], timeout: 5)
    XCTAssertTrue(rootCoordinator.childCoordinators.isEmpty)
  }

  public func testStackedPresentationFromNavigator() {
    XCTAssertNotNil(rootCoordinator.viewController.view)
    let vcA = UIViewController()
    let vcB = UIViewController()

    let presentationExpectationA = expectation(description: "Presentation")
    navigator.present(vcA, animated: true, removalCompletion: nil) {
      presentationExpectationA.fulfill()
    }
    wait(for: [presentationExpectationA], timeout: 5)

    let presentationExpectationB = expectation(description: "Presentation")
    navigator.present(vcB, animated: true, removalCompletion: nil) {
      presentationExpectationB.fulfill()
    }
    wait(for: [presentationExpectationB], timeout: 5)

    XCTAssertEqual(navigator.navigationController.presentedViewController, vcA)
    XCTAssertEqual(vcA.presentedViewController, vcB)

  }

  public func testDismissalFromNavigator() {
    XCTAssertNotNil(rootCoordinator.viewController.view)
    let childCoordinator = FakeCoordinator()
    let navigator = BasicNavigator(parent: rootCoordinator.navigator)
    let presentationExpectation = expectation(description: "Presentation")
    navigator.setViewControllers([childCoordinator.baseViewController], animated: false)
    rootCoordinator.present(childCoordinator, animated: false) {
      presentationExpectation.fulfill()
    }
    wait(for: [presentationExpectation], timeout: 5)

    XCTAssertTrue(rootCoordinator.childCoordinators.contains { $0 === childCoordinator })

    let dismissalExpectation = expectation(description: "Dismissal")
    dismissalExpectation.assertForOverFulfill = false
    navigator.dismiss(childCoordinator.viewController, animated: false) {
      dismissalExpectation.fulfill()
    }
    wait(for: [dismissalExpectation], timeout: 5)
    XCTAssertTrue(rootCoordinator.childCoordinators.isEmpty)
  }

  public func testPushAndPop() {
    XCTAssertNotNil(rootCoordinator.viewController.view)
    let childCoordinator = FakeCoordinator(navigator: rootCoordinator.navigator)
    rootCoordinator.push(childCoordinator, animated: false)
    XCTAssertTrue(rootCoordinator.childCoordinators.contains { $0 === childCoordinator })
    XCTAssertTrue(
      navigator.navigationController.viewControllers.contains {
        $0 === childCoordinator.viewController
      }
    )
    rootCoordinator.pop(animated: false)
    XCTAssertFalse(rootCoordinator.childCoordinators.contains { $0 === childCoordinator })
  }

  public func testPopToRoot() {
    XCTAssertNotNil(rootCoordinator.viewController.view)
    (1...5)
      .forEach { _ in
        let childCoordinator = FakeCoordinator(navigator: rootCoordinator.navigator)
        rootCoordinator.push(childCoordinator, animated: false)
        XCTAssertTrue(rootCoordinator.childCoordinators.contains { $0 === childCoordinator })
        XCTAssertTrue(
          navigator.navigationController.viewControllers.contains {
            $0 === childCoordinator.viewController
          }
        )
      }
    _ = navigator.popToRootViewController(animated: false)
    XCTAssertEqual(navigator.navigationController.viewControllers.count, 1)
    XCTAssertTrue(rootCoordinator.childCoordinators.isEmpty)
  }

  public func testPopToCoordinator() {
    XCTAssertNotNil(rootCoordinator.viewController.view)
    (1...5)
      .forEach { _ in
        let childCoordinator = FakeCoordinator(navigator: rootCoordinator.navigator)
        rootCoordinator.push(childCoordinator, animated: false)
        XCTAssertTrue(rootCoordinator.childCoordinators.contains { $0 === childCoordinator })
        XCTAssertTrue(
          navigator.navigationController.viewControllers.contains {
            $0 === childCoordinator.viewController
          }
        )
      }
    rootCoordinator.popToCoordinator(
      rootCoordinator.childCoordinators.first! as! FakeCoordinator,
      animated: false
    )
    XCTAssertEqual(navigator.navigationController.viewControllers.count, 2)
    XCTAssertEqual(rootCoordinator.childCoordinators.count, 1)
  }

  public func testSetCoordinators() {
    XCTAssertNotNil(rootCoordinator.viewController.view)
    (1...5)
      .forEach { _ in
        let childCoordinator = FakeCoordinator(navigator: rootCoordinator.navigator)
        rootCoordinator.push(childCoordinator, animated: false)
        XCTAssertTrue(rootCoordinator.childCoordinators.contains { $0 === childCoordinator })
        XCTAssertTrue(
          navigator.navigationController.viewControllers.contains {
            $0 === childCoordinator.viewController
          }
        )
      }
    let childCoordinator = FakeCoordinator(navigator: rootCoordinator.navigator)
    rootCoordinator.setCoordinators([childCoordinator], animated: false)
    XCTAssertEqual(navigator.navigationController.viewControllers.count, 1)
    XCTAssertEqual(rootCoordinator.childCoordinators.count, 1)
    XCTAssertTrue(rootCoordinator.childCoordinators[0] === childCoordinator)
  }

}
