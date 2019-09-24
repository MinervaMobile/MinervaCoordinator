//
//  BorderLabelCell.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva

final class BorderLabelCellModel: DefaultListCellModel, ListSelectableCellModel, ListBindableCellModel {

  // MARK: - ListSelectableCellModel
  typealias SelectableModelType = BorderLabelCellModel
  var selectionAction: SelectionAction?

  // MARK: - ListBindableCellModel
  typealias BindableModelType = BorderLabelCellModel
  var willBindAction: BindAction?

  var isSelected: Bool {
    get { return reactiveIsSelected.value }
    set { reactiveIsSelected.value = newValue }
  }

  private let cellIdentifier: String

  var numberOfLines = 0
  var textVerticalMargin: CGFloat = 15.0
  var textHorizontalMargin: CGFloat = 15.0
  var accessoryImageWidthHeight: CGFloat = 15.0
  var textAlignment: NSTextAlignment = .center

  var buttonColor: UIColor?
  var selectedButtonColor: UIColor?

  var accessoryImage: UIImage?
  var accessoryColor: UIColor?

  var selectedAttributedText: NSAttributedString?

  var borderWidth: CGFloat = 0
  var borderRadius: CGFloat = 4
  var borderColor: UIColor?
  var selectedBorderColor: UIColor?

  fileprivate var reactiveIsSelected = Observable<Bool>(false)

  fileprivate let attributedText: NSAttributedString

  init(identifier: String, attributedText: NSAttributedString) {
    self.cellIdentifier = identifier
    self.attributedText = attributedText
    super.init()
  }

  convenience init(attributedText: NSAttributedString) {
    self.init(identifier: attributedText.string, attributedText: attributedText)
  }

  convenience init(identifier: String, text: String, font: UIFont, textColor: UIColor) {
    let string = NSAttributedString(string: text, font: font, fontColor: textColor)
    self.init(identifier: identifier, attributedText: string)
  }

  convenience init(text: String, font: UIFont, textColor: UIColor) {
    self.init(identifier: text, text: text, font: font, textColor: textColor)
  }

  // MARK: - BaseListCellModel

  override var identifier: String {
    return cellIdentifier
  }

  override func isEqual(to model: ListCellModel) -> Bool {
    guard let model = model as? BorderLabelCellModel else {
      return false
    }
    return attributedText == model.attributedText
      && isSelected == model.isSelected
      && numberOfLines == model.numberOfLines
      && textVerticalMargin == model.textVerticalMargin
      && textHorizontalMargin == model.textHorizontalMargin
      && accessoryImageWidthHeight == model.accessoryImageWidthHeight
      && textAlignment == model.textAlignment
      && buttonColor == model.buttonColor
      && selectedButtonColor == model.selectedButtonColor
      && accessoryImage == model.accessoryImage
      && accessoryColor == model.accessoryColor
      && selectedAttributedText == model.selectedAttributedText
      && borderWidth == model.borderWidth
      && borderRadius == model.borderRadius
      && borderColor == model.borderColor
      && selectedBorderColor == model.selectedBorderColor
  }
}

final class BorderLabelCell: DefaultListCell, ListCellHelper {
  typealias ModelType = BorderLabelCellModel

  private var labelLeadingConstraint: NSLayoutConstraint?

  private let label: UILabel = {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    return label
  }()

  private var accessoryImageWidthConstraint: NSLayoutConstraint?
  private var accessoryLeadingConstraint: NSLayoutConstraint?
  private var accesoryTrailingConstraint: NSLayoutConstraint?

  private let accessoryImageView: UIImageView = {
    let imageView = UIImageView(frame: .zero)
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    containerView.addSubview(label)
    containerView.addSubview(accessoryImageView)
    setupConstraints()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("Unsupported")
    return nil
  }

  override func updatedCellModel() {
    super.updatedCellModel()
    guard let model = self.model else {
      return
    }

    label.textAlignment = model.textAlignment
    labelLeadingConstraint?.constant = model.textHorizontalMargin
    accesoryTrailingConstraint?.constant = -model.textHorizontalMargin

    accessoryImageWidthConstraint?.constant = model.accessoryImage != nil ? model.accessoryImageWidthHeight : 0
    accessoryLeadingConstraint?.constant = model.accessoryImage != nil ? model.textHorizontalMargin : 0

    bind(model.reactiveIsSelected) { [weak self, weak model] isSelected -> Void in
      self?.label.attributedText = isSelected ? model?.selectedAttributedText : model?.attributedText
      self?.containerView.backgroundColor = isSelected ? model?.selectedButtonColor : model?.buttonColor
      let borderColor = isSelected ? model?.selectedBorderColor?.cgColor : model?.borderColor?.cgColor
      self?.containerView.layer.borderColor = borderColor
    }

    containerView.layer.borderWidth = model.borderWidth
    containerView.layer.cornerRadius = model.borderRadius
  }
}

// MARK: - Constraints
extension BorderLabelCell {
  private func setupConstraints() {

    label.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
    label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true

    labelLeadingConstraint = label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)
    labelLeadingConstraint?.isActive = true

    accessoryLeadingConstraint = accessoryImageView.leadingAnchor.constraint(equalTo: label.trailingAnchor)
    accessoryLeadingConstraint?.isActive = true

    accessoryImageView.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true

    accesoryTrailingConstraint = accessoryImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
    accesoryTrailingConstraint?.isActive = true

    accessoryImageView.heightAnchor.constraint(equalTo: accessoryImageView.widthAnchor).isActive = true
    accessoryImageWidthConstraint = accessoryImageView.widthAnchor.constraint(equalToConstant: 0)
    accessoryImageWidthConstraint?.isActive = true

    containerView.shouldTranslateAutoresizingMaskIntoConstraints(false)
    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}
