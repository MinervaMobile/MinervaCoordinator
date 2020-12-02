//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import SwipeCellKit
import UIKit

open class SwipeableLabelCellModel: SwipeableCellModel {
  public typealias Action = (_ cellModel: SwipeableLabelCellModel) -> Void

  public var deleteAction: Action?
  public var deleteColor: UIColor?
  public var swipeable = true

  fileprivate let attributedText: NSAttributedString

  public init(identifier: String, attributedText: NSAttributedString) {
    self.attributedText = attributedText
    super.init(identifier: identifier)
  }

  // MARK: - BaseListCellModel

  override open func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return attributedText.string == model.attributedText.string
      && deleteColor == model.deleteColor
      && swipeable == model.swipeable
  }
}

public final class SwipeableLabelCell: SwipeableCell<SwipeableLabelCellModel> {
  private let label: UILabel = {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true
    return label
  }()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    containerView.addSubview(label)
    setupConstraints()
  }

  override public func bind(model: SwipeableLabelCellModel, sizing: Bool) {
    super.bind(model: model, sizing: sizing)

    label.attributedText = model.attributedText

    guard !sizing else { return }
    delegate = model
  }
}

// MARK: - Constraints

extension SwipeableLabelCell {
  private func setupConstraints() {
    label.anchor(to: containerView)
    containerView.shouldTranslateAutoresizingMaskIntoConstraints(false)
    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}

// MARK: - SwipeCollectionViewCellDelegate

extension SwipeableLabelCellModel: SwipeCollectionViewCellDelegate {
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
