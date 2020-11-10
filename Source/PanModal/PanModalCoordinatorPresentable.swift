//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import PanModal
import UIKit

public protocol PanModalCoordinatorPresentable: BaseCoordinatorPresentable {
  var panModalPresentableVC: PanModalPresentable & UIViewController { get }
}
