//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import SwipeCellKit
import UIKit

open class SwipeableDetailedLabelCellModel: SwipeableCellModel, ListSelectableCellModel {
  fileprivate static let labelSpacing: CGFloat = 8

  public typealias Action = (_ cellModel: SwipeableDetailedLabelCellModel) -> Void

  public var deleteAction: Action?
  public var deleteColor: UIColor?
  public var swipeable = true

  fileprivate let attributedText: NSAttributedString
  fileprivate let detailsText: NSAttributedString

  public init(
    identifier: String,
    attributedText: NSAttributedString,
    detailsText: NSAttributedString
  ) {
    self.attributedText = attributedText
    self.detailsText = detailsText
    super.init(identifier: identifier)

  }

  // MARK: - BaseListCellModel

  override open func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return attributedText == model.attributedText
      && detailsText == model.detailsText
      && deleteColor == model.deleteColor
      && swipeable == model.swipeable
  }

  // MARK: - ListSelectableCellModel
  public typealias SelectableModelType = SwipeableDetailedLabelCellModel
  public var selectionAction: SelectionAction?
}

public final class SwipeableDetailedLabelCell: SwipeableCell<SwipeableDetailedLabelCellModel> {

  private let label: UILabel = {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true
    label.textAlignment = .left
    return label
  }()

  private let detailedLabel: UILabel = {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true
    label.textAlignment = .right
    return label
  }()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    containerView.addSubview(label)
    containerView.addSubview(detailedLabel)
    setupConstraints()
  }

  override public func bind(model: SwipeableDetailedLabelCellModel, sizing: Bool) {
    super.bind(model: model, sizing: sizing)
    label.attributedText = model.attributedText
    detailedLabel.attributedText = model.detailsText

    guard !sizing else { return }
    self.delegate = model
  }
}

// MARK: - Constraints
extension SwipeableDetailedLabelCell {
  private func setupConstraints() {
    label.anchor(
      toLeading: containerView.leadingAnchor,
      top: containerView.topAnchor,
      trailing: nil,
      bottom: containerView.bottomAnchor
    )
    label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    detailedLabel.leadingAnchor
      .constraint(
        equalTo: label.trailingAnchor,
        constant: SwipeableDetailedLabelCellModel.labelSpacing
      )
      .isActive = true
    detailedLabel.anchor(
      toLeading: nil,
      top: containerView.topAnchor,
      trailing: containerView.trailingAnchor,
      bottom: containerView.bottomAnchor
    )
    containerView.shouldTranslateAutoresizingMaskIntoConstraints(false)
    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}

// MARK: - SwipeCollectionViewCellDelegate
extension SwipeableDetailedLabelCellModel: SwipeCollectionViewCellDelegate {
  public func collectionView(
    _ collectionView: UICollectionView,
    editActionsForItemAt indexPath: IndexPath,
    for orientation: SwipeActionsOrientation
  ) -> [SwipeAction]? {
    guard orientation == .right, swipeable else { return nil }

    let deleteAction = SwipeAction(style: .destructive, title: "Delete") { [weak self] action, _ in
      guard let strongSelf = self else { return }
      strongSelf.deleteAction?(strongSelf)
      action.fulfill(with: .delete)
    }
    deleteAction.backgroundColor = deleteColor
    deleteAction.hidesWhenSelected = true

    return [deleteAction]
  }
}
