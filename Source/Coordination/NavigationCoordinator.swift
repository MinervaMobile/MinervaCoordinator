//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import UIKit

/// Parent coordinator preserved by the lifecycle of the navigation controller it's responsible for
/// Use this like, e.g.:
///
/// ```
/// /// let navigationCoordinator = NavigationCoordinator()
/// navigationCoordinator.setRootCoordinator(someOtherCoordinator)
/// someOtherController.present(navigationCoordinator.viewController, animated: true)
/// ```
///
/// This will tie the lifetime of the Coordinators to the lifetime of the presentation of the navigation controller.
open class NavigationCoordinator: NSObject, CoordinatorNavigator, CoordinatorPresentable {
  public let navigator: Navigator
  public var viewController: UINavigationController { navigationController }
  public weak var presentedCoordinator: BaseCoordinatorPresentable?

  public var parent: Coordinator?
  public var childCoordinators: [Coordinator] = []
  private unowned let navigationController: UINavigationController

  public init(
    navigationController: UINavigationController,
    modalPresentationStyle: UIModalPresentationStyle
  ) {
    self.navigationController = navigationController
    self.navigator = NavigationCoordinatorNavigator(
      parent: nil,
      navigationController: navigationController,
      modalPresentationStyle: modalPresentationStyle
    )

    super.init()

    // ties our lifetime to the navigation controller's lifecycle
    objc_setAssociatedObject(
      navigationController,
      &associatedObjectKeyLifecycle,
      self,
      .OBJC_ASSOCIATION_RETAIN_NONATOMIC
    )
  }
}

private var associatedObjectKeyLifecycle = ""
