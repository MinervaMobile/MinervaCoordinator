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
  var _viewController: UIViewController { get }
}

public protocol CoordinatorPresentable: BaseCoordinatorPresentable {
  associatedtype CoordinatorVC: UIViewController

  var viewController: CoordinatorVC { get }
}

extension CoordinatorPresentable {
  public var _viewController: UIViewController { return viewController }
}

public protocol CoordinatorNavigator: Coordinator {
  var navigator: Navigator { get }
}

extension CoordinatorNavigator {

  public func present(
    _ coordinator: BaseCoordinatorPresentable,
    from navigator: Navigator,
    animated: Bool,
    modalPresentationStyle: UIModalPresentationStyle = .fullScreen
  ) {
    navigator.setViewControllers([coordinator._viewController], animated: false)
    present(coordinator, animated: true, modalPresentationStyle: modalPresentationStyle)
  }

  public func present(
    _ coordinator: BaseCoordinatorPresentable,
    animated: Bool,
    modalPresentationStyle: UIModalPresentationStyle = .fullScreen
  ) {
    addChild(coordinator)

    let viewController = coordinator._viewController.navigationController ?? coordinator._viewController
    viewController.modalPresentationStyle = modalPresentationStyle
    navigator.present(viewController, animated: animated) { [weak self] _ in
      self?.removeChild(coordinator)
    }
  }

  public func dismiss(_ coordinator: BaseCoordinatorPresentable, animated: Bool, completion: (() -> Void)? = nil) {
    let viewController = coordinator._viewController.navigationController ?? coordinator._viewController
    navigator.dismiss(viewController, animated: animated) { _ in
      completion?()
    }
  }

  public func push(_ coordinator: BaseCoordinatorPresentable, animated: Bool) {
    addChild(coordinator)
    navigator.push(coordinator._viewController, animated: animated) { [weak self] _ in
      self?.removeChild(coordinator)
    }
  }
  public func setCoordinators(_ coordinators: [BaseCoordinatorPresentable], animated: Bool) {
    coordinators.forEach { addChild($0) }
    navigator.setViewControllers(
      coordinators.map { $0._viewController },
      animated: animated
    ) { [weak self] viewController in
      guard let coordinator = coordinators.first(where: { $0._viewController === viewController }) else {
        assertionFailure("Coordinator does not exist for \(viewController)")
        return
      }
      self?.removeChild(coordinator)
    }
  }

  public func setRootCoordinator(_ coordinator: BaseCoordinatorPresentable, animated: Bool) {
    addChild(coordinator)
    navigator.setViewControllers([coordinator._viewController], animated: animated) { [weak self] _ in
      self?.removeChild(coordinator)
    }
  }
}
