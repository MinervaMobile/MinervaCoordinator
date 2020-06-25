//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva

public struct FakeCellModel: ListTypedCellModel, ListSelectableCellModel,
  ListHighlightableCellModel, ListReorderableCellModel
{
  public typealias CellType = FakeCell

  public typealias SelectableModelType = FakeCellModel
  public var selectionAction: SelectionAction?

  public typealias HighlightableModelType = FakeCellModel
  public var highlightEnabled: Bool = true
  public var highlightColor: UIColor?

  public var highlightedAction: HighlightAction?
  public var unhighlightedAction: HighlightAction?

  public var reorderable: Bool = true

  public var identifier: String
  public var size: ListCellSize

  public func identical(to model: FakeCellModel) -> Bool {
    size == model.size
      && highlightEnabled == model.highlightEnabled
      && highlightColor == model.highlightColor
      && reorderable == model.reorderable
  }

  public func size(constrainedTo containerSize: CGSize) -> ListCellSize {
    size
  }
}

public final class FakeCell: ListCollectionViewCell, ListTypedCell, ListDisplayableCell {
  public var handledWillDisplay = false
  public var handledDidEndDisplaying = false

  public var displaying = false

  public func bind(model: FakeCellModel, sizing: Bool) {}
  public func bindViewModel(_ viewModel: Any) { bind(viewModel) }

  public func willDisplayCell() {
    handledWillDisplay = true
    displaying = true
  }

  public func didEndDisplayingCell() {
    handledDidEndDisplaying = true
    displaying = false
  }
}

/// Used to test the last item in Distribution.proportionallyWithLastCellFillingWidth
public final class ExpandingTextInputCellModel: TextInputCellModel {
  override public var cellType: ListCollectionViewCell.Type { TextInputCell.self }

  public init(identifier: String, placeholder: String) {
    super.init(identifier: identifier, placeholder: placeholder, font: .systemFont(ofSize: 16))
  }

  override public func size(constrainedTo containerSize: CGSize) -> ListCellSize {
    .relative
  }
}

public func createCellModels(count: Int) -> [FakeCellModel] {
  (1...count)
    .map {
      FakeCellModel(
        identifier: "FakeCellModel\($0)",
        size: .explicit(size: CGSize(width: 75, height: 100))
      )
    }
}

public func createCellModelsWithRelativeLastCell(count: Int) -> [ListCellModel] {
  var cells: [ListCellModel] = (1..<count)
    .map {
      FakeCellModel(
        identifier: "FakeCellModel\($0)",
        size: .explicit(size: CGSize(width: 50, height: 50))
      )
    }
  let lastCell = ExpandingTextInputCellModel(identifier: "LastCellThatFillsWidth", placeholder: "input")
  cells.append(lastCell)
  return cells
}
