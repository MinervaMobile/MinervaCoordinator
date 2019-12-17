//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import RxSwift
import UIKit

open class ButtonCellModel: BaseListCellModel {
  public typealias ButtonAction = (_ model: ButtonCellModel, _ button: UIButton) -> Void

  public var buttonAction: ButtonAction?
  public var isSelected = BehaviorSubject<Bool>(value: false)

  public var directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
  public var numberOfLines = 0
  public var textVerticalMargin: CGFloat = 15.0
  public var textHorizontalMargin: CGFloat = 15.0
  public var accessoryImageWidthHeight: CGFloat = 15.0
  public var textAlignment: NSTextAlignment = .center
  public var cellFillsWidth = false
  public var titleEdgeInsets: UIEdgeInsets = .zero

  public var buttonColor: UIColor?
  public var selectedButtonColor: UIColor?
  public var backgroundColor: UIColor?

  public var selectedAttributedText: NSAttributedString?

  public var borderWidth: CGFloat = 0
  public var borderRadius: CGFloat = 4
  public var borderColor: UIColor?
  public var selectedBorderColor: UIColor?

  fileprivate let attributedText: NSAttributedString

  public init(identifier: String, attributedText: NSAttributedString) {
    self.attributedText = attributedText
    super.init(identifier: identifier)
  }

  public convenience init(attributedText: NSAttributedString) {
    self.init(identifier: attributedText.string, attributedText: attributedText)
  }

  public convenience init(identifier: String, text: String, font: UIFont, textColor: UIColor) {
    let string = NSAttributedString(
      string: text,
      font: font,
      fontColor: textColor
    )
    self.init(identifier: identifier, attributedText: string)
  }

  public convenience init(text: String, font: UIFont, textColor: UIColor) {
    self.init(identifier: text, text: text, font: font, textColor: textColor)
  }

  // MARK: - BaseListCellModel

  override open func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return attributedText == model.attributedText
      && numberOfLines == model.numberOfLines
      && textVerticalMargin == model.textVerticalMargin
      && textHorizontalMargin == model.textHorizontalMargin
      && accessoryImageWidthHeight == model.accessoryImageWidthHeight
      && textAlignment == model.textAlignment
      && buttonColor == model.buttonColor
      && selectedButtonColor == model.selectedButtonColor
      && selectedAttributedText == model.selectedAttributedText
      && borderWidth == model.borderWidth
      && borderRadius == model.borderRadius
      && borderColor == model.borderColor
      && selectedBorderColor == model.selectedBorderColor
      && cellFillsWidth == model.cellFillsWidth
      && titleEdgeInsets == model.titleEdgeInsets
      && backgroundColor == model.backgroundColor
      && directionalLayoutMargins == model.directionalLayoutMargins
  }
}

public final class ButtonCell: BaseReactiveListCell<ButtonCellModel> {

  private let button: UIButton = {
    let button = UIButton()
    button.titleLabel?.adjustsFontForContentSizeCategory = true
    button.titleLabel?.minimumScaleFactor = 0.5
    button.titleLabel?.adjustsFontSizeToFitWidth = true
    button.titleLabel?.lineBreakMode = .byWordWrapping
    button.clipsToBounds = true
    return button
  }()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(button)
    backgroundView = UIView()
    setupConstraints()
    button.addTarget(self, action: #selector(pressedButton(_:)), for: .touchUpInside)
  }

  override public func prepareForReuse() {
    super.prepareForReuse()
    button.setBackgroundImage(nil, for: .normal)
    button.setBackgroundImage(nil, for: .highlighted)
    button.setBackgroundImage(nil, for: .selected)
  }

  override public func bind(model: ButtonCellModel, sizing: Bool) {
    super.bind(model: model, sizing: sizing)

    button.titleLabel?.textAlignment = model.textAlignment
    button.titleLabel?.numberOfLines = model.numberOfLines
    button.titleEdgeInsets = model.titleEdgeInsets

    button.contentEdgeInsets = UIEdgeInsets(
      top: model.textVerticalMargin,
      left: model.textHorizontalMargin,
      bottom: model.textVerticalMargin,
      right: model.textHorizontalMargin
    )

    button.setAttributedTitle(model.attributedText, for: .normal)
    button.setAttributedTitle(model.selectedAttributedText, for: .selected)

    contentView.directionalLayoutMargins = model.directionalLayoutMargins

    guard !sizing else { return }

    button.setBackgroundImage(model.buttonColor?.image(), for: .normal)
    button.setBackgroundImage(model.buttonColor?.withAlphaComponent(0.8).image(), for: .highlighted)
    button.setBackgroundImage(model.selectedBorderColor?.image(), for: .selected)

    backgroundView?.backgroundColor = model.backgroundColor
    button.layer.borderWidth = model.borderWidth
    button.layer.cornerRadius = model.borderRadius
    button.isUserInteractionEnabled = model.buttonAction != nil

    model.isSelected.subscribe(onNext: { [weak self, weak model] isSelected -> Void in
      self?.button.isSelected = isSelected
      let borderColor = isSelected ? model?.selectedBorderColor?.cgColor : model?.borderColor?.cgColor
      self?.button.layer.borderColor = borderColor
    }).disposed(by: disposeBag)
  }

  @objc
  private func pressedButton(_ sender: UIButton) {
    guard let model = model else { return }
    model.buttonAction?(model, sender)
  }
}

// MARK: - Constraints
extension ButtonCell {
  private func setupConstraints() {
    button.anchorTo(layoutGuide: contentView.layoutMarginsGuide)
    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}
