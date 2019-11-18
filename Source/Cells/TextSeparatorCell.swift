//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

public final class TextSeparatorCellModel: BaseListCellModel {
  public static let separatorHeight: CGFloat = 1
  public static let textMargin: CGFloat = 8

  private let cellIdentifier: String
  public var font = UIFont.preferredFont(forTextStyle: .footnote)
  public var textColor: UIColor?
  public var lineColor: UIColor?

  public var directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

  public let text: String

  public init(identifier: String, text: String) {
    self.cellIdentifier = identifier
    self.text = text
    super.init()
  }

  public convenience init(text: String) {
    self.init(identifier: text, text: text)
  }

  // MARK: - BaseListCellModel

  override public var identifier: String { cellIdentifier }

  override public func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return text == model.text
      && font == model.font
      && textColor == model.textColor
      && lineColor == model.lineColor
      && directionalLayoutMargins == model.directionalLayoutMargins
  }
}

public final class TextSeparatorCell: BaseListCell<TextSeparatorCellModel> {

  private let label: UILabel = {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true
    return label
  }()
  private let leftLineView = UIView()
  private let rightLineView = UIView()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(label)
    contentView.addSubview(leftLineView)
    contentView.addSubview(rightLineView)
    setupConstraints()
  }

  override public func bind(model: TextSeparatorCellModel, sizing: Bool) {
    super.bind(model: model, sizing: sizing)
    label.text = model.text
    label.font = model.font
    contentView.directionalLayoutMargins = model.directionalLayoutMargins
    guard !sizing else { return }

    label.textColor = model.textColor

    leftLineView.backgroundColor = model.lineColor
    rightLineView.backgroundColor = model.lineColor
  }
}

// MARK: - Constraints
extension TextSeparatorCell {
  private func setupConstraints() {
    let layoutGuide = contentView.layoutMarginsGuide
    label.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor).isActive = true
    label.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
    label.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true

    leftLineView.anchorHeight(to: TextSeparatorCellModel.separatorHeight)
    leftLineView.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
    leftLineView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
    leftLineView.trailingAnchor.constraint(
      equalTo: label.leadingAnchor,
      constant: -TextSeparatorCellModel.textMargin
    ).isActive = true

    rightLineView.anchorHeight(to: TextSeparatorCellModel.separatorHeight)
    rightLineView.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
    rightLineView.leadingAnchor.constraint(
      equalTo: label.trailingAnchor,
      constant: TextSeparatorCellModel.textMargin
    ).isActive = true
    rightLineView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true

    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}
