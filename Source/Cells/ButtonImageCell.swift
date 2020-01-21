//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import RxSwift
import UIKit

open class ButtonImageCellModel: BaseListCellModel {

  public static let imageMargin: CGFloat = 4.0

  public let iconImage = BehaviorSubject<UIImage?>(value: nil)

  public var directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

  public var numberOfLines = 0
  public var textAlignment: NSTextAlignment = .center
  public var buttonColor: UIColor?
  public var textColor: UIColor?
  public var backgroundColor: UIColor?

  public var imageContentMode: UIView.ContentMode = .scaleAspectFit
  public var imageColor: UIColor?

  public var minimumContainerHeight: CGFloat = 0
  public var borderWidth: CGFloat = 0
  public var borderRadius: CGFloat = 4
  public var borderColor: UIColor?

  public let text: String
  public let font: UIFont
  public let imageSize: CGSize

  public init(identifier: String, imageSize: CGSize, text: String, font: UIFont) {
    self.imageSize = imageSize
    self.text = text
    self.font = font
    super.init(identifier: identifier)
  }

  public convenience init(imageSize: CGSize, text: String, font: UIFont) {
    self.init(identifier: text, imageSize: imageSize, text: text, font: font)
  }

  // MARK: - BaseListCellModel

  override open func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return numberOfLines == model.numberOfLines
      && textAlignment == model.textAlignment
      && buttonColor == model.buttonColor
      && textColor == model.textColor
      && imageContentMode == model.imageContentMode
      && imageColor == model.imageColor
      && borderWidth == model.borderWidth
      && borderRadius == model.borderRadius
      && borderColor == model.borderColor
      && text == model.text
      && font == model.font
      && imageSize == model.imageSize
      && backgroundColor == model.backgroundColor
      && directionalLayoutMargins == model.directionalLayoutMargins
      && minimumContainerHeight == model.minimumContainerHeight
  }
}

public final class ButtonImageCell: BaseReactiveListCell<ButtonImageCellModel> {
  private let label: UILabel = {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true
    return label
  }()

  private let buttonBackgroundView = UIView()

  private let marginContainer: UIView = {
    let view = UIView()
    return view
  }()

  private let imageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()

  private var imageWidthConstraint: NSLayoutConstraint?
  private var imageHeightConstraint: NSLayoutConstraint?
  private var minimumContainerHeightConstraint: NSLayoutConstraint?

  override public init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(buttonBackgroundView)
    contentView.addSubview(marginContainer)
    marginContainer.addSubview(imageView)
    marginContainer.addSubview(label)
    backgroundView = UIView()
    setupConstraints()
  }

  override public func prepareForReuse() {
    super.prepareForReuse()
    imageView.image = nil
  }

  override public func bind(model: ButtonImageCellModel, sizing: Bool) {
    super.bind(model: model, sizing: sizing)
    label.text = model.text
    label.font = model.font
    label.textAlignment = model.textAlignment
    label.numberOfLines = model.numberOfLines
    contentView.directionalLayoutMargins = model.directionalLayoutMargins
    remakeConstraints(with: model)

    guard !sizing else { return }

    imageView.contentMode = model.imageContentMode
    imageView.tintColor = model.imageColor
    label.textColor = model.textColor

    buttonBackgroundView.layer.borderWidth = model.borderWidth
    buttonBackgroundView.layer.borderColor = model.borderColor?.cgColor
    buttonBackgroundView.layer.cornerRadius = model.borderRadius
    buttonBackgroundView.backgroundColor = model.buttonColor
    backgroundView?.backgroundColor = model.backgroundColor

    model.iconImage.subscribe(onNext: { [weak self] in self?.imageView.image = $0 }).disposed(by: disposeBag)
  }
}

// MARK: - Constraints
extension ButtonImageCell {

  private func remakeConstraints(with model: ButtonImageCellModel) {
    imageWidthConstraint?.constant = model.imageSize.width
    imageHeightConstraint?.constant = model.imageSize.height
    minimumContainerHeightConstraint?.constant = model.minimumContainerHeight
  }

  private func setupConstraints() {
    let layoutGuide = contentView.layoutMarginsGuide

    buttonBackgroundView.anchorTo(layoutGuide: layoutGuide)

    marginContainer.topAnchor.constraint(
      equalTo: layoutGuide.topAnchor
    ).isActive = true
    marginContainer.bottomAnchor.constraint(
      equalTo: layoutGuide.bottomAnchor
    ).isActive = true
    marginContainer.leadingAnchor.constraint(
      greaterThanOrEqualTo: layoutGuide.leadingAnchor
    ).isActive = true
    marginContainer.trailingAnchor.constraint(
      lessThanOrEqualTo: layoutGuide.trailingAnchor
    ).isActive = true
    marginContainer.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor).isActive = true
    minimumContainerHeightConstraint = marginContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
    minimumContainerHeightConstraint?.isActive = true

    imageView.leadingAnchor.constraint(equalTo: marginContainer.leadingAnchor, constant: ButtonImageCellModel.imageMargin).isActive = true
    imageView.topAnchor.constraint(equalTo: marginContainer.topAnchor, constant: ButtonImageCellModel.imageMargin).isActive = true
    imageView.bottomAnchor.constraint(equalTo: marginContainer.bottomAnchor, constant: -ButtonImageCellModel.imageMargin).isActive = true

    imageWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 0)
    imageWidthConstraint?.isActive = true
    imageHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 0)
    imageWidthConstraint?.isActive = true

    label.leadingAnchor.constraint(
      equalTo: imageView.trailingAnchor,
      constant: ButtonImageCellModel.imageMargin
    ).isActive = true
    label.trailingAnchor.constraint(equalTo: marginContainer.trailingAnchor).isActive = true
    label.topAnchor.constraint(equalTo: marginContainer.topAnchor, constant: ButtonImageCellModel.imageMargin).isActive = true
    label.bottomAnchor.constraint(equalTo: marginContainer.bottomAnchor, constant: -ButtonImageCellModel.imageMargin).isActive = true
    marginContainer.shouldTranslateAutoresizingMaskIntoConstraints(false)
    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}
