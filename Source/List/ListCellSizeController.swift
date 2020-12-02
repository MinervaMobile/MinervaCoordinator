//
// Copyright © 2020 Optimize Fitness Inc.
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

  internal init() {}

  internal func clearCache() {
    cachedCells.removeAll()
  }

  internal func supplementarySize(
    for cellModel: ListCellModel,
    sizeConstraints: ListSizeConstraints
  ) -> CGSize {
    let size = cellModel.size(constrainedTo: sizeConstraints.containerSize)
    switch size {
    case .autolayout:
      return autolayoutSize(for: cellModel, constrainedTo: sizeConstraints)
    case let .explicit(size):
      return size
    case .relative:
      assertionFailure("Relative sizing is not supported for supplementary views")
      return autolayoutSize(for: cellModel, constrainedTo: sizeConstraints)
    }
  }

  internal func size(
    for cellModel: ListCellModel,
    at indexPath: IndexPath?,
    in section: ListSection?,
    with sizeConstraints: ListSizeConstraints,
    enableSizeByDelegate: Bool
  ) -> CGSize {
    let cellSize = listCellSize(for: cellModel, with: sizeConstraints)
    switch cellSize {
    case .autolayout:
      return autolayoutSize(for: cellModel, constrainedTo: sizeConstraints)
    case let .explicit(size):
      return size
    case .relative:
      guard
        let indexPath = indexPath,
        let section = section
      else {
        assertionFailure(
          "An indexPath and section should always be provided for .relative"
        )
        return .zero
      }

      // Handle the last cell when distribution is .proportionallyWithLastCellFillingWidth and cell opts in to .relative
      let isLastCell = (section.cellModels.count == indexPath.item + 1)
      if
        case let .proportionallyWithLastCellFillingWidth(minimumWidth) = sizeConstraints
        .distribution, isLastCell
      {
        let remainingWidth = remainingRowWidthForCell(
          at: indexPath,
          in: section,
          with: sizeConstraints
        )

        // If there isn't enough remainingWidth, size for a new row.
        let sizingWidth =
          remainingWidth >= minimumWidth
            ? remainingWidth : sizeConstraints.adjustedContainerSize.width

        let sizeToFill = CGSize(
          width: sizingWidth,
          height: sizeConstraints.adjustedContainerSize.height
        )
        return autolayoutSize(for: cellModel, fillingWidthAndLimitedByHeight: sizeToFill)
      }

      guard enableSizeByDelegate else { return .zero }

      guard
        let size = delegate?
        .sizeController(
          self,
          sizeFor: cellModel,
          at: indexPath,
          constrainedTo: sizeConstraints
        )
      else {
        assertionFailure(
          "The section controller delegate should provide a size for relative cell sizes."
        )
        return autolayoutSize(for: cellModel, constrainedTo: sizeConstraints)
      }
      return size
    }
  }

  internal func size(
    of listSection: ListSection,
    atSectionIndex sectionIndex: Int,
    with constraints: ListSizeConstraints
  ) -> CGSize {
    let isVertical = constraints.scrollDirection == .vertical
    let adjustedContainerSize = constraints.containerSize.adjust(for: listSection.constraints.inset)
    var height: CGFloat = listSection.constraints.inset.top + listSection.constraints.inset.bottom
    var width: CGFloat = listSection.constraints.inset.left + listSection.constraints.inset.right
    func adjustDimensions(for model: ListCellModel?) {
      guard let model = model else { return }
      let cellSize = size(
        for: model,
        at: nil,
        in: listSection,
        with: constraints,
        enableSizeByDelegate: false
      )
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
        height +=
          listSection.cellModels
          .reduce(
            (sum: 0, itemIndex: 0),
            { x, model -> (sum: CGFloat, itemIndex: Int) in
              let indexPath = IndexPath(item: x.itemIndex, section: sectionIndex)
              let length = size(
                for: model,
                at: indexPath,
                in: listSection,
                with: constraints,
                enableSizeByDelegate: false
              )
              .height
              let newSum = x.sum + length + constraints.minimumLineSpacing
              let newIndex = x.itemIndex + 1
              return (newSum, newIndex)
            }
          )
          .sum

        return CGSize(width: adjustedContainerSize.width, height: height)
      } else {
        width += listSection.cellModels.reduce(
          0,
          { sum, model -> CGFloat in
            let length = size(
              for: model,
              at: nil,
              in: listSection,
              with: constraints,
              enableSizeByDelegate: false
            )
            .width
            return sum + length + constraints.minimumLineSpacing
          }
        )
        return CGSize(width: width, height: adjustedContainerSize.height)
      }
    case let .equally(cellsInRow):
      guard isVertical else { fatalError("Horizontal is not yet supported") }
      var rowHeight: CGFloat = 0
      for (index, model) in listSection.cellModels.enumerated() {
        if index.isMultiple(of: cellsInRow) {
          height += (rowHeight + constraints.minimumLineSpacing)
          rowHeight = 0
        }
        let indexPath = IndexPath(item: index, section: sectionIndex)
        let modelHeight = size(
          for: model,
          at: indexPath,
          in: listSection,
          with: constraints,
          enableSizeByDelegate: false
        )
        .height
        rowHeight = max(rowHeight, modelHeight)
      }
      height += (rowHeight + constraints.minimumLineSpacing)
      return CGSize(width: adjustedContainerSize.width, height: height)
    case .proportionally, .proportionallyWithLastCellFillingWidth:
      guard isVertical else { fatalError("Horizontal is not yet supported") }
      var maxCellHeightInRow: CGFloat = 0
      var currentRowWidth: CGFloat = 0
      for (index, model) in listSection.cellModels.enumerated() {
        let indexPath = IndexPath(item: index, section: sectionIndex)
        let modelSize = size(
          for: model,
          at: indexPath,
          in: listSection,
          with: constraints,
          enableSizeByDelegate: false
        )
        let modelHeight = modelSize.height + constraints.minimumLineSpacing
        let modelWidth = modelSize.width + constraints.minimumInteritemSpacing
        maxCellHeightInRow = max(maxCellHeightInRow, modelHeight)
        currentRowWidth += modelWidth
        guard currentRowWidth <= adjustedContainerSize.width else {
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

  private func remainingRowWidthForCell(
    at indexPath: IndexPath,
    in listSection: ListSection,
    with constraints: ListSizeConstraints
  ) -> CGFloat {
    let isVertical = constraints.scrollDirection == .vertical
    guard isVertical else { fatalError("Horizontal is not yet supported") }
    let adjustedContainerSize = constraints.containerSize.adjust(for: listSection.constraints.inset)
    var maxCellHeightInRow: CGFloat = 0
    var currentRowWidth: CGFloat = 0
    var height: CGFloat = 0

    for (index, model) in listSection.cellModels[0..<indexPath.item].enumerated() {
      let indexPath = IndexPath(item: index, section: indexPath.section)
      let modelSize = size(
        for: model,
        at: indexPath,
        in: listSection,
        with: constraints,
        enableSizeByDelegate: false
      )
      let modelHeight = modelSize.height + constraints.minimumLineSpacing
      let modelWidth = modelSize.width + constraints.minimumInteritemSpacing
      maxCellHeightInRow = max(maxCellHeightInRow, modelHeight)
      currentRowWidth += modelWidth
      guard currentRowWidth <= adjustedContainerSize.width else {
        height += maxCellHeightInRow
        maxCellHeightInRow = modelHeight
        currentRowWidth = modelWidth
        continue
      }
    }

    return adjustedContainerSize.width - currentRowWidth
  }

  // MARK: - Private

  private func autolayoutSize(
    for model: ListCellModel,
    constrainedTo sizeConstraints: ListSizeConstraints
  ) -> CGSize {
    let adjustedContainerSize = sizeConstraints.adjustedContainerSize

    let collectionCell = cell(for: model)
    collectionCell.bind(cellModel: model, sizing: true)
    defer {
      collectionCell.prepareForReuse()
    }

    let view = collectionCell.contentView

    let isVertical = sizeConstraints.scrollDirection == .vertical
    switch sizeConstraints.distribution {
    case .equally, .entireRow:
      let size = view.systemLayoutSizeFitting(
        adjustedContainerSize,
        withHorizontalFittingPriority: isVertical ? .required : .fittingSizeLevel,
        verticalFittingPriority: isVertical ? .fittingSizeLevel : .required
      )
      if isVertical {
        return CGSize(width: adjustedContainerSize.width, height: size.height)
      } else {
        return CGSize(width: size.width, height: adjustedContainerSize.height)
      }

    // For .proportionallyWithLastCellFillingWidth, all cells except the last one hit this path.
    case .proportionally, .proportionallyWithLastCellFillingWidth:
      let size = view.systemLayoutSizeFitting(
        adjustedContainerSize,
        withHorizontalFittingPriority: .fittingSizeLevel,
        verticalFittingPriority: .fittingSizeLevel
      )
      if isVertical {
        return CGSize(width: min(size.width, adjustedContainerSize.width), height: size.height)
      } else {
        return CGSize(width: size.width, height: min(size.height, adjustedContainerSize.height))
      }
    }
  }

  private func autolayoutSize(
    for model: ListCellModel,
    fillingWidthAndLimitedByHeight size: CGSize
  ) -> CGSize {
    let collectionCell = cell(for: model)
    collectionCell.bind(cellModel: model, sizing: true)
    defer {
      collectionCell.prepareForReuse()
    }

    return collectionCell.contentView.systemLayoutSizeFitting(
      size,
      withHorizontalFittingPriority: .required,
      verticalFittingPriority: .fittingSizeLevel
    )
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

  private func listCellSize(for model: ListCellModel, with sizeConstraints: ListSizeConstraints)
    -> ListCellSize
  {
    let adjustedContainerSize = sizeConstraints.adjustedContainerSize
    let modelSize = model.size(constrainedTo: adjustedContainerSize)

    guard case let .explicit(size) = modelSize else {
      return modelSize
    }

    switch sizeConstraints.distribution {
    case .entireRow:
      if sizeConstraints.scrollDirection == .vertical {
        return .explicit(size: CGSize(width: adjustedContainerSize.width, height: size.height))
      } else {
        return .explicit(size: CGSize(width: size.width, height: adjustedContainerSize.height))
      }
    case .proportionally, .proportionallyWithLastCellFillingWidth, .equally:
      return modelSize
    }
  }
}
