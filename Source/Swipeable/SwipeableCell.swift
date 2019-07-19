//
//  SwipeableCell.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import SwipeCellKit

open class SwipeableCellModel: DefaultListCellModel {

}

open class SwipeableCell: SwipeCollectionViewCell, ListBindableCell {
  public private(set) var disposeBag = DisposeBag()
  open private(set) var cellModel: ListCellModel?

  private(set) public var containerTopConstraint: NSLayoutConstraint?
  private(set) public var containerBottomConstraint: NSLayoutConstraint?
  private(set) public var containerLeadingConstraint: NSLayoutConstraint?
  private(set) public var containerTrailingConstraint: NSLayoutConstraint?

  private(set) public var maxContainerWidthConstraint: NSLayoutConstraint?
  private(set) public var topSeparatorLeadingConstraint: NSLayoutConstraint?
  private(set) public var topSeparatorTrailingConstraint: NSLayoutConstraint?
  private(set) public var topSeparatorHeightConstraint: NSLayoutConstraint?

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
      let newLeadingAnchor = newValue ? containerView.leadingAnchor : contentView.leadingAnchor
      bottomSeparatorLeadingConstraint = bottomSeparatorView.leadingAnchor.constraint(equalTo: newLeadingAnchor)
      bottomSeparatorLeadingConstraint?.isActive = true
    }
  }

  public var bottomSeparatorRightInset: Bool {
    get {
      return bottomSeparatorTrailingConstraint?.firstAnchor == containerView.trailingAnchor
    }
    set {
      bottomSeparatorTrailingConstraint?.isActive = false
      let newLeadingAnchor = newValue ? containerView.trailingAnchor : contentView.trailingAnchor
      bottomSeparatorTrailingConstraint = bottomSeparatorView.trailingAnchor.constraint(equalTo: newLeadingAnchor)
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

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag.clear()
    cellModel?.cell = nil
    cellModel = nil
    updatedCellModel()
  }

  open func updatedCellModel() {
    guard let model = self.cellModel as? SwipeableCellModel else { return }
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

    maxContainerWidthConstraint?.isActive = model.constrainToReadablilityWidth
  }

  open func willDisplayCell() {
  }

  open func didEndDisplayingCell() {
  }

  // MARK: - ListBindable

  public func bindViewModel(_ viewModel: Any) {
    guard let cellModel = viewModel as? ListCellModel else {
      assertionFailure("Invalid view model \(viewModel)")
      return
    }
    if let existingCell = self.cellModel?.cell, existingCell === self {
      self.cellModel?.cell = nil
    }
    if let model = cellModel as? ListBindableCellModelWrapper {
      model.willBind()
    }
    self.cellModel = cellModel
    self.cellModel?.cell = self
    updatedCellModel()
  }
}

// MARK: - Constraints
extension SwipeableCell {
  private func setupConstraints() {
    let nonRequiredPriority = UILayoutPriority.notRequired

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

    containerLeadingConstraint
      = containerView.leadingAnchor.constraint(equalTo: contentView.readableContentGuide.leadingAnchor)
    containerLeadingConstraint?.priority = nonRequiredPriority
    containerLeadingConstraint?.isActive = true

    containerTrailingConstraint
      = containerView.trailingAnchor.constraint(equalTo: contentView.readableContentGuide.trailingAnchor)
    containerTrailingConstraint?.priority = nonRequiredPriority
    containerTrailingConstraint?.isActive = true

    containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true

    maxContainerWidthConstraint =
      containerView.widthAnchor.constraint(lessThanOrEqualTo: contentView.readableContentGuide.widthAnchor)
    maxContainerWidthConstraint?.isActive = true

    bottomSeparatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    bottomSeparatorHeightConstraint = bottomSeparatorView.heightAnchor.constraint(equalToConstant: 1)
    bottomSeparatorHeightConstraint?.isActive = true
    containerBottomConstraint = bottomSeparatorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
    containerBottomConstraint?.isActive = true

    topSeparatorLeadingConstraint = topSeparatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
    topSeparatorLeadingConstraint?.isActive = true
    topSeparatorTrailingConstraint = topSeparatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
    topSeparatorTrailingConstraint?.isActive = true

    bottomSeparatorLeadingConstraint = bottomSeparatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
    bottomSeparatorLeadingConstraint?.isActive = true
    bottomSeparatorTrailingConstraint =
      bottomSeparatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
    bottomSeparatorTrailingConstraint?.isActive = true
  }
}
