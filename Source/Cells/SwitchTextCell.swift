//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import UIKit

open class SwitchTextCellModel: BaseListCellModel {
  public static let switchWidth: CGFloat = 50
  public static let textMargin: CGFloat = 15.0

  public typealias SwitchAction = (
    _ model: SwitchTextCellModel,
    _ isOn: Bool
  ) -> Void

  public var didSwitchAction: SwitchAction?

  public var directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
  public var backgroundColor: UIColor?

  fileprivate let text: String
  fileprivate let font: UIFont
  fileprivate let textColor: UIColor
  fileprivate let switchColor: UIColor
  public private(set) var isOn: Bool

  public init(identifier: String, text: String, font: UIFont, textColor: UIColor, switchColor: UIColor, isOn: Bool) {
    self.text = text
    self.font = font
    self.textColor = textColor
    self.switchColor = switchColor
    self.isOn = isOn
    super.init(identifier: identifier)
  }

  public convenience init(text: String, font: UIFont, textColor: UIColor, switchColor: UIColor, isOn: Bool) {
    self.init(identifier: text, text: text, font: font, textColor: textColor, switchColor: switchColor, isOn: isOn)
  }

  // MARK: - BaseListCellModel

  override open func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return text == model.text
      && isOn == model.isOn
      && font == model.font
      && textColor == model.textColor
      && switchColor == model.switchColor
      && backgroundColor == model.backgroundColor
      && directionalLayoutMargins == model.directionalLayoutMargins
  }
}

public final class SwitchTextCell: BaseListCell<SwitchTextCellModel> {

  private let label: UILabel = {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    label.textAlignment = .left
    return label
  }()

  private let switchButton: UISwitch = {
    let switchButton = UISwitch()
    return switchButton
  }()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(label)
    contentView.addSubview(switchButton)
    backgroundView = UIView()
    setupConstraints()
    switchButton.addTarget(self, action: #selector(self.toggleSwitch), for: .valueChanged)
  }

  override public func bind(model: SwitchTextCellModel, sizing: Bool) {
    super.bind(model: model, sizing: sizing)

    label.text = model.text
    label.font = model.font
    contentView.directionalLayoutMargins = model.directionalLayoutMargins
    switchButton.isUserInteractionEnabled = model.didSwitchAction != nil

    guard !sizing else { return }

    label.textColor = model.textColor
    switchButton.onTintColor = model.switchColor
    switchButton.isOn = model.isOn

    backgroundView?.backgroundColor = model.backgroundColor
  }
  @objc
  private func toggleSwitch(_ sender: UISwitch) {
    guard let model = model else {
      return
    }
    model.didSwitchAction?(model, sender.isOn)
  }
}

// MARK: - Constraints
extension SwitchTextCell {
  private func setupConstraints() {
    let layoutGuide = contentView.layoutMarginsGuide
    label.anchor(
      toLeading: layoutGuide.leadingAnchor,
      top: layoutGuide.topAnchor,
      trailing: nil,
      bottom: layoutGuide.bottomAnchor
    )
    label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    switchButton.anchorWidth(to: SwitchTextCellModel.switchWidth)

    switchButton.leadingAnchor.constraint(
      equalTo: label.trailingAnchor,
      constant: SwitchTextCellModel.textMargin
    ).isActive = true

    switchButton.anchor(
      toLeading: nil,
      top: layoutGuide.topAnchor,
      trailing: layoutGuide.trailingAnchor,
      bottom: layoutGuide.bottomAnchor
    )
    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}
