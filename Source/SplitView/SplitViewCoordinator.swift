//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import RxRelay
import RxSwift
import UIKit

public typealias SplitChildCoordinator = BaseCoordinatorPresentable & CoordinatorNavigator

/// A Coordinator handles the state transition between Coordinators within a splitview environment
open class SplitViewCoordinator<T: SplitChildCoordinator, U: SplitChildCoordinator>: CoordinatorNavigator,
  CoordinatorPresentable,
  UISplitViewControllerDelegate
{
  public typealias CoordinatorVC = SplitViewContainerViewController

  public enum Action {
    case splitViewWillCollapse
    case splitViewWillExpand
  }

  public let actionsRelay = PublishRelay<Action>()
  public let viewController = SplitViewContainerViewController()
  public var splitViewController: UISplitViewController {
    viewController.splitVC
  }
  public let navigator: Navigator

  public var presentedCoordinator: BaseCoordinatorPresentable?
  public var parent: Coordinator?
  public var childCoordinators: [Coordinator] = []

  public let splitNavigator: SplitNavigator
  public let masterCoordinator: T
  public let defaultDetailCoordinator: U

  private var displayedDetailCoordinator: SplitChildCoordinator?

  private var masterNavigator: BasicNavigator {
    splitNavigator.masterNavigator
  }

  private var detailNavigator: BasicNavigator {
    splitNavigator.detailNavigator
  }

  /// - Parameter navigator: Navigator that manages this class.
  /// - Parameter masterCoordinatorCreator: A closure with a `BasicNavigator` parameter
  ///   that manages the Coordinator created in the closure.
  ///   Builds the Coordinator whose view controller will be used as the default master(left) view controller
  /// - Parameter detailCoordinatorCreator: A closure with a `BasicNavigator` parameter
  ///   that manages the Coordinator created in the closure.
  ///   Builds the Coordinator whose view controller will be used as the default detail(right) view controller
  public init(
    navigator: Navigator,
    masterCoordinatorCreator: (BasicNavigator) -> T,
    detailCoordinatorCreator: (BasicNavigator) -> U
  ) {
    self.navigator = navigator
    let masterNavigator = BasicNavigator(parent: navigator)
    let detailNavigator = BasicNavigator(parent: navigator)

    self.splitNavigator = SplitNavigator(
      masterNavigator: masterNavigator,
      detailNavigator: detailNavigator
    )

    masterCoordinator = masterCoordinatorCreator(masterNavigator)
    defaultDetailCoordinator = detailCoordinatorCreator(detailNavigator)
    splitViewController.delegate = self
    displayedDetailCoordinator = defaultDetailCoordinator

    masterNavigator.setViewControllers([masterCoordinator.baseViewController], animated: false)
    detailNavigator.setViewControllers(
      [defaultDetailCoordinator.baseViewController],
      animated: false
    )

    splitViewController.viewControllers = [
      masterNavigator.navigationController, detailNavigator.navigationController
    ]
  }

  // MARK: - UISplitViewControllerDelegate
  public func splitViewController(
    _ splitViewController: UISplitViewController,
    collapseSecondary secondaryViewController: UIViewController,
    onto primaryViewController: UIViewController
  ) -> Bool {
    // always return true here because the view controllers stacks are reconfigured in 2 methods below
    true
  }

  // will enter regular mode
  public func primaryViewController(forCollapsing splitViewController: UISplitViewController)
    -> UIViewController?
  {
    // set master as active detail so any new coordinators get added to the correct navigators stack
    splitNavigator.setMasterNavigatorActive()
    // dismiss any presented coordinators before we reset the navigators' stacks
    dismissAllSplitPresentedCoordinators()
    // Reset master and remove detail view controllers before we transition to a regular environment
    splitNavigator.resetViewControllersForCompactMode()
    actionsRelay.accept(.splitViewWillCollapse)
    return masterNavigator.navigationController
  }

  // will enter split view
  public func splitViewController(
    _ splitViewController: UISplitViewController,
    separateSecondaryFrom primaryViewController: UIViewController
  ) -> UIViewController? {
    // set detail as active detail so any new coordinators get added to the correct navigators' stack
    splitNavigator.setDetailNavigatorActive()
    // dismiss any presented coordinators before we reset the navigators' stacks
    dismissAllSplitPresentedCoordinators()
    // Reset the master and detail view controllers before we transition to a splitview enivornment
    splitNavigator.resetViewControllersForRegularMode(
      defaultDetailViewController: defaultDetailCoordinator.baseViewController
    )
    actionsRelay.accept(.splitViewWillExpand)
    return detailNavigator.navigationController
  }

  // MARK: - Public

  /// Sets the Detail Coordinator depending on the UISplitView collapsed environment
  ///
  /// If splitview is collapsed and showing only master view push the coordinator on master coordinator's stack
  ///
  /// Otherwise, strongly retain the new coordinator and reset the detail navigators stack
  /// to only contain the new coordinators baseViewController
  ///
  /// - Parameter coordinator: Navigator that manages this class.
  /// - Parameter masterPushAnimated: Whether or not to animate the transition of pushing view controller on master
  /// - Parameter detailReplaceAnimated: Whether or not to animate the transition of setting view controller stack
  public func setDetailCoordinator(
    _ coordinator: SplitChildCoordinator,
    masterPushAnimated: Bool = true,
    detailReplaceAnimated: Bool = false
  ) {
    if splitViewController.isCollapsed {
      masterCoordinator.push(coordinator, animated: masterPushAnimated)
    } else {
      displayedDetailCoordinator = coordinator
      detailNavigator.setViewControllers(
        [coordinator.baseViewController],
        animated: detailReplaceAnimated,
        completion: nil
      )
    }
  }

  // MARK: - Helpers

  private func dismissAllSplitPresentedCoordinators() {
    masterCoordinator.dismissAllPresentedCoordinators()
    displayedDetailCoordinator?.dismissAllPresentedCoordinators()
  }
}
