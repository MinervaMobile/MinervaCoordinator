//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import UIKit

open class SeparatorCellModel: BaseListCellModel {
  public static func id(for location: Location) -> String {
    switch location {
    case .bottom(let cellModelID):
      return "Separator-Bottom-\(cellModelID)"
    case .top(let cellModelID):
      return "Separator-Top-\(cellModelID)"
    }
  }

  public enum Location: Equatable {
      case bottom(cellModelID: String)
      case top(cellModelID: String)

      public static func == (lhs: Self, rhs: Self) -> Bool {
          switch (lhs, rhs) {
          case (.bottom(let idLeft), .bottom(let idRight)): return idLeft == idRight
          case (.top(let idLeft), .top(let idRight)): return idLeft == idRight
          default: return false
          }
      }
  }

  public var directionalLayoutMargins = NSDirectionalEdgeInsets(
    top: 0,
    leading: 16,
    bottom: 0,
    trailing: 16
  )
  public var backgroundColor: UIColor?

  fileprivate let color: UIColor
  fileprivate let height: CGFloat
  fileprivate let location: Location
  fileprivate let followsLeadingMargin: Bool
  fileprivate let followsTrailingMargin: Bool

  public init(
    location: Location,
    color: UIColor,
    height: CGFloat = 1,
    followsLeadingMargin: Bool = false,
    followsTrailingMargin: Bool = false
  ) {
    self.location = location
    self.color = color
    self.height = height
    self.followsLeadingMargin = followsLeadingMargin
    self.followsTrailingMargin = followsTrailingMargin
    super.init(identifier: Self.id(for: location))
  }

  // MARK: - BaseListCellModel

  override open func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return color == model.color
      && height == model.height
      && followsLeadingMargin == model.followsLeadingMargin
      && followsTrailingMargin == model.followsTrailingMargin
      && backgroundColor == model.backgroundColor
      && location == model.location
      && directionalLayoutMargins == model.directionalLayoutMargins
  }
}

public final class SeparatorCell: BaseListCell<SeparatorCellModel> {

  private let separator = UIView()
  private var heightConstraint: NSLayoutConstraint?
  private var leadingConstraint: NSLayoutConstraint?
  private var trailingConstraint: NSLayoutConstraint?

  override public init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(separator)
    separator.anchor(
      toLeading: nil,
      top: contentView.layoutMarginsGuide.topAnchor,
      trailing: nil,
      bottom: contentView.layoutMarginsGuide.bottomAnchor
    )
    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
    backgroundView = UIView()
    setupConstraints()
  }

  override public func bind(model: SeparatorCellModel, sizing: Bool) {
    super.bind(model: model, sizing: sizing)
    contentView.directionalLayoutMargins = model.directionalLayoutMargins

    remakeConstraints(with: model)

    guard !sizing else { return }

    separator.backgroundColor = model.color
    backgroundView?.backgroundColor = model.backgroundColor
  }
}

// MARK: - Constraints
extension SeparatorCell {
  private func remakeConstraints(with model: SeparatorCellModel) {
    let layoutGuide = contentView.layoutMarginsGuide

    if let leadingConstraint = leadingConstraint {
      leadingConstraint.isActive = false
      separator.removeConstraint(leadingConstraint)
    }
    leadingConstraint = separator.leadingAnchor.constraint(
      equalTo: model.followsLeadingMargin ? layoutGuide.leadingAnchor : contentView.leadingAnchor
    )
    leadingConstraint?.isActive = true

    if let trailingConstraint = trailingConstraint {
      trailingConstraint.isActive = false
      separator.removeConstraint(trailingConstraint)
    }
    trailingConstraint = separator.trailingAnchor.constraint(
      equalTo: model.followsTrailingMargin ? layoutGuide.trailingAnchor : contentView.trailingAnchor
    )
    trailingConstraint?.isActive = true
    heightConstraint?.constant = model.height
  }

  private func setupConstraints() {
    leadingConstraint = separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
    leadingConstraint?.isActive = true

    trailingConstraint = separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
    trailingConstraint?.isActive = true

    heightConstraint = separator.heightAnchor.constraint(equalToConstant: 1)
    heightConstraint?.isActive = true
  }
}
