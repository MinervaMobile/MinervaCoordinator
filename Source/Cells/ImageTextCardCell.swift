//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import RxSwift
import UIKit

open class ImageTextCardCellModel: BaseListCellModel {
  fileprivate static let textMargin: CGFloat = 8

  public let image = BehaviorSubject<UIImage?>(value: nil)

  public let attributedText: NSAttributedString
  public var cellSize = CGSize(width: 140, height: 170)
  public var imageSize: CGSize
  public var imageBackgroundColor: UIColor?

  public var imageContentMode = UIView.ContentMode.scaleAspectFill
  public var imageCornerRadius: CGFloat = 5

  public var imageColor: UIColor?
  public var backgroundColor: UIColor?

  public init(identifier: String, attributedText: NSAttributedString) {
    self.attributedText = attributedText
    self.imageSize = CGSize(width: cellSize.width, height: cellSize.height)
    super.init(identifier: identifier)
  }

  public convenience init(attributedText: NSAttributedString) {
    self.init(identifier: attributedText.string, attributedText: attributedText)
  }

  // MARK: - BaseListCellModel

  override open func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return attributedText == model.attributedText
      && cellSize == model.cellSize
      && imageSize == model.imageSize
      && imageContentMode == model.imageContentMode
      && imageCornerRadius == model.imageCornerRadius
      && imageBackgroundColor == model.imageBackgroundColor
      && imageColor == model.imageColor
      && backgroundColor == model.backgroundColor
  }

  override open func size(
    constrainedTo containerSize: CGSize,
    with templateProvider: () -> ListCollectionViewCell
  ) -> ListCellSize {
    return .autolayout
  }
}

public final class ImageTextCardCell: BaseReactiveListCell<ImageTextCardCellModel> {

  public var imageHeightConstraint: NSLayoutConstraint?
  public var imageWidthConstraint: NSLayoutConstraint?
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.clipsToBounds = true
    return imageView
  }()

  private let label: UILabel = {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    label.textAlignment = .left
    return label
  }()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(imageView)
    contentView.addSubview(label)
    self.setupConstraints()
  }

  override public func prepareForReuse() {
    super.prepareForReuse()
    imageView.image = nil
  }

  override public func bind(model: ImageTextCardCellModel, sizing: Bool) {
    super.bind(model: model, sizing: sizing)

    imageHeightConstraint?.constant = model.imageSize.height
    imageWidthConstraint?.constant = model.imageSize.width
    label.attributedText = model.attributedText

    guard !sizing else { return }

    if let imageColor = model.imageColor {
      imageView.tintColor = imageColor
    }

    contentView.backgroundColor = model.backgroundColor
    imageView.backgroundColor = model.imageBackgroundColor

    imageView.contentMode = model.imageContentMode
    imageView.layer.cornerRadius = model.imageCornerRadius

    model.image.subscribe(onNext: { [weak self] in self?.imageView.image = $0 }).disposed(by: disposeBag)
  }
}

// MARK: - Constraints
extension ImageTextCardCell {
  private func setupConstraints() {
    let layoutGuide = contentView.layoutMarginsGuide
    imageView.anchor(
      toLeading: layoutGuide.leadingAnchor,
      top: layoutGuide.topAnchor,
      trailing: nil,
      bottom: nil
    )

    imageHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 0)
    imageHeightConstraint?.isActive = true
    imageWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 0)
    imageWidthConstraint?.isActive = true
    label.anchor(
      toLeading: layoutGuide.leadingAnchor,
      top: nil,
      trailing: layoutGuide.trailingAnchor,
      bottom: nil
    )
    label.topAnchor.constraint(
      equalTo: imageView.bottomAnchor,
      constant: ImageTextCardCellModel.textMargin
    ).isActive = true
    label.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true

    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}
