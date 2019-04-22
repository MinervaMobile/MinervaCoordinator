//
//  LabelAccessoryCell.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva

final class LabelAccessoryCellModel: DefaultListCellModel, ListSelectableCellModel, ListBindableCellModel {
  fileprivate static let iconTrailingLength: CGFloat = 10
  fileprivate static let accessoryImageMargin: CGFloat = 10

  // MARK: - ListSelectableCellModel
  typealias SelectableModelType = LabelAccessoryCellModel
  var selectionAction: SelectionAction?

  // MARK: - ListBindableCellModel
  typealias BindableModelType = LabelAccessoryCellModel
  var willBindAction: BindAction?

  private let cellIdentifier: String

  var textAlignment: NSTextAlignment = .left

  var iconImage: UIImage?
  var iconColor: UIColor?
  var iconImageWidthHeight: CGFloat = 14.0

  var accessoryImage: UIImage?
  var accessoryColor: UIColor?
  var accessoryImageWidthHeight: CGFloat = 14.0

  var descriptionText: NSAttributedString?

  fileprivate let attributedText: NSAttributedString

  init(identifier: String, attributedText: NSAttributedString) {
    self.cellIdentifier = identifier
    self.attributedText = attributedText
    super.init()
  }

  // MARK: - BaseListCellModel

  override var identifier: String {
    return cellIdentifier
  }

  override func isEqual(to model: ListCellModel) -> Bool {
    guard let model = model as? LabelAccessoryCellModel, super.isEqual(to: model) else {
      return false
    }
    return attributedText == model.attributedText
      && descriptionText == model.descriptionText
      && textAlignment == model.textAlignment
      && iconImage == model.iconImage
      && iconColor == model.iconColor
      && iconImageWidthHeight == model.iconImageWidthHeight
      && accessoryImage == model.accessoryImage
      && accessoryColor == model.accessoryColor
      && accessoryImageWidthHeight == model.accessoryImageWidthHeight
  }

  override func size(constrainedTo containerSize: CGSize) -> CGSize? {
    let rowWidth = containerSize.width
    let textWidth = rowWidth - LabelAccessoryCellModel.accessoryImageMargin - accessoryImageWidthHeight

    let textArray = [attributedText, descriptionText].compactMap { $0 }

    let contentHeight = max(textArray.height(constraintedToWidth: textWidth), accessoryImageWidthHeight)

    let height = contentHeight + separatorAndMarginHeight

    return CGSize(width: rowWidth, height: height)
  }
}

final class LabelAccessoryCell: DefaultListCell, ListCellHelper {
  typealias ModelType = LabelAccessoryCellModel

  private let label: UILabel = {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    return label
  }()

  private let detailsLabel: UILabel = {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    label.textAlignment = .right
    return label
  }()

  private var accessoryImageLeadingConstraint: NSLayoutConstraint?
  private var accessoryImageWidthHeightConstraint: NSLayoutConstraint?
  private let accessoryImageView: UIImageView = {
    let imageView = UIImageView(frame: .zero)
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()

  private var iconImageWidthHeightConstraint: NSLayoutConstraint?
  private var iconImageTrailingConstraint: NSLayoutConstraint?
  private let iconImageView: UIImageView = {
    let imageView = UIImageView(frame: .zero)
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    containerView.addSubview(label)
    containerView.addSubview(detailsLabel)
    containerView.addSubview(accessoryImageView)
    containerView.addSubview(iconImageView)
    setupConstraints()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("Unsupported")
    return nil
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    accessoryImageWidthHeightConstraint?.constant = 0
    accessoryImageLeadingConstraint?.constant = 0
  }

  override func updatedCellModel() {
    super.updatedCellModel()
    guard let model = self.model else {
      return
    }
    label.textAlignment = model.textAlignment
    label.attributedText = model.attributedText

    detailsLabel.attributedText = model.descriptionText

    accessoryImageView.image = model.accessoryImage
    accessoryImageView.tintColor = model.accessoryColor
    accessoryImageWidthHeightConstraint?.constant = model.accessoryImageWidthHeight

    iconImageView.tintColor = model.iconColor
    if let accessory = model.accessoryImage {
      accessoryImageView.image = accessory
      accessoryImageWidthHeightConstraint?.constant = model.accessoryImageWidthHeight
      accessoryImageLeadingConstraint?.constant = LabelAccessoryCellModel.accessoryImageMargin
    } else {
      accessoryImageView.image = nil
      accessoryImageWidthHeightConstraint?.constant = 0
      accessoryImageLeadingConstraint?.constant = 0
    }

    iconImageView.tintColor = model.iconColor
    if let icon = model.iconImage {
      iconImageView.image = icon
      iconImageWidthHeightConstraint?.constant = model.accessoryImageWidthHeight
      iconImageTrailingConstraint?.constant = LabelAccessoryCellModel.iconTrailingLength
    } else {
      iconImageView.image = nil
      iconImageWidthHeightConstraint?.constant = 0
      iconImageTrailingConstraint?.constant = 0
    }
  }
}

// MARK: - Constraints
extension LabelAccessoryCell {
  private func setupConstraints() {
    iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
    iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    iconImageWidthHeightConstraint = iconImageView.widthAnchor.constraint(equalToConstant: 0)
    iconImageWidthHeightConstraint?.isActive = true
    iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor).isActive = true

    iconImageTrailingConstraint = label.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor)
    iconImageTrailingConstraint?.isActive = true
    label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true

    detailsLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    detailsLabel.leadingAnchor.constraint(equalTo: label.trailingAnchor).isActive = true
    detailsLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    accessoryImageLeadingConstraint = accessoryImageView.leadingAnchor.constraint(equalTo: detailsLabel.trailingAnchor)
    accessoryImageLeadingConstraint?.isActive = true
    accessoryImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    accessoryImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
    accessoryImageWidthHeightConstraint = accessoryImageView.widthAnchor.constraint(equalToConstant: 0)
    accessoryImageWidthHeightConstraint?.isActive = true
    accessoryImageView.heightAnchor.constraint(equalTo: accessoryImageView.widthAnchor).isActive = true

    containerView.shouldTranslateAutoresizingMaskIntoConstraints(false)
    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}

// MARK: - Factory
extension LabelAccessoryCellModel {
  public static func createSettingsCellModel(
    title: String,
    details: String?,
    hasChevron: Bool
  ) -> LabelAccessoryCellModel {
    let text = NSAttributedString(string: title, font: .subheadline, fontColor: .black)
    let cellModel = LabelAccessoryCellModel(identifier: "\(title)-\(details ?? "")", attributedText: text)
    cellModel.accessoryImage = Asset.Disclosure.image.withRenderingMode(.alwaysTemplate)
    cellModel.accessoryColor = .darkGray
    cellModel.topMargin = 15
    cellModel.bottomMargin = 15
    cellModel.bottomSeparatorColor = .separator
    cellModel.bottomSeparatorLeftInset = true
    if !hasChevron {
      cellModel.accessoryImageWidthHeight = 0
    }
    if let details = details {
      cellModel.descriptionText = NSAttributedString(string: details, font: .subheadline, fontColor: .darkGray)
    }
    return cellModel
  }
}
