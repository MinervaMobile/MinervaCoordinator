import Foundation
import Minerva

public final class FilterCellModel: LabelAccessoryCellModel, ListSelectableCellModel {
  public typealias SelectableModelType = FilterCellModel
  public var selectionAction: SelectionAction?

  public init(
    identifier: String? = nil,
    title: String = "",
    details: String? = nil,
    hasChevron: Bool = false
  ) {
    let text = NSAttributedString(string: title, font: .subheadline, fontColor: .black)
    let id = identifier ?? "\(title)-\(details ?? "")"
    super.init(identifier: id, attributedText: text)
    accessoryImage = Asset.Disclosure.image.withRenderingMode(.alwaysTemplate)
    accessoryColor = .darkGray
    directionalLayoutMargins.top = 15
    directionalLayoutMargins.bottom = 15
    if !hasChevron {
      accessoryImageWidthHeight = 0
    }
    if let details = details {
      descriptionText = NSAttributedString(string: details, font: .subheadline, fontColor: .darkGray)
    }
  }

  override public var cellType: ListCollectionViewCell.Type { LabelAccessoryCell.self }
}
