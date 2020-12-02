//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import UIKit

public enum RelativeCellSizingHelper {
  /// Divide remaining vertical space to fill `sizeConstraints.containerSize` equally between all cells matching filter.
  public static func sizeOf(
    cellModel: ListCellModel,
    listController: ListController,
    constrainedTo sizeConstraints: ListSizeConstraints,
    withExcessHeightDividedEquallyBetween include: (ListCellModel) -> Bool = { _ in true }
  ) -> CGSize {
    let collectionViewBounds = sizeConstraints.containerSize
    let minHeight: CGFloat = 1
    let dynamicHeight = listController.listSections.reduce(collectionViewBounds.height) {
      sum,
        section -> CGFloat in
      sum - listController.size(of: section, containerSize: collectionViewBounds).height
    }
    let cellModels = listController.listSections.flatMap(\.cellModels)
    let marginCellCount = cellModels.reduce(0) { count, model -> Int in
      guard case .relative = model.size(constrainedTo: .zero), include(model) else { return count }
      return count + 1
    }
    let width = sizeConstraints.adjustedContainerSize.width
    guard marginCellCount > 0 else {
      return CGSize(width: width, height: minHeight)
    }
    let height = max(minHeight, dynamicHeight / CGFloat(marginCellCount))
    return CGSize(width: width, height: height)
  }
}
