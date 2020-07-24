//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import RxSwift
import UIKit

open class ImageCellModel: BaseListCellModel {

  public var imageColor: UIColor?
  public var contentMode: UIView.ContentMode = .scaleAspectFit
  public var directionalLayoutMargins = NSDirectionalEdgeInsets(
    top: 8,
    leading: 16,
    bottom: 8,
    trailing: 16
  )

  public let imageObservable: Observable<UIImage?>
  public let imageSize: CGSize

  public convenience init(imageObservable: Observable<UIImage?>, imageSize: CGSize) {
    self.init(identifier: "ImageCellModel", imageObservable: imageObservable, imageSize: imageSize)
  }

  public init(identifier: String, imageObservable: Observable<UIImage?>, imageSize: CGSize) {
    self.imageObservable = imageObservable
    self.imageSize = imageSize
    super.init(identifier: identifier)
  }

  // MARK: - BaseListCellModel

  override open func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return imageSize == model.imageSize
      && contentMode == model.contentMode
      && imageColor == model.imageColor
  }

  override open func size(constrainedTo containerSize: CGSize) -> ListCellSize {
    let width = containerSize.width
    let cellHeight =
      imageSize.height + directionalLayoutMargins.top
      + directionalLayoutMargins.bottom
    return .explicit(size: CGSize(width: width, height: cellHeight))
  }
}

public final class ImageCell: BaseReactiveListCell<ImageCellModel> {

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

    model.imageObservable
      .observeOn(MainScheduler.instance)
      .subscribe(
        onNext: { [weak self] image -> Void in
          guard let strongSelf = self else { return }
          if let imageColor = model.imageColor {
            strongSelf.imageView.image = image?.withRenderingMode(.alwaysTemplate)
            strongSelf.imageView.tintColor = imageColor
          } else {
            strongSelf.imageView.image = image
          }
        }
      )
      .disposed(by: disposeBag)
  }
}

// MARK: - Constraints
extension ImageCell {
  private func setupConstraints() {
    let layoutGuide = contentView.layoutMarginsGuide
    imageView.anchor(
      toLeading: nil,
      top: layoutGuide.topAnchor,
      trailing: nil,
      bottom: layoutGuide.bottomAnchor
    )
    imageView.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor).isActive = true

    imageWidthConstraint.isActive = true

    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}
