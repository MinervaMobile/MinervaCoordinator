//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import UIKit

/// Puts a Coordinator's VC in a navigator's navigation controller.
public final class NavigationCoordinatorWrapper: CoordinatorPresentable {
  public let viewController: UINavigationController
  public weak var parent: Coordinator?
  public var childCoordinators = [Coordinator]()

  private let navigator: Navigator

  public init(wrapped: (Navigator) -> BaseCoordinatorPresentable,
              navigationController: UINavigationController = UINavigationController()) {
    let basicNavigator = BasicNavigator(parent: nil,
                                        navigationController: navigationController)
    self.viewController = basicNavigator.navigationController
    self.navigator = basicNavigator

    let coordinator = wrapped(basicNavigator)
    basicNavigator.navigationController.setViewControllers(
      [coordinator.baseViewController],
      animated: false
    )
    childCoordinators.append(coordinator)
  }
}
