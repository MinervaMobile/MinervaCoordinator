//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import RxRelay
import UIKit

open class TextViewCellModel: BaseListCellModel {
  public typealias Action = (_ cellModel: TextViewCellModel, _ text: String?) -> Void

  public var placeholderText: String? {
    get { return helper.placeholderText }
    set { helper.placeholderText = newValue }
  }
  public var placeholderTextColor: UIColor? {
    get { return helper.placeholderTextColor }
    set { helper.placeholderTextColor = newValue }
  }
  public var textColor: UIColor? {
    get { return helper.textColor }
    set { helper.textColor = newValue }
  }

  public var directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

  public var backgroundColor: UIColor?

  public var becomesFirstResponder = BehaviorRelay<Bool>(value: false)

  public var height: CGFloat = 200

  public var cursorColor: UIColor?

  fileprivate let font: UIFont
  fileprivate var text: String?
  fileprivate let helper: TextViewCellModelHelper

  public init(
    identifier: String,
    text: String?,
    font: UIFont,
    changedValue: Action? = nil,
    finishEditingTextAction: Action? = nil
  ) {
    self.text = text
    self.font = font
    self.helper = TextViewCellModelHelper()
    super.init(identifier: identifier)
    self.helper.changedTextAction = { [weak self] text -> Void in
      guard let strongSelf = self else { return }
      changedValue?(strongSelf, text)
    }
    self.helper.finishEditingTextAction = { [weak self] text -> Void in
      guard let strongSelf = self else { return }
      finishEditingTextAction?(strongSelf, text)
    }
  }

  // MARK: - BaseListCellModel

  override open func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return height == model.height
      && cursorColor == model.cursorColor
      && placeholderText == model.placeholderText
      && placeholderTextColor == model.placeholderTextColor
      && textColor == model.textColor
      && font == model.font
      && text == model.text
      && backgroundColor == model.backgroundColor
      && directionalLayoutMargins == model.directionalLayoutMargins
  }

  override open func size(
    constrainedTo containerSize: CGSize,
    with templateProvider: () -> ListCollectionViewCell
  ) -> ListCellSize {
    let width = containerSize.width
    return .explicit(size: CGSize(width: width, height: height))
  }
}

public final class TextViewCell: BaseReactiveListCell<TextViewCellModel> {

  private let textView: UITextView = {
    let textView = UITextView()
    textView.adjustsFontForContentSizeCategory = true
    textView.isEditable = true
    textView.backgroundColor = nil
    return textView
  }()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(textView)
    backgroundView = UIView()
    setupConstraints()
  }

  override public func bind(model: TextViewCellModel, sizing: Bool) {
    super.bind(model: model, sizing: sizing)
    textView.font = model.font

    if let text = model.text, !text.isEmpty {
      textView.text = text
    } else {
      textView.text = model.placeholderText
    }
    contentView.directionalLayoutMargins = model.directionalLayoutMargins
    guard !sizing else { return }

    textView.tintColor = model.cursorColor
    textView.textColor = model.textColor

    if let text = model.text, !text.isEmpty {
      textView.textColor = model.textColor
    } else {
      textView.textColor = model.placeholderTextColor
    }

    model.becomesFirstResponder.subscribe(onNext: { [weak self] isFirstResponder in
      if isFirstResponder {
        self?.textView.becomeFirstResponder()
      } else {
        self?.textView.resignFirstResponder()
      }
    }).disposed(by: disposeBag)

    backgroundView?.backgroundColor = model.backgroundColor
    textView.delegate = model.helper
  }
}

private class TextViewCellModelHelper: NSObject {
  fileprivate typealias Action = (_ text: String?) -> Void

  fileprivate var changedTextAction: Action?
  fileprivate var finishEditingTextAction: Action?
  fileprivate var placeholderText: String?
  fileprivate var placeholderTextColor: UIColor?
  fileprivate var textColor: UIColor?

  override fileprivate init() {
  }
}

// MARK: - UITextViewDelegate
extension TextViewCellModelHelper: UITextViewDelegate {
  public func textViewDidChange(_ textView: UITextView) {
    let text = textView.text.isEmpty && textView.text != placeholderText ? nil : textView.text
    changedTextAction?(text)
  }

  public func textViewDidBeginEditing(_ textView: UITextView) {
    guard textView.textColor == placeholderTextColor else {
      return
    }
    textView.text = nil
    textView.textColor = textColor

  }

  public func textViewDidEndEditing(_ textView: UITextView) {
    finishEditingTextAction?(textView.text)
    guard textView.text.isEmpty else {
      return
    }
    textView.text = placeholderText
    textView.textColor = placeholderTextColor
  }
}

// MARK: - Constraints
extension TextViewCell {
  private func setupConstraints() {
    textView.anchorTo(layoutGuide: contentView.layoutMarginsGuide)

    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}
