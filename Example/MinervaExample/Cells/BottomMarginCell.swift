//
//  BottomMarginCell.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva

struct BottomMarginCellModel: TypedListCellModel, Equatable {

  typealias CellType = BottomMarginCell

  var backgroundColor: UIColor?

  // MARK: - TypedListCellModel

  var description: String { typeDescription }
  var reorderable: Bool { false }
  var identifier: String { "BottomMarginCellModel" }

  func size(
    constrainedTo containerSize: CGSize,
    with templateProvider: () -> CellType
  ) -> ListCellSize {
    let device = UIDevice.current
    let height: CGFloat
    if device.userInterfaceIdiom == .pad && device.orientation.isLandscape {
      height = 60
    } else if device.userInterfaceIdiom == .pad {
      height = 120
    } else {
      height = 40
    }
    let width = containerSize.width
    return .explicit(size: CGSize(width: width, height: height))
  }
}

final class BottomMarginCell: BaseListCell, ListCellHelper {

  typealias ModelType = BottomMarginCellModel

  override func didUpdateCellModel() {
    super.didUpdateCellModel()
    guard let model = self.model else { return }
    self.contentView.backgroundColor = model.backgroundColor
  }
}
