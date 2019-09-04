//
//  Navigator.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

public protocol Navigator {
  typealias RemovalCompletion = (UIViewController) -> Void

  func present(
    _ viewController: UIViewController,
    animated: Bool,
    completion: RemovalCompletion?
  )

  func dismiss(_ viewController: UIViewController, animated: Bool)

  @discardableResult
  func popToRootViewController(animated: Bool) -> [UIViewController]?

  @discardableResult
  func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]?

  @discardableResult
  func popViewController(animated: Bool) -> UIViewController?

  func push(_ viewController: UIViewController, animated: Bool, completion: RemovalCompletion?)

  func setViewControllers(
    _ viewControllers: [UIViewController],
    animated: Bool,
    completion: RemovalCompletion?
  )
}

extension Navigator {

  public func push(_ viewController: UIViewController, animated: Bool) {
    push(viewController, animated: animated, completion: nil)
  }

  public func present(_ viewController: UIViewController, animated: Bool) {
    present(viewController, animated: animated, completion: nil)
  }

  public func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
    setViewControllers(viewControllers, animated: animated, completion: nil)
  }
}

public final class BasicNavigator: NSObject {
  public let navigationController: UINavigationController
  private var completions = [UIViewController: RemovalCompletion]()

  public init(navigationController: UINavigationController = UINavigationController()) {
    self.navigationController = navigationController
    super.init()
    self.navigationController.delegate = self
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
    completion: RemovalCompletion?
  ) {
    if let completion = completion {
      completions[viewController] = completion
    }
    navigationController.present(viewController, animated: animated, completion: nil)
  }

  public func dismiss(_ viewController: UIViewController, animated: Bool) {
    var viewControllers = [UIViewController]()
    func calculateDismissingViewControllers(from vc: UIViewController?) {
      guard let vc = vc else { return }

      viewControllers.append(vc)
      if let navigationController = vc as? UINavigationController {
        viewControllers.append(contentsOf: navigationController.viewControllers)
      }
      return calculateDismissingViewControllers(from: vc.presentedViewController)
    }
    if viewController.presentingViewController == nil {
      calculateDismissingViewControllers(from: viewController.presentedViewController)
    } else {
      calculateDismissingViewControllers(from: viewController)
    }

    viewController.dismiss(animated: animated) {
      viewControllers.forEach { self.runCompletion(for: $0) }
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

  public func push(
    _ viewController: UIViewController,
    animated: Bool,
    completion: RemovalCompletion?
  ) {
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
    Array(completions.keys).forEach { vc in
      guard !viewControllers.contains(vc) else { return }
      runCompletion(for: vc)
    }
  }

}

// MARK: - UINavigationControllerDelegate
extension BasicNavigator: UINavigationControllerDelegate {

  // Handles when a user swipes to go back or taps the back button in the navigation bar.
  public func navigationController(
    _ navigationController: UINavigationController,
    didShow viewController: UIViewController,
    animated: Bool
  ) {
    guard let poppingViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
      !navigationController.viewControllers.contains(poppingViewController) else {
        return
    }
    runCompletion(for: poppingViewController)
  }

}
