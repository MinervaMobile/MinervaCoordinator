//
//  LabelCellModel.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva

final class LabelCellModel: DefaultListCellModel, ListSelectableCellModel, ListBindableCellModel {

  fileprivate static let maxTextWidth: CGFloat = 600

  // MARK: - ListSelectableCellModel
  typealias SelectableModelType = LabelCellModel
  var selectionAction: SelectionAction?

  // MARK: - ListBindableCellModel
  typealias BindableModelType = LabelCellModel
  var willBindAction: BindAction?

  var textAlignment: NSTextAlignment = .left
  var numberOfLines = 0
  var textColor: UIColor?

  fileprivate let attributedText: NSAttributedString?
  fileprivate let text: String
  fileprivate let font: UIFont
  private let cellIdentifier: String

  init(identifier: String, text: String, font: UIFont, attributedText: NSAttributedString? = nil) {
    self.cellIdentifier = identifier
    self.text = text
    self.font = font
    self.attributedText = attributedText
    super.init()
  }

  convenience init(text: String, font: UIFont) {
    self.init(identifier: text, text: text, font: font)
  }

  convenience init(attributedText: NSAttributedString) {
    self.init(identifier: attributedText.string, attributedText: attributedText)
  }

  convenience init(identifier: String, attributedText: NSAttributedString) {
    self.init(
      identifier: identifier,
      text: attributedText.string,
      font: UIFont.preferredFont(forTextStyle: .subheadline),
      attributedText: attributedText)
  }

  // MARK: - BaseListCellModel

  override var identifier: String {
    return cellIdentifier
  }

  override func isEqual(to model: ListCellModel) -> Bool {
    guard let model = model as? LabelCellModel, super.isEqual(to: model) else {
      return false
    }
    return text == model.text
      && font == model.font
      && attributedText == model.attributedText
      && textColor == model.textColor
      && textAlignment == model.textAlignment
      && numberOfLines == model.numberOfLines
  }

  override func size(constrainedTo containerSize: CGSize) -> CGSize? {
    let width = containerSize.width
    let textHeight: CGFloat
    if let attributedString = attributedText {
      textHeight = attributedString.height(constraintedToWidth: width)
    } else {
      textHeight = text.height(constraintedToWidth: width, font: font)
    }
    let height = textHeight + separatorAndMarginHeight

    return CGSize(width: width, height: height)
  }
}

final class LabelCell: DefaultListCell, ListCellHelper {
  typealias ModelType = LabelCellModel

  private let label: UILabel = {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    containerView.addSubview(label)
    label.anchor(to: containerView)
    containerView.shouldTranslateAutoresizingMaskIntoConstraints(false)
    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
    contentView.clipsToBounds = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("Unsupported")
    return nil
  }

  override func updatedCellModel() {
    super.updatedCellModel()
    guard let model = model else {
      return
    }
    label.numberOfLines = model.numberOfLines
    if let attributedText = model.attributedText {
      label.attributedText = attributedText
    } else {
      label.text = model.text
      label.font = model.font
      label.textColor = model.textColor
    }

    label.textAlignment = model.textAlignment
    topMargin = model.topMargin
    bottomMargin = model.bottomMargin

    contentView.backgroundColor = model.backgroundColor
  }
}

// MARK: - Factory
extension LabelCellModel {
  public static func createSectionHeaderModel(title: String) -> LabelCellModel {
    let cellModel = LabelCellModel(text: title, font: .footnote)
    cellModel.backgroundColor = .section
    cellModel.topMargin = 24
    cellModel.bottomMargin = 8
    cellModel.textAlignment = .left
    cellModel.textColor = .black
    cellModel.bottomSeparatorColor = .separator
    cellModel.bottomSeparatorLeftInset = false
    return cellModel
  }
}
