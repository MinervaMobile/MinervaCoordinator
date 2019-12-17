//
// Copyright © 2019 Optimize Fitness Inc.
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
  public var baseViewController: UIViewController { return viewController }
}

/// A coordinator that manages the presentation of other coordinators should implement this protocol.
public protocol CoordinatorNavigator: Coordinator {
  var navigator: Navigator { get }
}

extension CoordinatorNavigator {
  /// The block to execute after the presentation finishes.
  public typealias AnimationCompletion = () -> Void

  /// Presents a coordinator modally.
  /// - Parameter coordinator: The coordinator to display.
  /// - Parameter navigator: The navigator to use for the presented view controller.
  /// - Parameter modalPresentationStyle: The style used to present the coordinators view controller.
  /// - Parameter animated: Whether or not to animate the transition of the coordinators view controller.
  /// - Parameter animationCompletion: The completion to call when the presentation completes.
  public func present(
    _ coordinator: BaseCoordinatorPresentable,
    from navigator: Navigator,
    modalPresentationStyle: UIModalPresentationStyle = .safeAutomatic,
    animated: Bool = true,
    animationCompletion: AnimationCompletion? = nil
  ) {
    navigator.setViewControllers([coordinator.baseViewController], animated: false)
    present(
      coordinator,
      modalPresentationStyle: modalPresentationStyle,
      animated: animated,
      animationCompletion: animationCompletion
    )
  }

  /// Presents a coordinator modally.
  /// - Parameter coordinator: The coordinator to display.
  /// - Parameter modalPresentationStyle: The style used to present the coordinators view controller.
  /// - Parameter animated: Whether or not to animate the transition of the coordinators view controller.
  /// - Parameter animationCompletion: The completion to call when the presentation completes.
  public func present(
    _ coordinator: BaseCoordinatorPresentable,
    modalPresentationStyle: UIModalPresentationStyle = .safeAutomatic,
    animated: Bool = true,
    animationCompletion: AnimationCompletion? = nil
  ) {
    addChild(coordinator)

    let viewController = coordinator.baseViewController.navigationController ?? coordinator.baseViewController
    viewController.modalPresentationStyle = modalPresentationStyle
    navigator.present(
      viewController,
      animated: animated,
      removalCompletion: { [weak self] _ in self?.removeChild(coordinator) },
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
    let viewController = coordinator.baseViewController.navigationController ?? coordinator.baseViewController
    navigator.dismiss(viewController, animated: animated, animationCompletion: animationCompletion)
  }

  /// Pushes a coordinator onto the navigators navigation controller.
  /// - Parameter coordinator: The coordinator to push onto the navigation stack.
  /// - Parameter animated: Whether or not to animate the transition of the coordinators view controller.
  public func push(_ coordinator: BaseCoordinatorPresentable, animated: Bool = true) {
    addChild(coordinator)
    navigator.push(coordinator.baseViewController, animated: animated) { [weak self] _ in
      self?.removeChild(coordinator)
    }
  }

  /// Sets the coordinators view controllers in the navigation controllers stack
  /// - Parameter coordinators: The coordinators to display.
  /// - Parameter animated: Whether or not to animate the transition of the coordinators view controllers.
  public func setCoordinators(_ coordinators: [BaseCoordinatorPresentable], animated: Bool = true) {
    coordinators.forEach { addChild($0) }
    navigator.setViewControllers(
      coordinators.map { $0.baseViewController },
      animated: animated
    ) { [weak self] viewController in
      guard let coordinator = coordinators.first(where: { $0.baseViewController === viewController }) else {
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
    navigator.setViewControllers([coordinator.baseViewController], animated: animated) { [weak self] _ in
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

extension UIModalPresentationStyle {
  /// On iOS13+ this is UIModalPresentationStyle.automatic and earler versions are UIModalPresentationStyle.fullScreen
  public static var safeAutomatic: UIModalPresentationStyle {
    if #available(iOS 13, tvOS 13.0, *) {
      return .automatic
    } else {
      return .fullScreen
    }
  }
}
