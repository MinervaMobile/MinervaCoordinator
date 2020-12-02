//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import UIKit

/// Same as BasicNavigator but the navigationController var is weak.
open class NavigationCoordinatorNavigator: NavigatorCommonImpl {
  public weak var navigationController: UINavigationController? { weakNavigationController }

  public init(
    parent: Navigator?,
    navigationController: UINavigationController,
    modalPresentationStyle: UIModalPresentationStyle
  ) {
    navigationController.modalPresentationStyle = modalPresentationStyle
    super.init(parent: parent, navigationController: navigationController)
  }
}

open class NavigatorCommonImpl: NSObject {
  private final class RemovalCompletionBox {
    let completion: Navigator.RemovalCompletion

    init(_ completion: @escaping Navigator.RemovalCompletion) {
      self.completion = completion
    }
  }

  private weak var parent: Navigator?
  fileprivate weak var weakNavigationController: UINavigationController?
  private var completions: NSMapTable<UIViewController, RemovalCompletionBox>

  internal init(
    parent: Navigator?,
    navigationController: UINavigationController = UINavigationController()
  ) {
    self.completions = NSMapTable(keyOptions: .weakMemory, valueOptions: .strongMemory)
    self.parent = parent
    self.weakNavigationController = navigationController
    super.init()
    navigationController.delegate = self
    navigationController.presentationController?.delegate = parent ?? self
  }

  // MARK: - Private

  private func runCompletion(for controller: UIViewController) {
    guard let box = completions.object(forKey: controller) else { return }
    box.completion(controller)
    completions.removeObject(forKey: controller)
  }
}

// MARK: - NavigatorType

extension NavigatorCommonImpl: Navigator {
  public func present(
    _ viewController: UIViewController,
    animated: Bool,
    removalCompletion: RemovalCompletion?,
    animationCompletion: AnimationCompletion?
  ) {
    if let removalCompletion = removalCompletion {
      completions.setObject(RemovalCompletionBox(removalCompletion), forKey: viewController)
    }
    var topPresentedVC: UIViewController? = weakNavigationController
    while let vc = topPresentedVC?.presentedViewController {
      topPresentedVC = vc
    }
    topPresentedVC?.present(viewController, animated: animated, completion: animationCompletion)
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
        parent.dismiss(viewController, animated: false, animationCompletion: nil)
        return
      }
    }
  }

  @discardableResult
  public func popToRootViewController(animated: Bool) -> [UIViewController]? {
    guard
      let poppedControllers = weakNavigationController?.popToRootViewController(animated: animated)
    else {
      return nil
    }
    poppedControllers.forEach { runCompletion(for: $0) }
    return poppedControllers
  }

  public func popToViewController(_ viewController: UIViewController, animated: Bool)
    -> [UIViewController]?
  {
    guard
      let poppedControllers = weakNavigationController?
      .popToViewController(
        viewController,
        animated: animated
      )
    else {
      return nil
    }
    poppedControllers.forEach { runCompletion(for: $0) }
    return poppedControllers
  }

  public func popViewController(animated: Bool) -> UIViewController? {
    guard let poppedController = weakNavigationController?.popViewController(animated: animated)
    else {
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
      completions.setObject(RemovalCompletionBox(completion), forKey: viewController)
    }

    weakNavigationController?.pushViewController(viewController, animated: animated)
  }

  public func setViewControllers(
    _ viewControllers: [UIViewController],
    animated: Bool,
    completion: RemovalCompletion?
  ) {
    if let completion = completion {
      viewControllers.forEach { viewController in
        completions.setObject(RemovalCompletionBox(completion), forKey: viewController)
      }
    }
    weakNavigationController?.setViewControllers(viewControllers, animated: animated)
    completions.keyEnumerator().allObjects
      .forEach { key in
        guard let viewController = key as? UIViewController else { return }
        guard !viewControllers.contains(viewController) else { return }
        runCompletion(for: viewController)
      }
  }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension NavigatorCommonImpl {
  // Handles iOS 13 Swipe to dismiss of modals.
  public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    let dismissingViewController = presentationController.presentedViewController
    runCompletion(for: dismissingViewController)
  }

  // This allows explicitly setting the modalPresentationStyle from a view controller.
  public func adaptivePresentationStyle(for controller: UIPresentationController)
    -> UIModalPresentationStyle
  {
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

extension NavigatorCommonImpl {
  // Handles when a user swipes to go back or taps the back button in the navigation bar.
  public func navigationController(
    _ navigationController: UINavigationController,
    didShow viewController: UIViewController,
    animated: Bool
  ) {
    guard
      let poppingViewController = navigationController.transitionCoordinator?
      .viewController(
        forKey: .from
      )
    else {
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
