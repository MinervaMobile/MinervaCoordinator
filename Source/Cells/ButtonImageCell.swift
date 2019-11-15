//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

public final class ButtonImageCellModel: BaseListCellModel, ListSelectableCellModel, ListBindableCellModel {

  fileprivate static let verticalMargin: CGFloat = 10
  fileprivate static let horizontalMargin: CGFloat = 4.0
  fileprivate static let imageMargin: CGFloat = 4.0

  public let iconImage = BehaviorSubject<UIImage?>(value: nil)

  public var numberOfLines = 0
  public var textAlignment: NSTextAlignment = .center
  public var buttonColor: UIColor?
  public var textColor: UIColor?
  public var backgroundColor: UIColor?

  public var allButtonsText: [String]
  public var imageContentMode: UIView.ContentMode = .scaleAspectFit
  public var imageColor: UIColor?

  public var borderWidth: CGFloat = 0
  public var borderRadius: CGFloat = 4
  public var borderColor: UIColor?

  fileprivate let text: String
  fileprivate let font: UIFont
  fileprivate let imageWidth: CGFloat
  fileprivate let imageHeight: CGFloat

  private let cellIdentifier: String

  public init(identifier: String, imageWidth: CGFloat, imageHeight: CGFloat, text: String, font: UIFont) {
    self.cellIdentifier = identifier
    self.imageWidth = imageWidth
    self.imageHeight = imageHeight
    self.text = text
    self.font = font
    self.allButtonsText = [text]
    super.init()
  }

  public convenience init(imageWidth: CGFloat, imageHeight: CGFloat, text: String, font: UIFont) {
    self.init(identifier: text, imageWidth: imageWidth, imageHeight: imageHeight, text: text, font: font)
  }

  // MARK: - BaseListCellModel

  override public var identifier: String {
    return self.cellIdentifier
  }

  override public func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? ButtonImageCellModel, super.identical(to: model) else { return false }
    return numberOfLines == model.numberOfLines
      && textAlignment == model.textAlignment
      && buttonColor == model.buttonColor
      && textColor == model.textColor
      && allButtonsText == model.allButtonsText
      && imageContentMode == model.imageContentMode
      && imageColor == model.imageColor
      && borderWidth == model.borderWidth
      && borderRadius == model.borderRadius
      && borderColor == model.borderColor
      && text == model.text
      && font == model.font
      && imageWidth == model.imageWidth
      && imageHeight == model.imageHeight
      && backgroundColor == model.backgroundColor
  }

  override public func size(
    constrainedTo containerSize: CGSize,
    with templateProvider: () -> ListCollectionViewCell
  ) -> ListCellSize {
    let margins = templateProvider().layoutMargins
    let rowWidth = containerSize.width
    let textWidth = rowWidth - margins.left - margins.right - imageWidth - ButtonImageCellModel.horizontalMargin * 4

    let textHeight = allButtonsText.reduce(0) {
      max($0, $1.height(constraintedToWidth: textWidth, font: font))
    }
    let height = textHeight
      + ButtonImageCellModel.verticalMargin * 2
      + margins.top
      + margins.bottom
    return .explicit(size: CGSize(width: rowWidth, height: height))
  }

  // MARK: - ListSelectableCellModel
  public typealias SelectableModelType = ButtonImageCellModel
  public var selectionAction: SelectionAction?

  // MARK: - ListBindableCellModel
  public typealias BindableModelType = ButtonImageCellModel
  public var willBindAction: BindAction?
}

public final class ButtonImageCell: BaseListCell {
  public var model: ButtonImageCellModel? { cellModel as? ButtonImageCellModel }
  public var disposeBag = DisposeBag()

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

  override public init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(buttonBackgroundView)
    contentView.addSubview(marginContainer)
    marginContainer.addSubview(imageView)
    marginContainer.addSubview(label)

    setupConstraints()
    backgroundView = UIView()
  }
  override public func prepareForReuse() {
    super.prepareForReuse()
    imageView.image = nil
  }

  override public func updateConstraints() {
    guard let model = model else { return }
    imageWidthConstraint?.constant = model.imageWidth
    imageHeightConstraint?.constant = model.imageHeight
    super.updateConstraints()
  }

  override public func didUpdateCellModel() {
    super.didUpdateCellModel()
    guard let model = model else { return }
    model.iconImage.subscribe(onNext: { [weak self] in self?.imageView.image = $0 }).disposed(by: disposeBag)
    imageView.contentMode = model.imageContentMode
    imageView.tintColor = model.imageColor
    label.text = model.text
    label.font = model.font
    label.textColor = model.textColor
    label.textAlignment = model.textAlignment
    label.numberOfLines = model.numberOfLines

    buttonBackgroundView.layer.borderWidth = model.borderWidth
    buttonBackgroundView.layer.borderColor = model.borderColor?.cgColor
    buttonBackgroundView.layer.cornerRadius = model.borderRadius
    buttonBackgroundView.backgroundColor = model.buttonColor
    backgroundView?.backgroundColor = model.backgroundColor

    setNeedsUpdateConstraints()
  }
}

// MARK: - Constraints
extension ButtonImageCell {
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
