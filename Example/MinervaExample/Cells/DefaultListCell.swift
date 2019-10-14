//
//  DefaultListCell.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva

open class DefaultListCellModel: BaseListCellModel {

  public static let defaultCellInset: CGFloat = 10

  public var topSeparatorColor: UIColor?
  public var topSeparatorLeftInset = false
  public var topSeparatorRightInset = false
  public var topSeparatorHeight: CGFloat = 1

  public var bottomSeparatorColor: UIColor?
  public var bottomSeparatorLeftInset = false
  public var bottomSeparatorRightInset = false
  public var bottomSeparatorHeight: CGFloat = 1

  public var backgroundColor: UIColor?
  public var topMargin: CGFloat = 0
  public var bottomMargin: CGFloat = 0
  public var constrainToReadablilityWidth = true

  public var leftMargin: CGFloat = DefaultListCellModel.defaultCellInset
  public var rightMargin: CGFloat = DefaultListCellModel.defaultCellInset

  public var separatorAndMarginHeight: CGFloat {
    return bottomSeparatorHeight
      + topSeparatorHeight
      + topMargin
      + bottomMargin
  }

  override open func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? DefaultListCellModel else {
      return false
    }
    return topSeparatorColor == model.topSeparatorColor
      && topSeparatorLeftInset == model.topSeparatorLeftInset
      && topSeparatorRightInset == model.topSeparatorRightInset
      && topSeparatorHeight == model.topSeparatorHeight
      && bottomSeparatorColor == model.bottomSeparatorColor
      && bottomSeparatorLeftInset == model.bottomSeparatorLeftInset
      && bottomSeparatorRightInset == model.bottomSeparatorRightInset
      && bottomSeparatorHeight == model.bottomSeparatorHeight
      && backgroundColor == model.backgroundColor
      && constrainToReadablilityWidth == model.constrainToReadablilityWidth
      && topMargin == model.topMargin
      && bottomMargin == model.bottomMargin
      && leftMargin == model.leftMargin
      && rightMargin == model.rightMargin

  }
}

open class DefaultListCell: BaseListBindableCell {

  public private(set) var containerCenterXConstraint: NSLayoutConstraint?
  public private(set) var containerTopConstraint: NSLayoutConstraint?
  public private(set) var containerBottomConstraint: NSLayoutConstraint?
  public private(set) var containerLeadingConstraint: NSLayoutConstraint?
  public private(set) var containerTrailingConstraint: NSLayoutConstraint?

  public private(set) var topSeparatorLeadingConstraint: NSLayoutConstraint?
  public private(set) var topSeparatorTrailingConstraint: NSLayoutConstraint?
  public private(set) var topSeparatorHeightConstraint: NSLayoutConstraint?

  private var requiredBottomSeparatorLeadingConstraint: NSLayoutConstraint?
  public private(set) var bottomSeparatorLeadingConstraint: NSLayoutConstraint?
  public private(set) var bottomSeparatorTrailingConstraint: NSLayoutConstraint?
  public private(set) var bottomSeparatorHeightConstraint: NSLayoutConstraint?

  public var topSeparatorLeftInset: Bool {
    get {
      return topSeparatorLeadingConstraint?.firstAnchor == containerView.leadingAnchor
    }
    set {
      topSeparatorLeadingConstraint?.isActive = false
      let newLeadingAnchor = newValue ? containerView.leadingAnchor : contentView.leadingAnchor
      topSeparatorLeadingConstraint = topSeparatorView.leadingAnchor.constraint(equalTo: newLeadingAnchor)
      topSeparatorLeadingConstraint?.isActive = true
    }
  }

  public var topSeparatorRightInset: Bool {
    get {
      return topSeparatorTrailingConstraint?.firstAnchor == containerView.trailingAnchor
    }
    set {
      topSeparatorTrailingConstraint?.isActive = false
      let newLeadingAnchor = newValue ? containerView.trailingAnchor : contentView.trailingAnchor
      topSeparatorTrailingConstraint = topSeparatorView.trailingAnchor.constraint(equalTo: newLeadingAnchor)
      topSeparatorTrailingConstraint?.isActive = true
    }
  }

  public var bottomSeparatorLeftInset: Bool {
    get {
      return bottomSeparatorLeadingConstraint?.firstAnchor == containerView.leadingAnchor
    }
    set {
      bottomSeparatorLeadingConstraint?.isActive = false
      if newValue {
        bottomSeparatorLeadingConstraint = bottomSeparatorView.leadingAnchor.constraint(
          equalTo: contentView.leadingAnchor,
          constant: DefaultListCellModel.defaultCellInset
        )
      } else {
        bottomSeparatorLeadingConstraint = bottomSeparatorView.leadingAnchor.constraint(
          equalTo: contentView.leadingAnchor
        )
      }
      bottomSeparatorLeadingConstraint?.priority = .notRequired
      bottomSeparatorLeadingConstraint?.isActive = true
    }
  }

