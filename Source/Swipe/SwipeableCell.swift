//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import IGListKit
import RxSwift
import SwipeCellKit
import UIKit

open class SwipeableCellModel: BaseListCellModel {

  public var directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
  public var backgroundColor: UIColor?

  public var separatorColor: UIColor?
  public var separatorLeadingInset = false

  override open func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? SwipeableCellModel else {
      return false
    }
    return separatorColor == model.separatorColor
      && separatorLeadingInset == model.separatorLeadingInset
      && backgroundColor == model.backgroundColor
      && directionalLayoutMargins == model.directionalLayoutMargins
  }
}

open class SwipeableCell: SwipeCollectionViewCell, ListCell, ListBindable {
  public var disposeBag = DisposeBag()

  open private(set) var cellModel: ListCellModel?

  private var insetLeadingSeparatorConstraint: NSLayoutConstraint?
  private var leadingSeparatorConstraint: NSLayoutConstraint?

  public let containerView = UIView()
  public let bottomSeparatorView = UIView()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(containerView)
    contentView.addSubview(bottomSeparatorView)
    setupConstraints()
  }

  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override open func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
    super.apply(layoutAttributes)
    if let attributes = layoutAttributes as? ListViewLayoutAttributes,
      let animation = attributes.animationGroup {
      self.layer.add(animation, forKey: nil)
    }
  }

  override open func prepareForReuse() {
    super.prepareForReuse()
    cellModel = nil
    disposeBag = DisposeBag()
    didUpdateCellModel()
  }

  override open func updateConstraints() {
    remakeConstraints()
    super.updateConstraints()
  }

  open func didUpdateCellModel() {
    guard let model = self.cellModel as? SwipeableCellModel else { return }
    contentView.backgroundColor = model.backgroundColor
    bottomSeparatorView.backgroundColor = model.separatorColor
    contentView.directionalLayoutMargins = model.directionalLayoutMargins
    setNeedsUpdateConstraints()
  }

  public final func bind(cellModel: ListCellModel, sizing: Bool) {
    if let model = cellModel as? ListBindableCellModelWrapper {
      model.willBind()
    }
    self.cellModel = cellModel
    didUpdateCellModel()
  }

  // MARK: - ListBindable

  public final func bindViewModel(_ viewModel: Any) {
    guard let wrapper = viewModel as? ListCellModelWrapper else {
      assertionFailure("Invalid view model \(viewModel)")
      return
    }
    bind(cellModel: wrapper.model, sizing: false)
  }
}

// MARK: - Constraints
extension SwipeableCell {

  private func remakeConstraints() {
    guard let model = self.cellModel as? SwipeableCellModel else { return }
    leadingSeparatorConstraint?.isActive = !model.separatorLeadingInset
    insetLeadingSeparatorConstraint?.isActive = model.separatorLeadingInset
  }
  private func setupConstraints() {
    let layoutGuide = contentView.layoutMarginsGuide
    containerView.anchorTo(layoutGuide: layoutGuide)

    insetLeadingSeparatorConstraint = bottomSeparatorView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor)
    leadingSeparatorConstraint = bottomSeparatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
    leadingSeparatorConstraint?.isActive = true

    bottomSeparatorView.anchorHeight(to: 1)
    bottomSeparatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    bottomSeparatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

  }
}
