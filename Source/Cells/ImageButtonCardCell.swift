//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import UIKit

open class ImageButtonCardCellModel: BaseListCellModel {

  fileprivate static let labelMargin: CGFloat = 15

  public var numberOfLines = 0

  public var selectedImageColor: UIColor?
  public var selectedBackgroundColor: UIColor?

  public var directionalLayoutMargins = NSDirectionalEdgeInsets(
    top: 8,
    leading: 16,
    bottom: 8,
    trailing: 16
  )
  public var contentMode: UIView.ContentMode = .scaleAspectFit
  public var imageColor: UIColor?

  public var matchHeightToText: NSAttributedString?

  public let attributedText: NSAttributedString
  public let selectedAttributedText: NSAttributedString
  public let image: UIImage
  public let imageSize: CGSize
  public let isSelected: Bool

  public var borderWidth: CGFloat = 1.0
  public var borderRadius: CGFloat = 8.0
  public var borderColor: UIColor?
  public var maxTextWidth: CGFloat = 600

  public init(
    identifier: String,
    attributedText: NSAttributedString,
    selectedAttributedText: NSAttributedString,
    image: UIImage,
    imageSize: CGSize,
    isSelected: Bool
  ) {
    self.attributedText = attributedText
    self.selectedAttributedText = selectedAttributedText
    self.image = image
    self.imageSize = imageSize
    self.isSelected = isSelected
    super.init(identifier: identifier)
  }

  // MARK: - BaseListCellModel

  override open func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return numberOfLines == model.numberOfLines
      && attributedText == model.attributedText
      && selectedAttributedText == model.selectedAttributedText
      && selectedImageColor == model.selectedImageColor
      && selectedBackgroundColor == model.selectedBackgroundColor
      && contentMode == model.contentMode
      && imageColor == model.imageColor
      && image == model.image
      && imageSize == model.imageSize
      && borderWidth == model.borderWidth
      && borderRadius == model.borderRadius
      && borderColor == model.borderColor
      && maxTextWidth == model.maxTextWidth
      && isSelected == model.isSelected
      && matchHeightToText == model.matchHeightToText
      && directionalLayoutMargins == model.directionalLayoutMargins
  }
}

public final class ImageButtonCardCell: BaseListCell<ImageButtonCardCellModel> {

  private let buttonContainerView = UIView()

  private let label: UILabel = {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true
    return label
  }()
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()
  private let imageWidthConstraint: NSLayoutConstraint
  private let imageHeightConstraint: NSLayoutConstraint

  override public init(frame: CGRect) {
    imageWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 0)
    imageHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 0)
    super.init(frame: frame)

    contentView.addSubview(buttonContainerView)
    buttonContainerView.addSubview(label)
    buttonContainerView.addSubview(imageView)
    setupConstraints()
  }

  override public func prepareForReuse() {
    super.prepareForReuse()
    imageView.image = nil
  }

  override public func bind(model: ImageButtonCardCellModel, sizing: Bool) {
    super.bind(model: model, sizing: sizing)

    label.numberOfLines = model.numberOfLines
    label.attributedText = model.isSelected ? model.selectedAttributedText : model.attributedText

    imageWidthConstraint.constant = model.imageSize.width
    imageHeightConstraint.constant = model.imageSize.height

    contentView.directionalLayoutMargins = model.directionalLayoutMargins

    guard !sizing else { return }

    buttonContainerView.layer.borderWidth = model.borderWidth
    buttonContainerView.layer.cornerRadius = model.borderRadius
    buttonContainerView.layer.borderColor = model.borderColor?.cgColor

    imageView.contentMode = model.contentMode
    imageView.tintColor = model.isSelected ? model.selectedImageColor : model.imageColor
    imageView.image = model.image.withRenderingMode(.alwaysTemplate)

    buttonContainerView.backgroundColor = model.isSelected ? model.selectedBackgroundColor : nil
  }
}

// MARK: - Constraints
extension ImageButtonCardCell {
  private func setupConstraints() {
    buttonContainerView.anchorTo(layoutGuide: contentView.layoutMarginsGuide)

    imageView.bottomAnchor
      .constraint(
        equalTo: label.topAnchor,
        constant: -ImageButtonCardCellModel.labelMargin
      )
      .isActive = true

    imageView.topAnchor
      .constraint(
        equalTo: buttonContainerView.topAnchor,
        constant: ImageButtonCardCellModel.labelMargin
      )
      .isActive = true

    imageView.centerXAnchor.constraint(equalTo: buttonContainerView.centerXAnchor).isActive = true

    label.leadingAnchor
      .constraint(
        equalTo: buttonContainerView.leadingAnchor,
        constant: ImageButtonCardCellModel.labelMargin
      )
      .isActive = true

    label.trailingAnchor
      .constraint(
        equalTo: buttonContainerView.trailingAnchor,
        constant: -ImageButtonCardCellModel.labelMargin
      )
      .isActive = true

    label.bottomAnchor
      .constraint(
        equalTo: buttonContainerView.bottomAnchor,
        constant: -ImageButtonCardCellModel.labelMargin
      )
      .isActive = true

    imageWidthConstraint.isActive = true
    imageHeightConstraint.isActive = true

    buttonContainerView.shouldTranslateAutoresizingMaskIntoConstraints(false)
    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}
