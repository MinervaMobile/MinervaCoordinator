//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

public final class ImageTextCardCellModel: BaseListCellModel, ListSelectableCellModel, ListBindableCellModel {
  fileprivate static let textMargin: CGFloat = 8

  fileprivate let image = BehaviorSubject<UIImage?>(value: nil)

  public let attributedText: NSAttributedString

  public var height: CGFloat = 170
  public var width: CGFloat = 140
  public var imageHeight: CGFloat = 140
  public var imageBackgroundColor: UIColor?

  public var imageContentMode = UIView.ContentMode.scaleAspectFill
  public var imageCornerRadius: CGFloat = 5

  public var imageColor: UIColor?
  public var backgroundColor: UIColor?

  private let cellIdentifier: String

  public init(identifier: String, attributedText: NSAttributedString) {
    self.attributedText = attributedText
    self.cellIdentifier = identifier
    super.init()
  }

  public convenience init(attributedText: NSAttributedString) {
    self.init(identifier: attributedText.string, attributedText: attributedText)
  }

  // MARK: - BaseListCellModel

  override public var identifier: String {
    return self.cellIdentifier
  }

  override public func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return attributedText == model.attributedText
      && height == model.height
      && width == model.width
      && imageHeight == model.imageHeight
      && imageContentMode == model.imageContentMode
      && imageCornerRadius == model.imageCornerRadius
      && imageBackgroundColor == model.imageBackgroundColor
      && imageColor == model.imageColor
      && backgroundColor == model.backgroundColor
  }

  override public func size(
    constrainedTo containerSize: CGSize,
    with templateProvider: () -> ListCollectionViewCell
  ) -> ListCellSize {
    return .explicit(size: CGSize(width: width, height: height))
  }

  // MARK: - ListSelectableCellModel
  public typealias SelectableModelType = ImageTextCardCellModel
  public var selectionAction: SelectionAction?

  // MARK: - ListBindableCellModel
  public typealias BindableModelType = ImageTextCardCellModel
  public var willBindAction: BindAction?
}

public final class ImageTextCardCell: BaseReactiveListCell<ImageTextCardCellModel> {

  public var imageHeightConstraint: NSLayoutConstraint?
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.clipsToBounds = true
    return imageView
  }()

  private let label: UILabel = {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.5
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

    imageHeightConstraint?.constant = model.imageHeight
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
    imageView.anchor(
      toLeading: contentView.leadingAnchor,
      top: contentView.topAnchor,
      trailing: contentView.trailingAnchor,
      bottom: nil
    )

    imageHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 0)
    imageHeightConstraint?.isActive = true
    label.anchor(
      toLeading: contentView.leadingAnchor,
      top: nil,
      trailing: contentView.trailingAnchor,
      bottom: nil
    )
    label.topAnchor.constraint(
      equalTo: imageView.bottomAnchor,
      constant: ImageTextCardCellModel.textMargin
    ).isActive = true
    label.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor).isActive = true

    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}
