//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva

// MARK: - ListControllerSizeDelegate
public final class FakeSizeManager: ListControllerSizeDelegate {
  public var handledSizeRequest = false

  public func listController(
    _ listController: ListController,
    sizeFor model: ListCellModel,
    at indexPath: IndexPath,
    constrainedTo sizeConstraints: ListSizeConstraints
  ) -> CGSize? {
    handledSizeRequest = true
    return .init(width: 24, height: 24)
  }
}

public final class FakeSizeManagerForMarginCells: ListControllerSizeDelegate {
  public func listController(
    _ listController: ListController,
    sizeFor model: ListCellModel,
    at indexPath: IndexPath,
    constrainedTo sizeConstraints: ListSizeConstraints
  ) -> CGSize? {
    if model is MarginCellModel {
      return RelativeCellSizingHelper.sizeOf(
        cellModel: model,
        withExcessHeightDividedEquallyBetween: { $0 is MarginCellModel },
        listController: listController,
        constrainedTo: sizeConstraints
      )
    } else {
      return nil
    }
  }
}
