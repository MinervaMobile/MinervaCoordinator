//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxSwift
import XCTest

public final class NavigationCoordinatorWrapperTests: XCTestCase {
  public func testPresentationFromNavigator() {
    let viewController = UIViewController()
    let tag = 77
    viewController.view.tag = tag

    let wrapped = NavigationCoordinatorWrapper { navigator -> BaseCoordinatorPresentable in
      TestCoordinator(viewController: viewController, navigator: navigator)
    }

    XCTAssertEqual(wrapped.viewController.viewControllers.first?.view.tag, tag)
  }
}

public final class TestCoordinatorPresentable: CoordinatorPresentable {
  public var viewController: UIViewController
  public weak var parent: Coordinator?
  public var childCoordinators = [Coordinator]()

  public init(
    viewController: UIViewController = UIViewController()
  ) {
    self.viewController = viewController
  }
}

public final class TestCoordinator: CoordinatorPresentable, CoordinatorNavigator {
  public var navigator: Navigator
  public weak var presentedCoordinator: BaseCoordinatorPresentable?
  public var viewController: UIViewController
  public weak var parent: Coordinator?
  public var childCoordinators = [Coordinator]()

  public init(
    viewController: UIViewController = UIViewController(),
    navigator: Navigator = BasicNavigator(parent: nil)
  ) {
    self.viewController = viewController
    self.navigator = navigator
  }
}
