//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import UIKit

/// A simple implementation of a navigator that manages the RemovalCompletions when view controllers are no longer displayed.
open class BasicNavigator: NavigatorCommonImpl {
  public let navigationController: UINavigationController

  override public init(
    parent: Navigator?,
    navigationController: UINavigationController = UINavigationController()
  ) {
    self.navigationController = navigationController
    super.init(parent: parent, navigationController: navigationController)
  }

  deinit {
    navigationController.setViewControllers([], animated: false)
  }
}
