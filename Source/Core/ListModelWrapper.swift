//
//  ListModelWrapper.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import IGListKit

internal class ListCellModelWrapper: NSObject {
  internal let model: ListCellModel

  internal init(model: ListCellModel) {
    self.model = model
  }
  override internal var description: String {
    return model.description
  }
}

// MARK: - ListDiffable
extension ListCellModelWrapper: ListDiffable {
  internal func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    guard let wrapper = object as? ListCellModelWrapper else {
      assertionFailure("Unknown object type \(object.debugDescription)")
      return false
    }
    return model.identical(to: wrapper.model)
  }

  internal func diffIdentifier() -> NSObjectProtocol {
    return model.identifier as NSString
  }
}
