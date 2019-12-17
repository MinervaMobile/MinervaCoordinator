//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import IGListKit
import UIKit

internal protocol ListCellSizeControllerDelegate: AnyObject {

  func sizeController(
    _ sizeController: ListCellSizeController,
    sizeFor model: ListCellModel,
    at indexPath: IndexPath,
    constrainedTo sizeConstraints: ListSizeConstraints
  ) -> CGSize?

}

internal final class ListCellSizeController {
  private typealias CellType = String
  internal weak var delegate: ListCellSizeControllerDelegate?

  private var cachedCells = [CellType: ListCollectionViewCell]()

  internal init() {
  }

  internal func clearCache() {
    cachedCells.removeAll()
  }

  internal func supplementarySize(for cellModel: ListCellModel, sizeConstraints: ListSizeConstraints) -> CGSize {
    let size = cellModel.size(constrainedTo: sizeConstraints.containerSize) {
      self.cell(for: cellModel)
    }
    switch size {
    case .autolayout:
      return autolayoutSize(for: cellModel, constrainedTo: sizeConstraints)
    case .explicit(let size):
      return size
    case .relative:
      assertionFailure("Relative sizing is not supported for supplementary views")
      return autolayoutSize(for: cellModel, constrainedTo: sizeConstraints)
    }
  }

  internal func size(
    for cellModel: ListCellModel,
    at indexPath: IndexPath,
    sizeConstraints: ListSizeConstraints
  ) -> CGSize {
    let cellSize = listCellSize(for: cellModel, with: sizeConstraints)
    switch cellSize {
    case .autolayout:
      return autolayoutSize(for: cellModel, constrainedTo: sizeConstraints)
    case .explicit(let size):
      return size
    case .relative:
      guard let size = self.delegate?.sizeController(
        self,
        sizeFor: cellModel,
        at: indexPath,
        constrainedTo: sizeConstraints
      ) else {
        assertionFailure("The section controller delegate should provide a size for relative cell sizes.")
        return autolayoutSize(for: cellModel, constrainedTo: sizeConstraints)
      }
      return size
    }
  }

  internal func size(for model: ListCellModel, with sizeConstraints: ListSizeConstraints) -> CGSize {
    let size = listCellSize(for: model, with: sizeConstraints)
    switch size {
    case .autolayout:
      return autolayoutSize(for: model, constrainedTo: sizeConstraints)
    case .explicit(let size):
      return size
    case .relative:
      return .zero
    }
  }

  internal func size(of listSection: ListSection, with constraints: ListSizeConstraints) -> CGSize {
    let isVertical = constraints.scrollDirection == .vertical
    let adjustedContainerSize = constraints.containerSize.adjust(for: listSection.constraints.inset)
    var height: CGFloat = listSection.constraints.inset.top + listSection.constraints.inset.bottom
    var width: CGFloat = listSection.constraints.inset.left + listSection.constraints.inset.right
    func adjustDimensions(for model: ListCellModel?) {
      guard let model = model else { return }
      let cellSize = size(for: model, with: constraints)
      if isVertical {
        height += cellSize.height
      } else {
        width += cellSize.width
      }
    }
    adjustDimensions(for: listSection.headerModel)
    adjustDimensions(for: listSection.footerModel)

    switch listSection.constraints.distribution {
    case .entireRow:
      if isVertical {
        height += listSection.cellModels.reduce(0, { sum, model -> CGFloat in
          let length = size(for: model, with: constraints).height
          return sum + length + constraints.minimumLineSpacing
        })
        return CGSize(width: adjustedContainerSize.width, height: height)
      } else {
        width += listSection.cellModels.reduce(0, { sum, model -> CGFloat in
          let length = size(for: model, with: constraints).width
          return sum + length + constraints.minimumLineSpacing
        })
        return CGSize(width: width, height: adjustedContainerSize.height)
      }
    case .equally(let cellsInRow):
      guard isVertical else { fatalError("Horizontal is not yet supported") }
      var rowHeight: CGFloat = 0
      for (index, model) in listSection.cellModels.enumerated() {
        if index.isMultiple(of: cellsInRow) {
          height += (rowHeight + constraints.minimumLineSpacing)
          rowHeight = 0
        }
        let modelHeight = size(for: model, with: constraints).height
        rowHeight = max(rowHeight, modelHeight)
      }
      height += (rowHeight + constraints.minimumLineSpacing)
      return CGSize(width: adjustedContainerSize.width, height: height)
    case .proportionally:
      guard isVertical else { fatalError("Horizontal is not yet supported") }
      var maxCellHeightInRow: CGFloat = 0
      var currentRowWidth: CGFloat = 0
      for model in listSection.cellModels {
        let modelSize = size(for: model, with: constraints)
        let modelHeight = modelSize.height + constraints.minimumLineSpacing
        let modelWidth = modelSize.width + constraints.minimumInteritemSpacing
        maxCellHeightInRow = max(maxCellHeightInRow, modelHeight)
        currentRowWidth += modelWidth
        guard currentRowWidth < adjustedContainerSize.width else {
          height += maxCellHeightInRow
          maxCellHeightInRow = modelHeight
          currentRowWidth = modelWidth
          continue
        }
      }
      height += maxCellHeightInRow
      return CGSize(width: adjustedContainerSize.width, height: height)
    }
  }

  // MARK: - Private

  private func autolayoutSize(for model: ListCellModel, constrainedTo sizeConstraints: ListSizeConstraints) -> CGSize {
    let adjustedContainerSize = sizeConstraints.adjustedContainerSize

    let collectionCell = cell(for: model)
    collectionCell.bind(cellModel: model, sizing: true)
    defer {
      collectionCell.prepareForReuse()
    }

    let view = collectionCell.contentView

    switch sizeConstraints.distribution {
    case .equally, .entireRow:
      let isVertical = sizeConstraints.scrollDirection == .vertical
      let size = view.systemLayoutSizeFitting(
        adjustedContainerSize,
        withHorizontalFittingPriority: isVertical ? .required : .fittingSizeLevel,
        verticalFittingPriority: isVertical ? .fittingSizeLevel : .required)
      if isVertical {
        return CGSize(width: adjustedContainerSize.width, height: size.height)
      } else {
        return CGSize(width: size.width, height: adjustedContainerSize.height)
      }
    case .proportionally:
      let size = view.systemLayoutSizeFitting(
        adjustedContainerSize,
        withHorizontalFittingPriority: .fittingSizeLevel,
        verticalFittingPriority: .fittingSizeLevel)
      return size
    }
  }

  private func cell(for model: ListCellModel) -> ListCollectionViewCell {
    let cellType = String(describing: model.cellType)
    if let cell = cachedCells[cellType] {
      return cell
    } else {
      let cell = model.cellType.init(frame: .zero)
      cachedCells[cellType] = cell
      return cell
    }
  }

  private func listCellSize(for model: ListCellModel, with sizeConstraints: ListSizeConstraints) -> ListCellSize {
    let adjustedContainerSize = sizeConstraints.adjustedContainerSize
    let modelSize = model.size(constrainedTo: adjustedContainerSize) {
      self.cell(for: model)
    }

    guard case .explicit(let size) = modelSize else {
      return modelSize
    }

    switch sizeConstraints.distribution {
    case .entireRow:
      if sizeConstraints.scrollDirection == .vertical {
        return .explicit(size: CGSize(width: adjustedContainerSize.width, height: size.height))
      } else {
        return .explicit(size: CGSize(width: size.width, height: adjustedContainerSize.height))
      }
    case .proportionally, .equally:
      return modelSize
    }
  }
}
