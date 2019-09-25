//
//  ViewController.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

public protocol ViewControllerDelegate: AnyObject {
  func viewController(_ viewController: ViewController, viewWillAppear animated: Bool)
  func viewController(_ viewController: ViewController, viewWillDisappear animated: Bool)
  func viewController(_ viewController: ViewController, viewDidDisappear animated: Bool)
}

public protocol ViewController: AnyObject {
  var lifecycleDelegate: ViewControllerDelegate? { get set }
  var collectionView: UICollectionView { get }
}
