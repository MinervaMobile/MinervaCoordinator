//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import UIKit

@UIApplicationMain
public class CatalogAppDelegate: UIResponder, UIApplicationDelegate {
  public var window: UIWindow?
  private let coordinator = CatalogCoordinator()

  public func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.makeKeyAndVisible()
    window?.rootViewController = coordinator.viewController
    return true
  }
}
