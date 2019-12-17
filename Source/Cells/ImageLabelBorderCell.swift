//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import RxSwift
import UIKit

open class ImageLabelBorderCellModel: BaseListCellModel {

  fileprivate static let labelMargin: CGFloat = 15

  public var isSelected = BehaviorSubject<Bool>(value: false)

  fileprivate let text: String
  fileprivate let font: UIFont

  public var directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
  public var textAlignment: NSTextAlignment = .center
  public var numberOfLines = 0

  public var selectedTextColor: UIColor?
  public var selectedImageColor: UIColor?
  public var selectedBackgroundColor: UIColor?
  public var textColor: UIColor?

  public var contentMode: UIView.ContentMode = .scaleAspectFit
  public var imageColor: UIColor?
  public let image: UIImage
  public let imageSize: CGSize

  public var borderWidth: CGFloat = 1.0
  public var borderRadius: CGFloat = 8.0
  public var borderColor: UIColor?
  public var maxTextWidth: CGFloat = 600

  public init(
    identifier: String,
    text: String,
    font: UIFont,
    image: UIImage,
    imageSize: CGSize
  ) {
    self.text = text
    self.font = font
    self.image = image
    self.imageSize = imageSize
    super.init(identifier: identifier)
  }

  public convenience init(text: String, font: UIFont, image: UIImage, imageSize: CGSize) {
    self.init(identifier: text, text: text, font: font, image: image, imageSize: imageSize)
  }

  // MARK: - BaseListCellModel

  override public func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return text == model.text
      && font == model.font
      && textAlignment == model.textAlignment
      && numberOfLines == model.numberOfLines
      && selectedTextColor == model.selectedTextColor
      && selectedImageColor == model.selectedImageColor
      && selectedBackgroundColor == model.selectedBackgroundColor
      && textColor == model.textColor
      && contentMode == model.contentMode
      && imageColor == model.imageColor
      && image == model.image
      && imageSize == model.imageSize
      && borderWidth == model.borderWidth
      && borderRadius == model.borderRadius
      && borderColor == model.borderColor
      && maxTextWidth == model.maxTextWidth
      && directionalLayoutMargins == model.directionalLayoutMargins
  }
}

public final class ImageLabelBorderCell: BaseReactiveListCell<ImageLabelBorderCellModel> {

  private let label: UILabel = {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true
    return label
  }()
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()
  private let buttonContainerView = UIView()

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

  override public func bind(model: ImageLabelBorderCellModel, sizing: Bool) {
    super.bind(model: model, sizing: sizing)

    label.numberOfLines = model.numberOfLines
    label.text = model.text
    label.font = model.font
    label.textAlignment = model.textAlignment

    imageWidthConstraint.constant = model.imageSize.width
    imageHeightConstraint.constant = model.imageSize.height

    guard !sizing else { return }

    buttonContainerView.layer.borderWidth = model.borderWidth
    buttonContainerView.layer.cornerRadius = model.borderRadius
    buttonContainerView.layer.borderColor = model.borderColor?.cgColor

    label.textColor = model.textColor

    imageView.contentMode = model.contentMode
    if let imageColor = model.imageColor {
      imageView.image = model.image.withRenderingMode(.alwaysTemplate)
      imageView.tintColor = imageColor
    } else {
      imageView.image = model.image
    }

    model.isSelected.subscribe(onNext: { [weak self, weak model] isSelected -> Void in
      self?.label.textColor = isSelected ? model?.selectedTextColor : model?.textColor
      self?.imageView.tintColor = isSelected ? model?.selectedImageColor : model?.imageColor
      self?.buttonContainerView.backgroundColor = isSelected ? model?.selectedBackgroundColor : nil
    }).disposed(by: disposeBag)
  }
}

// MARK: - Constraints
extension ImageLabelBorderCell {
  private func setupConstraints() {

    buttonContainerView.anchorTo(layoutGuide: contentView.layoutMarginsGuide)

    imageView.bottomAnchor.constraint(
      equalTo: label.topAnchor,
      constant: -ImageLabelBorderCellModel.labelMargin
    ).isActive = true

    imageView.topAnchor.constraint(
      equalTo: buttonContainerView.topAnchor,
      constant: ImageLabelBorderCellModel.labelMargin
    ).isActive = true

    imageView.centerXAnchor.constraint(equalTo: buttonContainerView.centerXAnchor).isActive = true

    label.leadingAnchor.constraint(
      equalTo: buttonContainerView.leadingAnchor,
      constant: ImageLabelBorderCellModel.labelMargin
    ).isActive = true

    label.trailingAnchor.constraint(
      equalTo: buttonContainerView.trailingAnchor,
      constant: -ImageLabelBorderCellModel.labelMargin
    ).isActive = true

    label.bottomAnchor.constraint(
      equalTo: buttonContainerView.bottomAnchor,
      constant: -ImageLabelBorderCellModel.labelMargin
    ).isActive = true

    imageWidthConstraint.isActive = true
    imageHeightConstraint.isActive = true

    buttonContainerView.shouldTranslateAutoresizingMaskIntoConstraints(false)
    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}
