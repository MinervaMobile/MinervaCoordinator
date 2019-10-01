//
//  MarginCell.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva

struct MarginCellModel: TypedListCellModel {

  typealias CellType = MarginCell

  let identifier: String

  var backgroundColor: UIColor?
  let height: CGFloat?

  init(cellIdentifier: String = "MarginCellModel", height: CGFloat? = nil) {
    self.identifier = cellIdentifier
    self.height = height
  }

  // MARK: - BaseListCellModel

  var reorderable: Bool { false }

  func identical(to model: MarginCellModel) -> Bool {
    return backgroundColor == model.backgroundColor
      && height == model.height
  }

  func size(
    constrainedTo containerSize: CGSize,
    with templateProvider: () -> CellType
  ) -> ListCellSize {
    guard let height = self.height else { return .relative }
    let width = containerSize.width
    return .explicit(size: CGSize(width: width, height: height))
  }
}

final class MarginCell: BaseListCell, ListCellHelper {

  typealias ModelType = MarginCellModel

  override func updatedCellModel() {
    super.updatedCellModel()
    guard let model = self.model else { return }
    self.contentView.backgroundColor = model.backgroundColor
  }
}
