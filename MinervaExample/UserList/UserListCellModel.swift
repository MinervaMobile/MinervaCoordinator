import Foundation
import Minerva
import UIKit

public final class UserListCellModel: SwipeableLabelCellModel, ListSelectableCellModel {
  public let user: User

  public init(user: User) {
    self.user = user

    super
      .init(
        identifier: user.description,
        attributedText: NSAttributedString(
          string: "\(user.email)\n\(user.dailyCalories)",
          font: .body,
          fontColor: .label
        )
      )
    backgroundColor = .systemBackground
  }

  override public var cellType: ListCollectionViewCell.Type {
    SwipeableLabelCell.self
  }

  override public func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return user.proto == model.user.proto
  }

  // MARK: - ListSelectableCellModel

  public typealias SelectableModelType = UserListCellModel
  public var selectionAction: SelectionAction?
}
