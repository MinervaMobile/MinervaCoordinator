//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import UIKit

open class ImageCellModel: BaseListCellModel {

  public var selectionAction: ((_ cellModel: ImageCellModel, _ indexPath: IndexPath) -> Void)?
  public var imageColor: UIColor?
  public var contentMode: UIView.ContentMode = .scaleAspectFit
  public var directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

  public let image: UIImage
  public let imageSize: CGSize

  public convenience init(image: UIImage, imageSize: CGSize) {
    self.init(identifier: "ImageCellModel", image: image, imageSize: imageSize)
  }

  public init(identifier: String, image: UIImage, imageSize: CGSize) {
    self.image = image
    self.imageSize = imageSize
    super.init(identifier: identifier)
  }

  // MARK: - BaseListCellModel

  override open func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return image == model.image
      && imageSize == model.imageSize
      && contentMode == model.contentMode
      && imageColor == model.imageColor
  }

  override open func size(
    constrainedTo containerSize: CGSize,
    with templateProvider: () -> ListCollectionViewCell
  ) -> ListCellSize {
    let width = containerSize.width
    let cellHeight = imageSize.height + directionalLayoutMargins.top + directionalLayoutMargins.bottom
    return .explicit(size: CGSize(width: width, height: cellHeight))
  }
}

public final class ImageCell: BaseListCell<ImageCellModel> {

  private let imageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()
  private let imageWidthConstraint: NSLayoutConstraint

  override public init(frame: CGRect) {
    imageWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 0)
    super.init(frame: frame)
    contentView.addSubview(imageView)
    setupConstraints()
  }

  override public func prepareForReuse() {
    super.prepareForReuse()
    imageView.image = nil
  }

  override public func bind(model: ImageCellModel, sizing: Bool) {
    super.bind(model: model, sizing: sizing)
    imageWidthConstraint.constant = model.imageSize.width
    contentView.directionalLayoutMargins = model.directionalLayoutMargins

    guard !sizing else { return }

    imageView.contentMode = model.contentMode

    if let imageColor = model.imageColor {
      imageView.image = model.image.withRenderingMode(.alwaysTemplate)
      imageView.tintColor = imageColor
    } else {
      imageView.image = model.image
    }
  }
}

// MARK: - Constraints
extension ImageCell {
  private func setupConstraints() {
    let layoutGuide = contentView.layoutMarginsGuide
    imageView.anchor(toLeading: nil, top: layoutGuide.topAnchor, trailing: nil, bottom: layoutGuide.bottomAnchor)
    imageView.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor).isActive = true

    imageWidthConstraint.isActive = true

    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}
