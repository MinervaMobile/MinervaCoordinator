//
//  Navigator.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

/// Manages the presentation of view controllers both modally and through a navigation controller.
public protocol Navigator: UIAdaptivePresentationControllerDelegate, UINavigationControllerDelegate {
  /// The block to use when a view controller is removed from the navigation controller.
  typealias RemovalCompletion = (UIViewController) -> Void

  /// Displays a view controller modally.
  /// - Parameter viewController: The view controller to display.
  /// - Parameter animated: Whether or not to animate the transition.
  /// - Parameter completion: The completion to be called when the view controller is no longer on the view stack.
  func present(_ viewController: UIViewController, animated: Bool, completion: RemovalCompletion?)

  /// Removes a modally presented view controller from the view stack.
  /// - Parameter viewController: The view controller to remove.
  /// - Parameter animated: Whether or not to animate the transition.
  /// - Parameter completion: The completion to be called when the view controller is no longer on the view stack.
  func dismiss(_ viewController: UIViewController, animated: Bool, completion: RemovalCompletion?)

  /// Displays a view controller in the navigators navigation controller.
  /// - Parameter viewController: The view controller to display.
  /// - Parameter animated: Whether or not to animate the transition.
  /// - Parameter completion: The completion to be called when the view controller is no longer on the view stack.
  func push(_ viewController: UIViewController, animated: Bool, completion: RemovalCompletion?)

  /// Sets the view controller's in the navigators navigation controller.
  /// - Parameter viewControllers: The view controllers to display.
  /// - Parameter animated: Whether or not to animate the transition.
  /// - Parameter completion: The completion to be called when the view controller is no longer on the view stack.
  func setViewControllers(_ viewControllers: [UIViewController], animated: Bool, completion: RemovalCompletion?)

  /// Removes all but the top view controller from the Navigator's navigation controller.
  /// - Parameter animated: Whether or not to animate the transition.
  @discardableResult
  func popToRootViewController(animated: Bool) -> [UIViewController]?

  /// Removes all view controller's above the provided view controller from the Navigator's navigation controller.
  /// - Parameter viewController: The view controller to display.
  /// - Parameter animated: Whether or not to animate the transition.
  @discardableResult
  func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]?

  /// Removes the top navigation controller from the navigation stack.
  /// - Parameter animated: Whether or not to animate the transition.
  @discardableResult
  func popViewController(animated: Bool) -> UIViewController?
}

extension Navigator {

  /// Displays a view controller modally.
  /// - Parameter viewController: The view controller to display.
  /// - Parameter animated: Whether or not to animate the transition.
  public func present(_ viewController: UIViewController, animated: Bool) {
    present(viewController, animated: animated, completion: nil)
  }

  /// Removes a modally presented view controller from the view stack.
  /// - Parameter viewController: The view controller to remove.
  /// - Parameter animated: Whether or not to animate the transition.
  public func dismiss(_ viewController: UIViewController, animated: Bool) {
    dismiss(viewController, animated: animated, completion: nil)
  }

  /// Displays a view controller in the navigators navigation controller.
  /// - Parameter viewController: The view controller to display.
  /// - Parameter animated: Whether or not to animate the transition.
  public func push(_ viewController: UIViewController, animated: Bool) {
    push(viewController, animated: animated, completion: nil)
  }

  /// Sets the view controller's in the navigators navigation controller.
  /// - Parameter viewControllers: The view controllers to display.
  /// - Parameter animated: Whether or not to animate the transition.
  public func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
    setViewControllers(viewControllers, animated: animated, completion: nil)
  }
}
