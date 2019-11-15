//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

open class ButtonCellModel: BaseListCellModel, ListBindableCellModel {
  public typealias SelectionAction = (_ model: ButtonCellModel, _ button: UIButton) -> Void

  public var selectionAction: SelectionAction?

  public var isSelected = BehaviorSubject<Bool>(value: false)

  private let cellIdentifier: String

  public var directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
  public var numberOfLines = 0
  public var textVerticalMargin: CGFloat = 15.0
  public var textHorizontalMargin: CGFloat = 15.0
  public var accessoryImageWidthHeight: CGFloat = 15.0
  public var textAlignment: NSTextAlignment = .center
  public var cellFillsWidth = false
  public var titleEdgeInsets: UIEdgeInsets = .zero
  public var followsLayoutGuideMargins = true

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
    self.cellIdentifier = identifier
    self.attributedText = attributedText
    super.init()
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

  override open var identifier: String {
    return cellIdentifier
  }

  override open func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? ButtonCellModel, super.identical(to: model) else {
      return false
    }
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

  // MARK: - ListBindableCellModel
  public typealias BindableModelType = ButtonCellModel
  public var willBindAction: BindAction?
}

public class ButtonCell: BaseListCell {
  public var model: ButtonCellModel? { cellModel as? ButtonCellModel }
  public var disposeBag = DisposeBag()

  private weak var leadingConstraint: NSLayoutConstraint?
  private weak var trailingConstraint: NSLayoutConstraint?
  private weak var topConstraint: NSLayoutConstraint?
  private weak var bottomConstraint: NSLayoutConstraint?

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
    setupConstraints()
    button.addTarget(self, action: #selector(pressedButton(_:)), for: .touchUpInside)
    backgroundView = UIView()
  }

  override public func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()
  }

  override public func updateConstraints() {
    remakeConstraints(followsLayoutGuideMargins: model?.followsLayoutGuideMargins ?? true)
    super.updateConstraints()
  }

  @objc
  private func pressedButton(_ sender: UIButton) {
    guard let model = model else { return }
    model.selectionAction?(model, sender)
  }

  override public func didUpdateCellModel() {
    super.didUpdateCellModel()
    guard let model = self.model else {
      return
    }

    button.titleLabel?.textAlignment = model.textAlignment
    button.titleLabel?.numberOfLines = model.numberOfLines
    button.setBackgroundImage(model.buttonColor?.image(), for: .normal)
    button.setBackgroundImage(model.buttonColor?.withAlphaComponent(0.8).image(), for: .highlighted)
    button.setBackgroundImage(model.selectedBorderColor?.image(), for: .selected)
    button.titleEdgeInsets = model.titleEdgeInsets

    button.contentEdgeInsets = UIEdgeInsets(
      top: model.textVerticalMargin,
      left: model.textHorizontalMargin,
      bottom: model.textVerticalMargin,
      right: model.textHorizontalMargin
    )

    button.setAttributedTitle(model.attributedText, for: .normal)
    button.setAttributedTitle(model.selectedAttributedText, for: .selected)
    button.isUserInteractionEnabled = model.selectionAction != nil

    model.isSelected.subscribe(onNext: { [weak self, weak model] isSelected -> Void in
      self?.button.isSelected = isSelected
      let borderColor = isSelected ? model?.selectedBorderColor?.cgColor : model?.borderColor?.cgColor
      self?.button.layer.borderColor = borderColor
    }).disposed(by: disposeBag)

    button.layer.borderWidth = model.borderWidth
    button.layer.cornerRadius = model.borderRadius
    backgroundView?.backgroundColor = model.backgroundColor
    contentView.directionalLayoutMargins = model.directionalLayoutMargins
    setNeedsUpdateConstraints()
  }
}

// MARK: - Constraints
extension ButtonCell {
  private func setupConstraints() {
    remakeConstraints()
    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }

  private func remakeConstraints(followsLayoutGuideMargins: Bool = true) {
    let layoutGuide = contentView.layoutMarginsGuide

    leadingConstraint?.isActive = false
    leadingConstraint = button.leadingAnchor.constraint(
      equalTo: followsLayoutGuideMargins ? layoutGuide.leadingAnchor : contentView.leadingAnchor
    )
    leadingConstraint?.isActive = true

    trailingConstraint?.isActive = false
    trailingConstraint = button.trailingAnchor.constraint(
      equalTo: followsLayoutGuideMargins ? layoutGuide.trailingAnchor : contentView.trailingAnchor
    )
    trailingConstraint?.isActive = true

    topConstraint?.isActive = false
    topConstraint = button.topAnchor.constraint(
      equalTo: followsLayoutGuideMargins ? layoutGuide.topAnchor : contentView.topAnchor
    )
    topConstraint?.isActive = true

    bottomConstraint?.isActive = false
    bottomConstraint = button.bottomAnchor.constraint(
      equalTo: followsLayoutGuideMargins ? layoutGuide.bottomAnchor : contentView.bottomAnchor
    )
    bottomConstraint?.isActive = true
  }
}
