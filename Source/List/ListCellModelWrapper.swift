//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import IGListKit
import UIKit

/// This class should not be used directly. It wraps the requirement that all IGListKit models are NSObject's and
/// obj-c compatible.
public final class ListCellModelWrapper: NSObject {
  public let model: ListCellModel

  public init(model: ListCellModel) {
    self.model = model
  }

  override public var description: String { model.typeDescription }
}

extension ListCellModelWrapper: ListDiffable {
  public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    guard let wrapper = object as? ListCellModelWrapper else {
      assertionFailure("Unknown object type \(object.debugDescription)")
      return false
    }
    return model.identical(to: wrapper.model)
  }

  public func diffIdentifier() -> NSObjectProtocol {
    model.identifier as NSString
  }
}
