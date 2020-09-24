//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import RxRelay
import UIKit

public enum ListViewControllerEvent {
  case viewDidLoad
  case viewWillAppear(animated: Bool)
  case viewWillDisappear(animated: Bool)
  case viewDidAppear(animated: Bool)
  case viewDidDisappear(animated: Bool)
  case traitCollectionDidChange(previousTraitCollection: UITraitCollection?)
}

public protocol ListViewController: UIViewController {
  var events: PublishRelay<ListViewControllerEvent> { get }

  var collectionView: UICollectionView { get }
}
