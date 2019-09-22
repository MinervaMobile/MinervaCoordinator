//
//  BottomMarginCell.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva

final class BottomMarginCellModel: BaseListCellModel {
  var backgroundColor: UIColor?

  // MARK: - BaseListCellModel

  override var identifier: String {
    return "BottomMarginCellModel"
  }

  override func isEqual(to model: ListCellModel) -> Bool {
    guard let model = model as? BottomMarginCellModel else {
      return false
    }
    return backgroundColor == model.backgroundColor
  }

  override func size(constrainedTo containerSize: CGSize) -> ListCellSize {
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

  override func updatedCellModel() {
    super.updatedCellModel()
    guard let model = self.model else { return }
    self.contentView.backgroundColor = model.backgroundColor
  }
}

