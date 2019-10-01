//
//  BaseListCellModel.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

open class BaseListCellModel: ListCellModel {

  public init() { }

  // MARK: - ListCellModel

  open var reorderable: Bool {
    return false
  }
  open var identifier: String {
    return typeIdentifier
  }
  open var cellType: ListCollectionViewCell.Type {
    return cellTypeFromModelName
  }
  open func identical(to model: ListCellModel) -> Bool {
    return identifier == model.identifier
  }
  open func size(
    constrainedTo containerSize: CGSize,
    with templateProvider: () -> ListCollectionViewCell
  ) -> ListCellSize {
    return .autolayout
  }
}
