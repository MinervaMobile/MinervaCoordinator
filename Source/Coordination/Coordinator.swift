//
//  Coordinator.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

public protocol Coordinator: AnyObject {
  var parent: Coordinator? { get set }
  var childCoordinators: [Coordinator] { get set }
}

extension Coordinator {
  public func addChild(_ coordinator: Coordinator) {
    coordinator.parent = self
    childCoordinators.append(coordinator)
  }

  public func removeChild(_ coordinator: Coordinator) {
    childCoordinators = childCoordinators.filter { $0 !== coordinator }
  }
}

public protocol BaseCoordinatorPresentable: Coordinator {
  var baseViewController: UIViewController { get }
}

public protocol CoordinatorPresentable: BaseCoordinatorPresentable {
  associatedtype CoordinatorVC: UIViewController

  var viewController: CoordinatorVC { get }
}

extension CoordinatorPresentable {
  public var baseViewController: UIViewController { return viewController }
}

public protocol CoordinatorNavigator: Coordinator {
  var navigator: Navigator { get }
}

extension CoordinatorNavigator {

  public func present(
    _ coordinator: BaseCoordinatorPresentable,
    from navigator: Navigator,
    animated: Bool = true,
    modalPresentationStyle: UIModalPresentationStyle = .fullScreen
  ) {
    navigator.setViewControllers([coordinator.baseViewController], animated: false)
    present(coordinator, animated: animated, modalPresentationStyle: modalPresentationStyle)
  }

  public func present(
    _ coordinator: BaseCoordinatorPresentable,
    animated: Bool = true,
    modalPresentationStyle: UIModalPresentationStyle = .fullScreen
  ) {
    addChild(coordinator)

    let viewController = coordinator.baseViewController.navigationController ?? coordinator.baseViewController
    viewController.modalPresentationStyle = modalPresentationStyle
    navigator.present(viewController, animated: animated) { [weak self] _ in
      self?.removeChild(coordinator)
    }
  }

  public func dismiss(
    _ coordinator: BaseCoordinatorPresentable,
    animated: Bool = true,
    completion: (() -> Void)? = nil
  ) {
    let viewController = coordinator.baseViewController.navigationController ?? coordinator.baseViewController
    navigator.dismiss(viewController, animated: animated) { _ in
      completion?()
    }
  }

  public func push(_ coordinator: BaseCoordinatorPresentable, animated: Bool = true) {
    addChild(coordinator)
    navigator.push(coordinator.baseViewController, animated: animated) { [weak self] _ in
      self?.removeChild(coordinator)
    }
  }
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

  public func setRootCoordinator(_ coordinator: BaseCoordinatorPresentable, animated: Bool = true) {
    addChild(coordinator)
    navigator.setViewControllers([coordinator.baseViewController], animated: animated) { [weak self] _ in
      self?.removeChild(coordinator)
    }
  }
}
