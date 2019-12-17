import Foundation
import Minerva

public final class SelectableLabelCellModel: LabelCellModel, ListSelectableCellModel {
  public typealias SelectableModelType = SelectableLabelCellModel
  public var selectionAction: SelectionAction?

  override public var cellType: ListCollectionViewCell.Type { LabelCell.self }
}
