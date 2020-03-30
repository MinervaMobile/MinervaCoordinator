//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import RxRelay
import UIKit

public protocol Presenter {
  var sections: BehaviorRelay<[ListSection]> { get }
}