  public var bottomSeparatorRightInset: Bool {
    get {
      return bottomSeparatorTrailingConstraint?.firstAnchor == containerView.trailingAnchor
    }
    set {
      bottomSeparatorTrailingConstraint?.isActive = false
      if newValue {
        bottomSeparatorTrailingConstraint = bottomSeparatorView.trailingAnchor.constraint(
          equalTo: contentView.trailingAnchor,
          constant: -DefaultListCellModel.defaultCellInset
        )
      } else {
        bottomSeparatorTrailingConstraint = bottomSeparatorView.trailingAnchor.constraint(
          equalTo: contentView.trailingAnchor
        )
      }
      bottomSeparatorTrailingConstraint?.isActive = true
    }
  }

  public var topSeparatorHeight: CGFloat {
    get { return topSeparatorHeightConstraint?.constant ?? 0 }
    set { topSeparatorHeightConstraint?.constant = newValue }
  }

  public var bottomSeparatorHeight: CGFloat {
    get { return bottomSeparatorHeightConstraint?.constant ?? 0 }
    set { bottomSeparatorHeightConstraint?.constant = newValue }
  }

  public var topMargin: CGFloat {
    get { return containerTopConstraint?.constant ?? 0 }
    set { containerTopConstraint?.constant = newValue }
  }

  public var bottomMargin: CGFloat {
    get { return containerBottomConstraint?.constant ?? 0 }
    set { containerBottomConstraint?.constant = newValue }
  }

  public let containerView = UIView()
  public let topSeparatorView = UIView()
  public let bottomSeparatorView = UIView()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(containerView)
    contentView.addSubview(topSeparatorView)
    contentView.addSubview(bottomSeparatorView)
    setupConstraints()
  }

  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override open func didUpdateCellModel() {
    super.didUpdateCellModel()
    guard let model = self.cellModel as? DefaultListCellModel else { return }
    constraintContainerViewHorizontally(toReadabilityWidth: model.constrainToReadablilityWidth)

    topSeparatorView.backgroundColor = model.topSeparatorColor ?? model.backgroundColor
    topSeparatorLeftInset = model.topSeparatorLeftInset
    topSeparatorRightInset = model.topSeparatorRightInset
    topSeparatorHeight = model.topSeparatorHeight
    bottomSeparatorView.backgroundColor = model.bottomSeparatorColor ?? model.backgroundColor
    bottomSeparatorLeftInset = model.bottomSeparatorLeftInset
    bottomSeparatorRightInset = model.bottomSeparatorRightInset
    bottomSeparatorHeight = model.bottomSeparatorHeight

    containerLeadingConstraint?.constant = model.leftMargin
    containerTrailingConstraint?.constant = -model.rightMargin

    contentView.backgroundColor = model.backgroundColor
    topMargin = model.topMargin
    bottomMargin = model.bottomMargin

  }
}

// MARK: - Constraints
extension DefaultListCell {
  private func constraintContainerViewHorizontally(toReadabilityWidth constrainToReadablilityWidth: Bool) {
    if constrainToReadablilityWidth {
      containerLeadingConstraint?.isActive = false
      containerLeadingConstraint
        = containerView.leadingAnchor.constraint(equalTo: contentView.readableContentGuide.leadingAnchor)
      containerLeadingConstraint?.priority = UILayoutPriority.notRequired
      containerLeadingConstraint?.isActive = true

      containerTrailingConstraint?.isActive = false
      containerTrailingConstraint
        = containerView.trailingAnchor.constraint(equalTo: contentView.readableContentGuide.trailingAnchor)
      containerTrailingConstraint?.priority = UILayoutPriority.notRequired
      containerTrailingConstraint?.isActive = true
    } else {
      containerLeadingConstraint?.isActive = false
      containerLeadingConstraint
        = containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
      containerLeadingConstraint?.priority = UILayoutPriority.notRequired
      containerLeadingConstraint?.isActive = true

      containerTrailingConstraint?.isActive = false
      containerTrailingConstraint
        = containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
      containerTrailingConstraint?.priority = UILayoutPriority.notRequired
      containerTrailingConstraint?.isActive = true
    }
  }

  private func setupConstraints() {
    topSeparatorView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    topSeparatorHeightConstraint = topSeparatorView.heightAnchor.constraint(equalToConstant: 1)
    topSeparatorHeightConstraint?.isActive = true

    topSeparatorLeadingConstraint = topSeparatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
    topSeparatorLeadingConstraint?.isActive = true
    topSeparatorTrailingConstraint = topSeparatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
    topSeparatorTrailingConstraint?.isActive = true

    containerTopConstraint = containerView.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor)
    containerTopConstraint?.isActive = true

    containerBottomConstraint = bottomSeparatorView.topAnchor.constraint(equalTo: containerView.bottomAnchor)
    containerBottomConstraint?.isActive = true

    bottomSeparatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    bottomSeparatorHeightConstraint = bottomSeparatorView.heightAnchor.constraint(equalToConstant: 1)
    bottomSeparatorHeightConstraint?.isActive = true
  }
}
