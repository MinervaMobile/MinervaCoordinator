import Foundation
import Minerva

private enum ConvenienceCellModels { }

public final class SelectableLabelCellModel: LabelCellModel, ListSelectableCellModel {
  public typealias SelectableModelType = SelectableLabelCellModel
  public var selectionAction: SelectionAction?

  override public var cellType: ListCollectionViewCell.Type { LabelCell.self }
}

public final class HighlightableLabelCellModel: LabelCellModel, ListHighlightableCellModel {

  public typealias HighlightableModelType = HighlightableLabelCellModel
  public var highlightEnabled: Bool = true
  public var highlightColor: UIColor?

  public var highlightedAction: HighlightAction?
  public var unhighlightedAction: HighlightAction?

  override public var cellType: ListCollectionViewCell.Type { LabelCell.self }

}

public final class HighlightableIconTextCellModel: IconTextCellModel, ListHighlightableCellModel {

  public typealias HighlightableModelType = HighlightableIconTextCellModel
  public var highlightEnabled: Bool = true
  public var highlightColor: UIColor?

  public var highlightedAction: HighlightAction?
  public var unhighlightedAction: HighlightAction?

  override public var cellType: ListCollectionViewCell.Type { IconTextCell.self }

}
