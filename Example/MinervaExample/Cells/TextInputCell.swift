//
//  TextInputCell.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva

protocol TextInputCellModelDelegate: AnyObject {
  func textInputCellModel(_ textInputCellModel: TextInputCellModel, textChangedTo text: String?)
}

final class TextInputCellModel: BaseListCell.Model {
  weak var delegate: TextInputCellModelDelegate?

  fileprivate static let bottomBorderHeight: CGFloat = 1.0
  fileprivate static let textBottomMargin: CGFloat = 8.0
  fileprivate static let textInputIndent: CGFloat = 10.0

  fileprivate var attributedPlaceholder: NSAttributedString {
    return NSAttributedString(string: placeholder, font: font, fontColor: placeholderTextColor)
  }
  var bottomBorderColor: UIColor? {
    get { return reactiveBottomBorderColor.value }
    set { reactiveBottomBorderColor.value = newValue }
  }

  var text: String?
  var backgroundColor: UIColor?
  var cursorColor: UIColor?
  var textColor: UIColor?
  var textContentType: UITextContentType?
  var isSecureTextEntry: Bool = false
  var autocorrectionType: UITextAutocorrectionType = .default
  var autocapitalizationType: UITextAutocapitalizationType = .none
  var keyboardType: UIKeyboardType = .default
  var inputTextColor: UIColor = .white
  var placeholderTextColor: UIColor = .white
  private let cellIdentifier: String

  fileprivate var reactiveFirstResponder = MinervaObservable<Bool>(false)
  fileprivate var reactiveBottomBorderColor = MinervaObservable<UIColor?>(nil)

  fileprivate let placeholder: String
  fileprivate let font: UIFont

  init(identifier: String, placeholder: String, font: UIFont) {
    self.cellIdentifier = identifier
    self.placeholder = placeholder
    self.font = font
    super.init()
  }

  func becomeFirstResponder() {
    reactiveFirstResponder.value = true
  }

  // MARK: - BaseListCell.Model

  override var identifier: String {
    return cellIdentifier
  }

  override func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? TextInputCellModel else { return false }
    return text == model.text
      && bottomBorderColor == model.bottomBorderColor
      && backgroundColor == model.backgroundColor
      && cursorColor == model.cursorColor
      && textColor == model.textColor
      && textContentType == model.textContentType
      && isSecureTextEntry == model.isSecureTextEntry
      && autocorrectionType == model.autocorrectionType
      && autocapitalizationType == model.autocapitalizationType
      && keyboardType == model.keyboardType
      && inputTextColor == model.inputTextColor
      && placeholderTextColor == model.placeholderTextColor
  }
}

final class TextInputCell: BaseListBindableCell, ListCellHelper {
  typealias ModelType = TextInputCellModel

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
  private let textFieldContainer: UIView = {
    let textFieldContainer = UIView()
    return textFieldContainer
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(textFieldContainer)
    textFieldContainer.addSubview(textField)
    contentView.addSubview(bottomBorder)
    textField.addTarget(
      self,
      action: #selector(textFieldDidChange(_:)),
      for: .editingChanged
    )
    setupConstraints()
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc
  func textFieldDidChange(_ textField: UITextField) {
    guard let model = self.model else { return }
    model.text = textField.text
    model.delegate?.textInputCellModel(model, textChangedTo: textField.text)
  }

  override func updatedCellModel() {
    super.updatedCellModel()
    guard let model = self.model else { return }
    textField.autocapitalizationType = model.autocapitalizationType
    textField.autocorrectionType = model.autocorrectionType
    textField.tintColor = model.cursorColor
    textField.attributedPlaceholder = model.attributedPlaceholder
    textField.keyboardType = model.keyboardType
    if let initialText = model.text, (textField.text == nil || textField.text?.isEmpty == true) {
      textField.text = initialText
    }
    textField.isSecureTextEntry = model.isSecureTextEntry
    textField.textColor = model.inputTextColor
    textField.textContentType = model.textContentType
    textField.font = model.font
    contentView.backgroundColor = model.backgroundColor

    bind(model.reactiveBottomBorderColor) { [weak self] bottomBorderColor -> Void in
      self?.bottomBorder.backgroundColor = model.bottomBorderColor
    }
    bind(model.reactiveFirstResponder) { [weak self] isFirstResponder -> Void in
      guard isFirstResponder else { return }
      self?.textField.becomeFirstResponder()
      model.reactiveFirstResponder.value = false
    }
  }
}

// MARK: - Constraints
extension TextInputCell {
  private func setupConstraints() {

    textField.leadingAnchor.constraint(
      equalTo: textFieldContainer.leadingAnchor,
      constant: TextInputCellModel.textInputIndent
    ).isActive = true
    textField.trailingAnchor.constraint(
      equalTo: textFieldContainer.trailingAnchor,
      constant: -TextInputCellModel.textInputIndent
    ).isActive = true
    textField.topAnchor.constraint(equalTo: textFieldContainer.topAnchor).isActive = true
    textField.bottomAnchor.constraint(equalTo: textFieldContainer.bottomAnchor).isActive = true

    textFieldContainer.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor).isActive = true
    textFieldContainer.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor).isActive = true
    textFieldContainer.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    textFieldContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    textFieldContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 340).isActive = true
    let widthAnchor = textField.widthAnchor.constraint(equalToConstant: 340)
    widthAnchor.priority = .defaultLow
    widthAnchor.isActive = true
    textField.setContentHuggingPriority(.defaultLow, for: .horizontal)

    bottomBorder.anchorHeight(to: TextInputCellModel.bottomBorderHeight)
    bottomBorder.anchor(
      toLeading: textFieldContainer.leadingAnchor,
      top: nil,
      trailing: textFieldContainer.trailingAnchor,
      bottom: contentView.bottomAnchor
    )
    bottomBorder.topAnchor.constraint(
      equalTo: textFieldContainer.bottomAnchor,
      constant: TextInputCellModel.textBottomMargin
    ).isActive = true

    textFieldContainer.shouldTranslateAutoresizingMaskIntoConstraints(false)
    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}
