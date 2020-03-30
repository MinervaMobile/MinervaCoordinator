//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import UIKit

public protocol ViewControllerDelegate: AnyObject {
  func viewControllerViewDidLoad(_ viewController: ViewController)
  func viewController(_ viewController: ViewController, viewWillAppear animated: Bool)
  func viewController(_ viewController: ViewController, viewWillDisappear animated: Bool)
  func viewController(_ viewController: ViewController, viewDidDisappear animated: Bool)
  func viewController(
    _ viewController: ViewController,
    traitCollectionDidChangeFrom previousTraitCollection: UITraitCollection?
  )
}

public protocol ViewController: UIViewController {
  var lifecycleDelegate: ViewControllerDelegate? { get set }
  var collectionView: UICollectionView { get }
}
