//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import UIKit

/// A simple implementation of a navigator that manages the RemovalCompletions when view controllers are no longer displayed.
public final class BasicNavigator: NSObject {

  private let parent: Navigator?
  public let navigationController: UINavigationController
  private var completions = [UIViewController: RemovalCompletion]()

  public init(
    navigationController: UINavigationController = UINavigationController(),
    parent: Navigator? = nil
  ) {
    self.parent = parent
    self.navigationController = navigationController
    super.init()
    navigationController.delegate = self
    navigationController.presentationController?.delegate = parent
  }

  // MARK: - Private

  private func runCompletion(for controller: UIViewController) {
    guard let completion = completions[controller] else { return }
    completion(controller)
    completions[controller] = nil
  }
}

// MARK: - NavigatorType
extension BasicNavigator: Navigator {

  public func present(
    _ viewController: UIViewController,
    animated: Bool,
    removalCompletion: RemovalCompletion?,
    animationCompletion: AnimationCompletion?
  ) {
    completions[viewController] = removalCompletion
    navigationController.present(viewController, animated: animated, completion: animationCompletion)
  }

  public func dismiss(
    _ viewController: UIViewController,
    animated: Bool,
    animationCompletion: AnimationCompletion?
  ) {
    var viewControllers = [UIViewController]()
    // Modal dismissal on iOS removes all modals from the current view controller down the stack.
    // This captures all view controllers that will be removed so their runCompletion blocks can be called.
    func calculateDismissingViewControllers(from viewController: UIViewController?) {
      guard let viewController = viewController else { return }
      viewControllers.append(viewController)
      if let navigationController = viewController as? UINavigationController {
        viewControllers.append(contentsOf: navigationController.viewControllers)
      }
      if let navigationController = viewController.navigationController {
        viewControllers.append(navigationController)
        calculateDismissingViewControllers(from: navigationController.presentedViewController)
      }
      calculateDismissingViewControllers(from: viewController.presentedViewController)
    }

    calculateDismissingViewControllers(from: viewController)

    viewController.dismiss(animated: animated) {
      viewControllers.forEach { self.runCompletion(for: $0) }
      animationCompletion?()
      // We need to ensure the runCompletion block is called from the correct navigator, this tells the parent
      // to dismiss the navigator in case a coordinator was presented with a new navigator.
      if let parent = self.parent {
        parent.dismiss(viewController, animated: false, animationCompletion: animationCompletion)
        return
      }
    }
  }

  public func popToRootViewController(animated: Bool) -> [UIViewController]? {
    guard let poppedControllers = navigationController.popToRootViewController(animated: animated) else {
      return nil
    }
    poppedControllers.forEach { runCompletion(for: $0) }
    return poppedControllers
  }

  public func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
    guard let poppedControllers = navigationController.popToViewController(viewController, animated: animated) else {
      return nil
    }
    poppedControllers.forEach { runCompletion(for: $0) }
    return poppedControllers
  }

  public func popViewController(animated: Bool) -> UIViewController? {
    guard let poppedController = navigationController.popViewController(animated: animated) else {
      return nil
    }
    runCompletion(for: poppedController)
    return poppedController
  }

  public func push(_ viewController: UIViewController, animated: Bool, completion: RemovalCompletion?) {
    if let completion = completion {
      completions[viewController] = completion
    }

    navigationController.pushViewController(viewController, animated: animated)
  }

  public func setViewControllers(
    _ viewControllers: [UIViewController],
    animated: Bool,
    completion: RemovalCompletion?
  ) {
    if let completion = completion {
      viewControllers.forEach { viewController in
        completions[viewController] = completion
      }
    }
    navigationController.setViewControllers(viewControllers, animated: animated)
    Array(completions.keys).forEach { viewController in
      guard !viewControllers.contains(viewController) else { return }
      runCompletion(for: viewController)
    }
  }

}

// MARK: - UIAdaptivePresentationControllerDelegate
extension BasicNavigator {

  // Handles iOS 13 Swipe to dismiss of modals.
  public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    let dismissingViewController = presentationController.presentedViewController
    runCompletion(for: dismissingViewController)
  }

  // This allows explicitly setting the modalPresentationStyle from a view controller.
  public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
    controller.presentedViewController.modalPresentationStyle
  }

  // This allows explicitly setting the modalPresentationStyle from a view controller.
  public func adaptivePresentationStyle(
    for controller: UIPresentationController,
    traitCollection: UITraitCollection
  ) -> UIModalPresentationStyle {
    controller.presentedViewController.modalPresentationStyle
  }
}

// MARK: - UINavigationControllerDelegate
extension BasicNavigator {

  // Handles when a user swipes to go back or taps the back button in the navigation bar.
  public func navigationController(
    _ navigationController: UINavigationController,
    didShow viewController: UIViewController,
    animated: Bool
  ) {
    guard let poppingViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
      return
    }
    // The view controller could be .from if it is being popped, or if another VC is being pushed. Check the
    // navigation stack to see if it is no longer there (meaning a pop).
    guard !navigationController.viewControllers.contains(poppingViewController) else {
      return
    }
    runCompletion(for: poppingViewController)
  }
}
