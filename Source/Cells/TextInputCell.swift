//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import RxSwift
import UIKit

public protocol TextInputCellModelDelegate: AnyObject {
  func textInputCellModel(_ textInputCellModel: TextInputCellModel, textChangedTo text: String?)
}

open class TextInputCellModel: BaseListCellModel {
  public weak var delegate: TextInputCellModelDelegate?

  public var directionalLayoutMargins = NSDirectionalEdgeInsets(
    top: 8,
    leading: 16,
    bottom: 8,
    trailing: 16
  )

  fileprivate static let bottomBorderHeight: CGFloat = 1.0
  fileprivate static let textBottomMargin: CGFloat = 8.0
  fileprivate static let textInputIndent: CGFloat = 10.0

  fileprivate var attributedPlaceholder: NSAttributedString {
    NSAttributedString(string: placeholder, font: font, fontColor: placeholderTextColor)
  }
  public var bottomBorderColor = BehaviorSubject<UIColor?>(value: nil)

  public var becomesFirstResponder = false
  public var text: String?
  fileprivate let font: UIFont
  fileprivate let placeholder: String

  public var cursorColor: UIColor?
  public var textColor: UIColor?
  public var textContentType: UITextContentType?
  public var isSecureTextEntry: Bool = false
  public var autocorrectionType: UITextAutocorrectionType = .default
  public var autocapitalizationType: UITextAutocapitalizationType = .none
  public var keyboardType: UIKeyboardType = .default
  public var inputTextColor: UIColor = .white
  public var placeholderTextColor: UIColor = .white
  public var maxControlWidth: CGFloat = 340

  public init(identifier: String, placeholder: String, font: UIFont) {
    self.placeholder = placeholder
    self.font = font
    super.init(identifier: identifier)
  }

  // MARK: - BaseListCellModel

  override open func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return text == model.text
      && font == model.font
      && placeholder == model.placeholder
      && cursorColor == model.cursorColor
      && textColor == model.textColor
      && textContentType == model.textContentType
      && isSecureTextEntry == model.isSecureTextEntry
      && autocorrectionType == model.autocorrectionType
      && autocapitalizationType == model.autocapitalizationType
      && keyboardType == model.keyboardType
      && inputTextColor == model.inputTextColor
      && placeholderTextColor == model.placeholderTextColor
      && maxControlWidth == model.maxControlWidth
      && directionalLayoutMargins == model.directionalLayoutMargins
  }
}

public final class TextInputCell: BaseReactiveListCell<TextInputCellModel> {
  private let textField: UITextField = {
    let textField = UITextField(frame: .zero)
    textField.borderStyle = .none
    textField.adjustsFontForContentSizeCategory = true
    return textField
  }()
  private let bottomBorder: UIView = {
    let bottomBorder = UIView()
    return bottomBorder
  }()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(textField)
    contentView.addSubview(bottomBorder)
    setupConstraints()
    textField.addTarget(
      self,
      action: #selector(textFieldDidChange(_:)),
      for: .editingChanged
    )
  }

  @objc
  private func textFieldDidChange(_ textField: UITextField) {
    guard let model = self.model else { return }
    model.text = textField.text
    model.delegate?.textInputCellModel(model, textChangedTo: textField.text)
  }

  override public func bind(model: TextInputCellModel, sizing: Bool) {
    super.bind(model: model, sizing: sizing)

    textField.attributedPlaceholder = model.attributedPlaceholder

    if let initialText = model.text, (textField.text == nil || textField.text?.isEmpty == true) {
      textField.text = initialText
    }
    textField.font = model.font
    contentView.directionalLayoutMargins = model.directionalLayoutMargins
    guard !sizing else { return }

    textField.textColor = model.inputTextColor
    textField.autocapitalizationType = model.autocapitalizationType
    textField.autocorrectionType = model.autocorrectionType
    textField.tintColor = model.cursorColor
    textField.keyboardType = model.keyboardType
    textField.isSecureTextEntry = model.isSecureTextEntry
    textField.textContentType = model.textContentType

    model.bottomBorderColor.subscribe(onNext: { [weak self] bottomBorderColor -> Void in
      self?.bottomBorder.backgroundColor = bottomBorderColor
    }).disposed(by: disposeBag)

    if model.becomesFirstResponder {
      textField.becomeFirstResponder()
    }
  }
}

// MARK: - Constraints
extension TextInputCell {
  private func setupConstraints() {
    let layoutGuide = contentView.layoutMarginsGuide

    textField.anchor(
      toLeading: layoutGuide.leadingAnchor,
      top: layoutGuide.topAnchor,
      trailing: layoutGuide.trailingAnchor,
      bottom: nil
    )

    bottomBorder.anchorHeight(to: TextInputCellModel.bottomBorderHeight)
    bottomBorder.anchor(
      toLeading: layoutGuide.leadingAnchor,
      top: nil,
      trailing: layoutGuide.trailingAnchor,
      bottom: layoutGuide.bottomAnchor
    )
    bottomBorder.topAnchor.constraint(
      equalTo: textField.bottomAnchor,
      constant: TextInputCellModel.textBottomMargin
    ).isActive = true

    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}
