//
//  AppDelegate.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import IQKeyboardManagerSwift

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

  private var lifecycleCoordinator: LifecycleCoordinator?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    IQKeyboardManager.shared.enable = true
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.makeKeyAndVisible()

    let testData = TestData()
    let factory = TestDataManagerFactory(testData: testData)
    let userManager = TestUserManager(testData: testData, dataManagerFactory: factory)

    let lifecycleCoordinator = LifecycleCoordinator(window: window, userManager: userManager)
    self.lifecycleCoordinator = lifecycleCoordinator
    lifecycleCoordinator.launch()

    return true
  }

}
