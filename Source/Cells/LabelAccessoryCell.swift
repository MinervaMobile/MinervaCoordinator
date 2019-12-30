//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import RxSwift
import UIKit

open class LabelAccessoryCellModel: BaseListCellModel {
  public typealias Action = (_ model: LabelAccessoryCellModel) -> Void

  public static let iconTrailingLength: CGFloat = 10
  public static let accessoryImageMargin: CGFloat = 10

  public var iconSelectionAction: Action?
  public var accessorySelectionAction: Action?

  public let iconImage = BehaviorSubject<UIImage?>(value: nil)
  public var directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)

  public var iconColor: UIColor?
  public var iconImageWidthHeight: CGFloat = 0
  public var iconCornerRadius: CGFloat = 0
  public var iconImageContentMode: UIView.ContentMode = .scaleAspectFit
  public var detailsTextResistCompression = true
  public var backgroundColor: UIColor?

  public var accessoryImage: UIImage?
  public var accessoryColor: UIColor?
  public var accessoryImageWidthHeight: CGFloat = 14.0

  public var textAlignment: NSTextAlignment = .left
  public var descriptionText: NSAttributedString?

  public let attributedText: NSAttributedString

  public init(identifier: String, attributedText: NSAttributedString) {
    self.attributedText = attributedText
    super.init(identifier: identifier)
  }

  // MARK: - BaseListCellModel

  override open func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return attributedText == model.attributedText
      && descriptionText == model.descriptionText
      && textAlignment == model.textAlignment
      && iconColor == model.iconColor
      && iconCornerRadius == model.iconCornerRadius
      && iconImageWidthHeight == model.iconImageWidthHeight
      && accessoryImage == model.accessoryImage
      && accessoryColor == model.accessoryColor
      && accessoryImageWidthHeight == model.accessoryImageWidthHeight
      && detailsTextResistCompression == model.detailsTextResistCompression
      && backgroundColor == model.backgroundColor
      && directionalLayoutMargins == model.directionalLayoutMargins
  }
}

public final class LabelAccessoryCell: BaseReactiveListCell<LabelAccessoryCellModel> {

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
    imageView.clipsToBounds = true
    return imageView
  }()

  private let iconTapView = UIView()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(label)
    contentView.addSubview(detailsLabel)
    contentView.addSubview(accessoryImageView)
    contentView.addSubview(iconImageView)
    contentView.addSubview(iconTapView)

    backgroundView = UIView()

    setupConstraints()
    let iconGesture = UITapGestureRecognizer(target: self, action: #selector(iconPressed))
    iconTapView.addGestureRecognizer(iconGesture)

    let accessoryGesture = UITapGestureRecognizer(target: self, action: #selector(accessoryPressed))
    accessoryImageView.addGestureRecognizer(accessoryGesture)
  }

  override public func prepareForReuse() {
    super.prepareForReuse()
    accessoryImageView.image = nil
    iconImageView.image = nil
  }

  @objc
  private func iconPressed(_ sender: UITapGestureRecognizer) {
    guard let model = model else { return }
    model.iconSelectionAction?(model)
  }

  @objc
  private func accessoryPressed(_ sender: UITapGestureRecognizer) {
    guard let model = model else { return }
    model.accessorySelectionAction?(model)
  }

  override public func bind(model: LabelAccessoryCellModel, sizing: Bool) {
    super.bind(model: model, sizing: sizing)

    label.textAlignment = model.textAlignment
    label.attributedText = model.attributedText

    detailsLabel.attributedText = model.descriptionText
    let detailsPriority: UILayoutPriority = model.detailsTextResistCompression ? .required : .defaultHigh
    detailsLabel.setContentCompressionResistancePriority(detailsPriority, for: .horizontal)

    contentView.directionalLayoutMargins = model.directionalLayoutMargins

    remakeConstraints(with: model)

    guard !sizing else { return }

    accessoryImageView.image = model.accessoryImage
    accessoryImageView.tintColor = model.accessoryColor
    accessoryImageView.isUserInteractionEnabled = model.accessorySelectionAction != nil
    accessoryImageView.isUserInteractionEnabled = model.accessorySelectionAction != nil

    iconImageView.tintColor = model.iconColor
    iconImageView.layer.cornerRadius = model.iconCornerRadius
    iconImageView.contentMode = model.iconImageContentMode
    iconImageView.isUserInteractionEnabled = model.iconSelectionAction != nil
    iconTapView.isUserInteractionEnabled = model.iconSelectionAction != nil

    backgroundView?.backgroundColor = model.backgroundColor

    model.iconImage.subscribe(onNext: { [weak self] image in
      self?.iconImageView.image = image
    }).disposed(by: disposeBag)
  }
}

// MARK: - Constraints
extension LabelAccessoryCell {

  private func remakeConstraints(with model: LabelAccessoryCellModel) {
    if model.accessoryImage != nil {
      accessoryImageWidthHeightConstraint?.constant = model.accessoryImageWidthHeight
      accessoryImageLeadingConstraint?.constant = LabelAccessoryCellModel.accessoryImageMargin
    } else {
      accessoryImageWidthHeightConstraint?.constant = 0
      accessoryImageLeadingConstraint?.constant = 0
    }
    if model.iconImageWidthHeight > 0 {
      iconImageWidthHeightConstraint?.constant = model.iconImageWidthHeight
      iconImageTrailingConstraint?.constant = LabelAccessoryCellModel.iconTrailingLength
    } else {
      iconImageWidthHeightConstraint?.constant = 0
      iconImageTrailingConstraint?.constant = 0
    }
  }

  private func setupConstraints() {
    let layoutGuide = contentView.layoutMarginsGuide

    iconImageView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
    iconImageView.centerYAnchor.constraint(equalTo: layoutGuide.centerYAnchor).isActive = true
    iconImageView.topAnchor.constraint(greaterThanOrEqualTo: layoutGuide.topAnchor).isActive = true
    iconImageView.bottomAnchor.constraint(lessThanOrEqualTo: layoutGuide.bottomAnchor).isActive = true
    iconImageWidthHeightConstraint = iconImageView.widthAnchor.constraint(equalToConstant: 0)
    iconImageWidthHeightConstraint?.isActive = true
    iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor).isActive = true

    iconTapView.anchor(
      toLeading: contentView.leadingAnchor,
      top: contentView.topAnchor,
      trailing: label.leadingAnchor,
      bottom: contentView.bottomAnchor
    )

    iconImageTrailingConstraint = label.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor)
    iconImageTrailingConstraint?.isActive = true

    label.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
    label.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true

    detailsLabel.centerYAnchor.constraint(equalTo: layoutGuide.centerYAnchor).isActive = true
    detailsLabel.leadingAnchor.constraint(equalTo: label.trailingAnchor).isActive = true
    detailsLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    accessoryImageLeadingConstraint = accessoryImageView.leadingAnchor.constraint(equalTo: detailsLabel.trailingAnchor)
    accessoryImageLeadingConstraint?.isActive = true
    accessoryImageView.centerYAnchor.constraint(equalTo: layoutGuide.centerYAnchor).isActive = true
    accessoryImageView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
    accessoryImageWidthHeightConstraint = accessoryImageView.widthAnchor.constraint(equalToConstant: 0)
    accessoryImageWidthHeightConstraint?.isActive = true
    accessoryImageView.heightAnchor.constraint(equalTo: accessoryImageView.widthAnchor).isActive = true

    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}
