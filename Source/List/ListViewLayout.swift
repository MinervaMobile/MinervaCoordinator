//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import IGListKit
import UIKit

/// The base layout that should be used for any collection view controlled by Minerva.
// TODO: Remove this dependency on IGListKit's ListCollectionViewLayout
open class ListViewLayout: ListCollectionViewLayout {
  override public class var layoutAttributesClass: AnyClass {
    ListViewLayoutAttributes.self
  }
}
