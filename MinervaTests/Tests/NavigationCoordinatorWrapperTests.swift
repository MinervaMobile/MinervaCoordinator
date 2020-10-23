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

  private final class TestCoordinator: CoordinatorPresentable, CoordinatorNavigator {
    var navigator: Navigator
    weak var presentedCoordinator: BaseCoordinatorPresentable?
    var viewController: UIViewController
    weak var parent: Coordinator?
    var childCoordinators = [Coordinator]()

    init(viewController: UIViewController, navigator: Navigator) {
      self.viewController = viewController
      self.navigator = navigator
    }
  }
}
