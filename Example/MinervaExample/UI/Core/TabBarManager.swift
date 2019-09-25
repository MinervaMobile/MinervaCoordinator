//
//  TabBarManager.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

protocol TabBarManager: AnyObject {
  var tabBarIsHidden: Bool { get set }
  var tabHeight: CGFloat { get }
}
