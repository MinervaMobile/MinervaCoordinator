//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import UIKit

open class LabelCellModel: BaseListCellModel {
  public typealias LabelAction = (_ model: LabelCellModel, _ gesture: UITapGestureRecognizer, _ label: UILabel) -> Void

  public var labelAction: LabelAction?

  public var directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
  public var textAlignment: NSTextAlignment = .left
  public var numberOfLines = 0
  public var textColor: UIColor?
  public var cornerMask: CACornerMask?
  public var cornerRadius: CGFloat = 0
  public var backgroundColor: UIColor?
  public var labelBackgroundColor: UIColor?

  fileprivate let attributedText: NSAttributedString?
  fileprivate let text: String
  fileprivate let font: UIFont

  public init(identifier: String, text: String, font: UIFont, attributedText: NSAttributedString? = nil) {
    self.text = text
    self.font = font
    self.attributedText = attributedText
    super.init(identifier: identifier)
  }

  public convenience init(text: String, font: UIFont) {
    self.init(identifier: text, text: text, font: font)
  }

  public convenience init(attributedText: NSAttributedString) {
    self.init(identifier: attributedText.string, attributedText: attributedText)
  }

  public convenience init(identifier: String, attributedText: NSAttributedString) {
    self.init(
      identifier: identifier,
      text: attributedText.string,
      font: UIFont.preferredFont(forTextStyle: .subheadline),
      attributedText: attributedText)
  }

  // MARK: - BaseListCellModel

  override open func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return text == model.text
      && font == model.font
      && attributedText == model.attributedText
      && textColor == model.textColor
      && textAlignment == model.textAlignment
      && numberOfLines == model.numberOfLines
      && cornerMask == model.cornerMask
      && cornerRadius == model.cornerRadius
      && backgroundColor == model.backgroundColor
      && directionalLayoutMargins == model.directionalLayoutMargins
      && labelBackgroundColor == model.labelBackgroundColor
  }
}

public final class LabelCell: BaseListCell<LabelCellModel> {
  private let labelBackgroundView = UIView()
  private let label: UILabel = {
    let label = UILabel()
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.5
    label.allowsDefaultTighteningForTruncation = true
    label.adjustsFontForContentSizeCategory = true
    return label
  }()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(labelBackgroundView)
    contentView.addSubview(label)
    backgroundView = UIView()
    let recognizer = UITapGestureRecognizer(target: self, action: #selector(tappedLabel))
    label.addGestureRecognizer(recognizer)
    setupConstraints()
  }

  override public func bind(model: LabelCellModel, sizing: Bool) {
    super.bind(model: model, sizing: sizing)

    if let attributedText = model.attributedText {
      label.attributedText = attributedText
    } else {
      label.text = model.text
      label.font = model.font
    }

    label.numberOfLines = model.numberOfLines
    label.textAlignment = model.textAlignment

    contentView.directionalLayoutMargins = model.directionalLayoutMargins

    guard !sizing else { return }

    if model.attributedText == nil {
      label.textColor = model.textColor
    }

    if let maskedCorners = model.cornerMask {
      labelBackgroundView.layer.maskedCorners = maskedCorners
    }
    labelBackgroundView.layer.cornerRadius = model.cornerRadius
    labelBackgroundView.layer.masksToBounds = true
    labelBackgroundView.backgroundColor = model.labelBackgroundColor
    labelBackgroundView.layer.borderColor = model.backgroundColor?.cgColor

    label.isUserInteractionEnabled = model.labelAction != nil
    backgroundView?.backgroundColor = model.backgroundColor
  }

  @objc
  private func tappedLabel(_ gesture: UITapGestureRecognizer) {
    guard let model = model else { return }
    model.labelAction?(model, gesture, label)
  }
}

// MARK: - Constraints
extension LabelCell {
  private func setupConstraints() {
    labelBackgroundView.anchor(to: label)
    label.anchorTo(layoutGuide: contentView.layoutMarginsGuide)
    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}
