//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

public final class SeparatorCellModel: BaseListCellModel {
  public static func id(for location: Location) -> String {
    switch location {
    case .bottom(let cellModelID):
      return "Separator-Bottom-\(cellModelID)"
    case .top(let cellModelID):
      return "Separator-Top-\(cellModelID)"
    }
  }
  public enum Location {
    case bottom(cellModelID: String)
    case top(cellModelID: String)

    public func isEqual(to other: Location) -> Bool {
      switch self {
      case .bottom(let id):
        switch other {
        case .bottom(let otherID): return id == otherID
        case .top: return false
        }
      case .top(let id):
        switch other {
        case .top(let otherID): return id == otherID
        case .bottom: return false
        }
      }
    }
  }

  public var directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
  public var backgroundColor: UIColor?

  fileprivate let color: UIColor
  fileprivate let height: CGFloat
  fileprivate let location: Location
  fileprivate let followsLeadingMargin: Bool
  fileprivate let followsTrailingMargin: Bool
  private let cellID: String

  public init(
    location: Location,
    color: UIColor,
    height: CGFloat = 1,
    followsLeadingMargin: Bool = false,
    followsTrailingMargin: Bool = false
  ) {
    self.cellID = Self.id(for: location)
    self.location = location
    self.color = color
    self.height = height
    self.followsLeadingMargin = followsLeadingMargin
    self.followsTrailingMargin = followsTrailingMargin
  }

  // MARK: - BaseListCellModel

  override public var identifier: String { cellID }

  override public func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? SeparatorCellModel else { return false }
    return color == model.color
      && height == model.height
      && followsLeadingMargin == model.followsLeadingMargin
      && followsTrailingMargin == model.followsTrailingMargin
      && backgroundColor == model.backgroundColor
      && location.isEqual(to: model.location)
      && directionalLayoutMargins == model.directionalLayoutMargins
  }
}

public final class SeparatorCell: BaseListCell {

  private let separator = UIView()
  private weak var heightConstraint: NSLayoutConstraint?
  private weak var leadingConstraint: NSLayoutConstraint?
  private weak var trailingConstraint: NSLayoutConstraint?

  override public func updateConstraints() {
    guard let model = self.cellModel as? SeparatorCellModel else { return }
    remakeConstraints(
      height: model.height,
      followsLayoutGuideLeadingMargin: model.followsLeadingMargin,
      followsLayoutGuideTrailingMargin: model.followsTrailingMargin
    )

    super.updateConstraints()
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(separator)
    separator.anchor(
      toLeading: nil,
      top: contentView.layoutMarginsGuide.topAnchor,
      trailing: nil,
      bottom: contentView.layoutMarginsGuide.bottomAnchor
    )
    remakeConstraints()
    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
    backgroundView = UIView()

  }

  override public func didUpdateCellModel() {
    super.didUpdateCellModel()
    guard let model = self.cellModel as? SeparatorCellModel else { return }
    separator.backgroundColor = model.color
    backgroundView?.backgroundColor = model.backgroundColor
    contentView.directionalLayoutMargins = model.directionalLayoutMargins
    setNeedsUpdateConstraints()
  }

  private func remakeConstraints(
    height: CGFloat = 1,
    followsLayoutGuideLeadingMargin: Bool = false,
    followsLayoutGuideTrailingMargin: Bool = false
  ) {
    let layoutGuide = contentView.layoutMarginsGuide

    leadingConstraint?.isActive = false
    leadingConstraint = separator.leadingAnchor.constraint(
      equalTo: followsLayoutGuideLeadingMargin ? layoutGuide.leadingAnchor : contentView.leadingAnchor
    )
    leadingConstraint?.isActive = true

    trailingConstraint?.isActive = false
    trailingConstraint = separator.trailingAnchor.constraint(
      equalTo: followsLayoutGuideTrailingMargin ? layoutGuide.trailingAnchor : contentView.trailingAnchor
    )
    trailingConstraint?.isActive = true

    heightConstraint?.isActive = false
    heightConstraint = separator.heightAnchor.constraint(equalToConstant: height)
    heightConstraint?.isActive = true
  }
}
