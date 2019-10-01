//
//  ListModelWrapper.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import IGListKit

public final class ListCellModelWrapper: NSObject {
  public let model: ListCellModel

  public init(model: ListCellModel) {
    self.model = model
  }

  override public var description: String {
    return model.description
  }
}

// MARK: - ListDiffable
extension ListCellModelWrapper: ListDiffable {
  public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    guard let wrapper = object as? ListCellModelWrapper else {
      assertionFailure("Unknown object type \(object.debugDescription)")
      return false
    }
    return model.identical(to: wrapper.model)
  }

  public func diffIdentifier() -> NSObjectProtocol {
    return model.identifier as NSString
  }
}
