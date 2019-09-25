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
}

// MARK: - ListDiffable
extension ListCellModelWrapper: ListDiffable {
  internal func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    guard let wrapper = object as? ListCellModelWrapper else {
      return false
    }
    return model.isEqual(to: wrapper.model)
  }

  internal func diffIdentifier() -> NSObjectProtocol {
    return model.identifier as NSString
  }
}
