//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import RxRelay
import RxSwift
import UIKit

/// A UIViewController that contains a UISplitViewController as a child UIViewController.
public final class SplitViewContainerViewController: UIViewController {
  public let splitVC = UISplitViewController()

  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: animated)
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    addChild(splitVC)
    view.addSubview(splitVC.view)
    splitVC.view.frame = view.bounds
    splitVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    splitVC.didMove(toParent: self)
  }
}
