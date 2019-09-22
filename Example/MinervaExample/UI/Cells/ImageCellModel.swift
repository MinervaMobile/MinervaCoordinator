//
//  ImageCellModel.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva

final class ImageCellModel: DefaultListCellModel {

  private let cellIdentifier: String
  var imageColor: UIColor?
  var contentMode: UIView.ContentMode = .scaleAspectFit

  let image: UIImage
  let width: CGFloat
  let height: CGFloat

  convenience init(image: UIImage, width: CGFloat, height: CGFloat) {
    self.init(identifier: "ImageCellModel", image: image, width: width, height: height)
  }

  init(identifier: String, image: UIImage, width: CGFloat, height: CGFloat) {
    self.image = image
    self.width = width
    self.height = height
    self.cellIdentifier = identifier
    super.init()
  }

  // MARK: - BaseListCellModel

  override var identifier: String {
    return cellIdentifier
  }

  override func isEqual(to model: ListCellModel) -> Bool {
    guard let model = model as? ImageCellModel, super.isEqual(to: model) else {
      return false
    }
    return image == model.image
      && width == model.width
      && height == model.height
      && contentMode == model.contentMode
      && imageColor == model.imageColor
  }

  override func size(constrainedTo containerSize: CGSize) -> ListCellSize {
    let width = containerSize.width
    let cellHeight = height + separatorAndMarginHeight
    return .explicit(size: CGSize(width: width, height: cellHeight))
  }
}

final class ImageCell: DefaultListCell, ListCellHelper {
  typealias ModelType = ImageCellModel

  private let imageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()
  private let imageWidthConstraint: NSLayoutConstraint

  override init(frame: CGRect) {
    imageWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 0)
    super.init(frame: frame)
    contentView.addSubview(imageView)
    setupConstraints()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("Unsupported")
    return nil
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    imageView.image = nil
  }

  override func updatedCellModel() {
    super.updatedCellModel()
    guard let model = self.model else {
      return
    }
    imageWidthConstraint.constant = model.width
    imageWidthConstraint.isActive = true
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
    imageView.anchor(toLeading: nil, top: containerView.topAnchor, trailing: nil, bottom: containerView.bottomAnchor)
    imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true

    containerView.shouldTranslateAutoresizingMaskIntoConstraints(false)
    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}
