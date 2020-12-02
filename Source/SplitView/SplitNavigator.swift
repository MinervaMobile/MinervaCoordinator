//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import RxSwift
import UIKit

/// Manages the presentation of view controllers between two navigators in a split view environment.
public class SplitNavigator: NSObject {
  private enum ActiveNavigatorType {
    case master
    case detail
  }

  public let masterNavigator: BasicNavigator
  public let detailNavigator: BasicNavigator

  private var activeNavigatorType: ActiveNavigatorType

  private var activeDetailNavigator: BasicNavigator {
    switch activeNavigatorType {
    case .master: return masterNavigator
    case .detail: return detailNavigator
    }
  }

  /// - Parameter masterNavigator: `BasicNavigator` that manages master coordinators.
  /// - Parameter detailNavigator: `BasicNavigator` that manages detail coordinators.
  public init(masterNavigator: BasicNavigator, detailNavigator: BasicNavigator) {
    self.masterNavigator = masterNavigator
    self.detailNavigator = detailNavigator
    self.activeNavigatorType = .detail
  }

  /// Sets activeDetailNavigator to point to the masterNavigator.
  public func setMasterNavigatorActive() {
    activeNavigatorType = .master
  }

  /// Sets activeDetailNavigator to point to the detailNavigator.
  public func setDetailNavigatorActive() {
    activeNavigatorType = .detail
  }

  /// Resets master navigator view controller stack to contain only ViewControllers.
  /// Removes all ViewControllers from detail coordinator stack
  public func resetViewControllersForCompactMode(animated: Bool = false) {
    masterNavigator.setViewControllers(
      masterNavigator.navigationController.viewControllers,
      animated: animated
    )
    detailNavigator.setViewControllers([], animated: animated)
  }

  // Resets master navigator view controller stack to only contain its root
  ///
  /// - Parameter defaultDetailViewController: `UIViewController` to set as the root
  ///   ViewController for the detail navigator
  /// - Parameter animated: Whether or not to animate the view controller transitions
  public func resetViewControllersForRegularMode(
    defaultDetailViewController: UIViewController,
    animated: Bool = false
  ) {
    masterNavigator.popToRootViewController(animated: animated)
    detailNavigator.setViewControllers(
      [defaultDetailViewController],
      animated: animated,
      completion: nil
    )
  }
}

// MARK: - NavigatorType

extension SplitNavigator: Navigator {
  public func setViewControllers(
    _ viewControllers: [UIViewController],
    animated: Bool,
    completion: RemovalCompletion?
  ) {
    activeDetailNavigator
      .setViewControllers(viewControllers, animated: animated, completion: completion)
  }

  public func push(
    _ viewController: UIViewController,
    animated: Bool,
    completion: RemovalCompletion?
  ) {
    activeDetailNavigator.push(viewController, animated: animated, completion: completion)
  }

  public func dismiss(
    _ viewController: UIViewController,
    animated: Bool,
    animationCompletion: AnimationCompletion?
  ) {
    activeDetailNavigator
      .dismiss(viewController, animated: animated, animationCompletion: animationCompletion)
  }

  public func present(
    _ viewController: UIViewController,
    animated: Bool,
    removalCompletion: RemovalCompletion?,
    animationCompletion: AnimationCompletion?
  ) {
    activeDetailNavigator
      .present(viewController, animated: animated, removalCompletion: removalCompletion)
  }

  public func popToRootViewController(animated: Bool) -> [UIViewController]? {
    activeDetailNavigator.popToRootViewController(animated: animated)
  }

  public func popToViewController(_ viewController: UIViewController, animated: Bool)
    -> [UIViewController]?
  {
    activeDetailNavigator.popToViewController(viewController, animated: animated)
  }

  public func popViewController(animated: Bool) -> UIViewController? {
    activeDetailNavigator.popViewController(animated: animated)
  }
}
