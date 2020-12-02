//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import UIKit

/// A Coordinator handles the state transition between Coordinators. This logic was previously part of the UIViewController's.
public protocol Coordinator: AnyObject {
  var parent: Coordinator? { get set }
  var childCoordinators: [Coordinator] { get set }
}

extension Coordinator {
  /// Strongly retains a child coordinator and sets its parent to the current coordinator.
  /// - Parameter coordinator: The child to retain strongly.
  public func addChild(_ coordinator: Coordinator) {
    coordinator.parent = self
    childCoordinators.append(coordinator)
  }

  /// Removes the coordinator if it is the child.  Removes based on direct object reference comparison.
  /// - Parameter coordinator: The child to remove.
  public func removeChild(_ coordinator: Coordinator) {
    childCoordinators = childCoordinators.filter { $0 !== coordinator }
  }
}

/// This should not be used directly, it is used to work around the associatedtype in CoordinatorPresentable.
public protocol BaseCoordinatorPresentable: Coordinator {
  var baseViewController: UIViewController { get }
}

/// A coordinator that manages a specific view controller and can be displated should implement this protocol.
public protocol CoordinatorPresentable: BaseCoordinatorPresentable {
  associatedtype CoordinatorVC: UIViewController

  var viewController: CoordinatorVC { get }
}

extension CoordinatorPresentable {
  public var baseViewController: UIViewController { viewController }
}

/// A coordinator that manages the presentation of other coordinators should implement this protocol.
public protocol CoordinatorNavigator: Coordinator {
  var navigator: Navigator { get }
  var presentedCoordinator: BaseCoordinatorPresentable? { get set }
}

extension CoordinatorNavigator {
  /// The block to execute after the presentation finishes.
  public typealias AnimationCompletion = () -> Void

  /// Presents a coordinator modally.
  /// - Parameter coordinator: The coordinator to display.
  /// - Parameter modalPresentationStyle: The style used to present the coordinators view controller.
  /// - Parameter animated: Whether or not to animate the transition of the coordinators view controller.
  /// - Parameter animationCompletion: The completion to call when the presentation completes.
  public func present(
    _ coordinator: BaseCoordinatorPresentable,
    modalPresentationStyle: UIModalPresentationStyle? = nil,
    animated: Bool = true,
    animationCompletion: AnimationCompletion? = nil
  ) {
    addChild(coordinator)
    presentedCoordinator = coordinator
    let viewController =
      coordinator.baseViewController.navigationController
        ?? coordinator.baseViewController
    if let modalPresentationStyle = modalPresentationStyle {
      viewController.modalPresentationStyle = modalPresentationStyle
    }
    navigator.present(
      viewController,
      animated: animated,
      removalCompletion: { [weak self, weak coordinator] _ in
        guard let coordinator = coordinator else { return }
        self?.removeChild(coordinator)
      },
      animationCompletion: animationCompletion
    )
  }

  /// Removes the coordinator from the view heiarchy if it was presented modally.
  /// - Parameter coordinator: The coordinator to remove.
  /// - Parameter animated: Whether or not to animate the transition of the coordinators view controller.
  /// - Parameter animationCompletion: The completion to call when the coordinator is no longer on the screen
  public func dismiss(
    _ coordinator: BaseCoordinatorPresentable,
    animated: Bool = true,
    animationCompletion: AnimationCompletion? = nil
  ) {
    let viewController =
      coordinator.baseViewController.navigationController
        ?? coordinator.baseViewController
    navigator.dismiss(viewController, animated: animated, animationCompletion: animationCompletion)
    presentedCoordinator = nil
  }

  /// Recursively dismiss any presented coordintor and/or any child which has a presented coordinator.
  /// - Parameter animated: Whether dismissal should be animated.
  public func dismissAllPresentedCoordinators(animated: Bool = false) {
    guard let presentedCoordinator = presentedCoordinator else { return }
    dismiss(presentedCoordinator, animated: animated)
    childCoordinators.compactMap { $0 as? CoordinatorNavigator }
      .forEach { $0.dismissAllPresentedCoordinators(animated: animated) }
  }

  /// Pushes a coordinator onto the navigators navigation controller.
  /// - Parameter coordinator: The coordinator to push onto the navigation stack.
  /// - Parameter animated: Whether or not to animate the transition of the coordinators view controller.
  public func push(_ coordinator: BaseCoordinatorPresentable, animated: Bool = true) {
    addChild(coordinator)
    navigator.push(coordinator.baseViewController, animated: animated) {
      [weak self, weak coordinator] _ in
      guard let coordinator = coordinator else { return }
      self?.removeChild(coordinator)
    }
  }

  /// Sets the coordinators view controllers in the navigation controllers stack
  /// - Parameter coordinators: The coordinators to display.
  /// - Parameter animated: Whether or not to animate the transition of the coordinators view controllers.
  public func setCoordinators(_ coordinators: [BaseCoordinatorPresentable], animated: Bool = true) {
    coordinators.forEach { addChild($0) }
    let weakCoordinators = coordinators.map({ WeakBaseCoordinatorPresentable($0) })
    navigator.setViewControllers(
      coordinators.map(\.baseViewController),
      animated: animated
    ) { [weak self] viewController in
      let weakCoordinator = weakCoordinators.first {
        $0.coordinator?.baseViewController === viewController
      }
      guard let coordinator = weakCoordinator?.coordinator else {
        assertionFailure("Coordinator does not exist for \(viewController)")
        return
      }
      self?.removeChild(coordinator)
    }
  }

  /// Sets the root view controller on the navigators navigation controller to the given coordinators view controller.
  /// - Parameter coordinator: The coordinator to display
  /// - Parameter animated: Whether or not to animate the transition of the coordinators view controller.
  public func setRootCoordinator(_ coordinator: BaseCoordinatorPresentable, animated: Bool = true) {
    addChild(coordinator)
    navigator.setViewControllers([coordinator.baseViewController], animated: animated) {
      [weak self, weak coordinator] _ in
      guard let coordinator = coordinator else { return }
      self?.removeChild(coordinator)
    }
  }

  /// Pops a coordinator from the navigators navigation controller.
  /// - Parameter animated: Whether or not to animate the transition of the coordinators view controller.
  public func pop(animated: Bool = true) {
    _ = navigator.popViewController(animated: animated)
  }

  /// Pops to a coordinator on the navigators navigation controller.
  /// - Parameter coordinator: The coordinator to pop the navigation stack to.
  /// - Parameter animated: Whether or not to animate the transition of the coordinators view controller.
  public func popToCoordinator(_ coordinator: BaseCoordinatorPresentable, animated: Bool = true) {
    _ = navigator.popToViewController(coordinator.baseViewController, animated: animated)
  }
}

private class WeakBaseCoordinatorPresentable {
  weak var coordinator: BaseCoordinatorPresentable?

  init(_ coordinator: BaseCoordinatorPresentable?) {
    self.coordinator = coordinator
  }
}
