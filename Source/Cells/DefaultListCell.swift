//
//  DefaultListCell.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

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

  open override func isEqual(to model: ListCellModel) -> Bool {
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

  private(set) public var containerCenterXConstraint: NSLayoutConstraint?
  private(set) public var containerTopConstraint: NSLayoutConstraint?
  private(set) public var containerBottomConstraint: NSLayoutConstraint?
  private(set) public var containerLeadingConstraint: NSLayoutConstraint?
  private(set) public var containerTrailingConstraint: NSLayoutConstraint?

  private(set) public var maxContainerWidthConstraint: NSLayoutConstraint?
  private(set) public var topSeparatorLeadingConstraint: NSLayoutConstraint?
  private(set) public var topSeparatorTrailingConstraint: NSLayoutConstraint?
  private(set) public var topSeparatorHeightConstraint: NSLayoutConstraint?

  private var requiredBottomSeparatorLeadingConstraint: NSLayoutConstraint?
  private(set) public var bottomSeparatorLeadingConstraint: NSLayoutConstraint?
  private(set) public var bottomSeparatorTrailingConstraint: NSLayoutConstraint?
  private(set) public var bottomSeparatorHeightConstraint: NSLayoutConstraint?

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

  public override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(containerView)
    contentView.addSubview(topSeparatorView)
    contentView.addSubview(bottomSeparatorView)
    setupConstraints()
  }

  open override func layoutSubviews() {
    super.layoutSubviews()
    // TODO: Remove this and use readableContentGuide
    // https://developer.apple.com/documentation/uikit/uiview/1622644-readablecontentguide
    requiredBottomSeparatorLeadingConstraint?.isActive = frame.width > 800 ? true : false
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override func updatedCellModel() {
    super.updatedCellModel()
    guard let model = self.cellModel as? DefaultListCellModel else { return }
    maxContainerWidthConstraint?.isActive = model.constrainToReadablilityWidth
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
    topSeparatorView.anchor(
      toLeading: contentView.leadingAnchor,
      top: nil,
      trailing: contentView.trailingAnchor,
      bottom: nil
    )

    containerTopConstraint = containerView.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor)
    containerTopConstraint?.isActive = true

    constraintContainerViewHorizontally(toReadabilityWidth: true)

    containerCenterXConstraint = containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
    containerCenterXConstraint?.isActive = true

    maxContainerWidthConstraint = containerView.widthAnchor.constraint(
      lessThanOrEqualTo: contentView.readableContentGuide.widthAnchor
    )
    maxContainerWidthConstraint?.isActive = true

    bottomSeparatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    bottomSeparatorHeightConstraint = bottomSeparatorView.heightAnchor.constraint(equalToConstant: 1)
    bottomSeparatorHeightConstraint?.isActive = true
    containerBottomConstraint = bottomSeparatorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
    containerBottomConstraint?.isActive = true

    requiredBottomSeparatorLeadingConstraint
      = bottomSeparatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)

    topSeparatorLeadingConstraint = topSeparatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
    topSeparatorLeadingConstraint?.isActive = true
    topSeparatorTrailingConstraint = topSeparatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
    topSeparatorTrailingConstraint?.isActive = true

    bottomSeparatorLeftInset = false
    bottomSeparatorRightInset = false
  }
}
