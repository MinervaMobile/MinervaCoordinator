//
//  SwipeableLabelCell.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva

import SwipeCellKit

final class SwipeableLabelCellModel: SwipeableCellModel, ListSelectableCellModel {

  // MARK: - ListSelectableCellModel
  typealias SelectableModelType = SwipeableLabelCellModel
  var selectionAction: SelectionAction?

  typealias Action = (_ cellModel: SwipeableLabelCellModel) -> Void

  fileprivate static let buttonWidthHeight: CGFloat = 22
  fileprivate static let accessoryWidthHeight: CGFloat = 14
  fileprivate static let labelMargin: CGFloat = 8

  var deleteAction: Action?
  var editAction: Action?

  private var titleText: NSAttributedString {
    return NSAttributedString(string: title, font: .subheadline, fontColor: titleColor)
  }

  private var detailsText: NSAttributedString {
    return NSAttributedString(string: "\n\(details)", font: .footnote, fontColor: detailsColor)
  }

  fileprivate var text: NSAttributedString {
    let attributedString = NSMutableAttributedString()
    attributedString.append(titleText)
    attributedString.append(detailsText)

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 5
    attributedString.addAttribute(
      NSAttributedString.Key.paragraphStyle,
      value: paragraphStyle,
      range: NSRange(location: 0, length: attributedString.length)
    )
    return attributedString
  }

  var titleColor: UIColor = .black
  var detailsColor: UIColor = .darkGray
  var editColor: UIColor = .blue
  var deleteColor: UIColor = .red
  var separatorColor: UIColor = .separator
  private let title: String
  private let details: String
  private let cellIdentifier: String

  init(identifier: String, title: String, details: String) {
    self.cellIdentifier = identifier
    self.title = title
    self.details = details
    super.init()
    topMargin = 10
    bottomMargin = 10
  }

  // MARK: - BaseListCellModel

  override var identifier: String {
    return cellIdentifier
  }

  override func isEqual(to model: ListCellModel) -> Bool {
    guard let model = model as? SwipeableLabelCellModel, super.isEqual(to: model) else {
      return false
    }
    return title == model.title
      && details == model.details
      && titleColor == model.titleColor
      && detailsColor == model.detailsColor
      && editColor == model.editColor
      && deleteColor == model.deleteColor
      && separatorColor == model.separatorColor
  }
}

final class SwipeableLabelCell: SwipeableCell, ListCellHelper {
  typealias ModelType = SwipeableLabelCellModel

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    return label
  }()

  private let accessoryImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    containerView.addSubview(titleLabel)
    containerView.addSubview(accessoryImageView)
    setupConstraints()
  }

  override func updatedCellModel() {
    super.updatedCellModel()
    guard let model = self.model else {
      return
    }
    self.delegate = model

    contentView.backgroundColor = model.backgroundColor
    accessoryImageView.tintColor = model.detailsColor
    if model.selectionAction != nil {
      accessoryImageView.image = Asset.Disclosure.image.withRenderingMode(.alwaysTemplate)
    } else {
      accessoryImageView.image = nil
    }
    titleLabel.attributedText = model.text
  }

}

// MARK: - Constraints
extension SwipeableLabelCell {
  private func setupConstraints() {
    titleLabel.leadingAnchor.constraint(
      equalTo: containerView.leadingAnchor,
      constant: SwipeableLabelCellModel.labelMargin
    ).isActive = true
    titleLabel.trailingAnchor.constraint(
      equalTo: accessoryImageView.leadingAnchor,
      constant: -SwipeableLabelCellModel.labelMargin
    ).isActive = true

    titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
    titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true

    accessoryImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    accessoryImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
    accessoryImageView.widthAnchor.constraint(equalTo: accessoryImageView.heightAnchor).isActive = true
    accessoryImageView.anchorHeight(to: SwipeableLabelCellModel.accessoryWidthHeight)

    containerView.shouldTranslateAutoresizingMaskIntoConstraints(false)
    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}

// MARK: - SwipeCollectionViewCellDelegate
extension SwipeableLabelCellModel: SwipeCollectionViewCellDelegate {
  func collectionView(
    _ collectionView: UICollectionView,
    editActionsForItemAt indexPath: IndexPath,
    for orientation: SwipeActionsOrientation
  ) -> [SwipeAction]? {
    guard orientation == .right else { return nil }

    let deleteAction = SwipeAction(style: .destructive, title: "Delete") { [weak self] action, _ in
      guard let strongSelf = self else { return }
      strongSelf.deleteAction?(strongSelf)
      action.fulfill(with: .delete)
    }
    deleteAction.backgroundColor = deleteColor
    deleteAction.hidesWhenSelected = true

    let editAction = SwipeAction(style: .default, title: "Edit") { [weak self] action, _ in
      guard let strongSelf = self else { return }
      strongSelf.editAction?(strongSelf)
      action.fulfill(with: .reset)
    }
    editAction.backgroundColor = editColor
    editAction.hidesWhenSelected = true

    return [deleteAction, editAction]
  }
}
