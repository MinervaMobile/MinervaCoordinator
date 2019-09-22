//
//  MarginCell.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva

final class MarginCellModel: BaseListCellModel {

  private let cellIdentifier: String

  var backgroundColor: UIColor?
  let height: CGFloat?

  init(cellIdentifier: String = "MarginCellModel", height: CGFloat? = nil) {
    self.cellIdentifier = cellIdentifier
    self.height = height
    super.init()
  }

  // MARK: - BaseListCellModel

  override var identifier: String {
    return self.cellIdentifier
  }

  override func isEqual(to model: ListCellModel) -> Bool {
    guard let model = model as? MarginCellModel else {
      return false
    }
    return backgroundColor == model.backgroundColor
      && height == model.height
  }

  override func size(constrainedTo containerSize: CGSize) -> ListCellSize {
    guard let height = self.height else { return .relative }
    let width = containerSize.width
    return .explicit(size: CGSize(width: width, height: height))
  }
}

final class MarginCell: BaseListCell, ListCellHelper {

  typealias ModelType = MarginCellModel

  override func updatedCellModel() {
    super.updatedCellModel()
    guard let model = self.model else {
      return
    }
    self.contentView.backgroundColor = model.backgroundColor
  }
}
