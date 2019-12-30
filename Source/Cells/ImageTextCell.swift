//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import RxSwift
import UIKit

open class ImageTextCellModel: BaseListCellModel {
  fileprivate static let imageMargin: CGFloat = 10

  public let image = BehaviorSubject<UIImage?>(value: nil)

  public var directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

  fileprivate let attributedText: NSAttributedString
  public var imageSize = CGSize(width: 75, height: 75)
  public var imageViewCornerRadius: CGFloat = 0

  public init(identifier: String, attributedText: NSAttributedString) {
    self.attributedText = attributedText
    super.init(identifier: identifier)
  }

  // MARK: - BaseListCellModel

  override open func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return attributedText == model.attributedText
      && imageSize == model.imageSize
      && imageViewCornerRadius == model.imageViewCornerRadius
      && directionalLayoutMargins == model.directionalLayoutMargins
  }
}

public final class ImageTextCell: BaseReactiveListCell<ImageTextCellModel> {

  private let label: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    label.numberOfLines = 0
    label.adjustsFontForContentSizeCategory = true
    return label
  }()

  private var imageViewHeightConstraint: NSLayoutConstraint?
  private var imageViewWidthConstraint: NSLayoutConstraint?
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.layer.masksToBounds = true
    return imageView
  }()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(label)
    contentView.addSubview(imageView)
    setupConstraints()
  }

  override public func prepareForReuse() {
    super.prepareForReuse()
    imageView.image = nil
  }

  override public func bind(model: ImageTextCellModel, sizing: Bool) {
    super.bind(model: model, sizing: sizing)
    contentView.directionalLayoutMargins = model.directionalLayoutMargins
    label.attributedText = model.attributedText
    imageViewWidthConstraint?.constant = model.imageSize.width
    imageViewHeightConstraint?.constant = model.imageSize.height

    guard !sizing else { return }

    imageView.layer.cornerRadius = model.imageViewCornerRadius
    model.image.subscribe(onNext: { [weak self] in self?.imageView.image = $0 }).disposed(by: disposeBag)
  }
}

// MARK: - Constraints
extension ImageTextCell {
  private func setupConstraints() {
    let layoutGuide = contentView.layoutMarginsGuide

    imageView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
    imageView.centerYAnchor.constraint(equalTo: layoutGuide.centerYAnchor).isActive = true
    imageView.topAnchor.constraint(greaterThanOrEqualTo: layoutGuide.topAnchor).isActive = true
    imageView.bottomAnchor.constraint(lessThanOrEqualTo: layoutGuide.bottomAnchor).isActive = true

    imageViewHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 75)
    imageViewHeightConstraint?.isActive = true
    imageViewWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 75)
    imageViewWidthConstraint?.isActive = true

    label.leadingAnchor.constraint(
      equalTo: imageView.trailingAnchor,
      constant: ImageTextCellModel.imageMargin
    ).isActive = true
    label.anchor(
      toLeading: nil,
      top: layoutGuide.topAnchor,
      trailing: layoutGuide.trailingAnchor,
      bottom: layoutGuide.bottomAnchor
    )

    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}
