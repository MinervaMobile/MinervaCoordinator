//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import IGListKit
import RxSwift
import SwipeCellKit
import UIKit

open class SwipeableCellModel: BaseListCellModel {

  public var directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
  public var backgroundColor: UIColor?

  public var separatorColor: UIColor?
  public var separatorLeadingInset = false

  override open func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return separatorColor == model.separatorColor
      && separatorLeadingInset == model.separatorLeadingInset
      && backgroundColor == model.backgroundColor
      && directionalLayoutMargins == model.directionalLayoutMargins
  }
}

open class SwipeableCell<CellModelType: SwipeableCellModel>: SwipeCollectionViewCell, ListCell, ListBindable {
  public var disposeBag = DisposeBag()

  open private(set) var model: CellModelType?

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
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override open func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
    super.apply(layoutAttributes)
    guard let attributes = layoutAttributes as? ListViewLayoutAttributes else {
      return
    }
    if let animation = attributes.animationGroup {
      self.layer.add(animation, forKey: nil)
    }
  }

  override open func prepareForReuse() {
    super.prepareForReuse()
    model = nil
    disposeBag = DisposeBag()
  }

  open func bind(model: CellModelType, sizing: Bool) {
    if !sizing {
      // Run the willBind function before reading any data from the model
      if let model = model as? ListBindableCellModelWrapper {
        model.willBind()
      }
      self.model = model
    }
    contentView.directionalLayoutMargins = model.directionalLayoutMargins
    remakeConstraints(with: model)

    guard !sizing else { return }

    contentView.backgroundColor = model.backgroundColor
    bottomSeparatorView.backgroundColor = model.separatorColor
  }

  // MARK: - ListCell

  public final func bindViewModel(_ viewModel: Any) {
    guard let wrapper = viewModel as? ListCellModelWrapper else {
      assertionFailure("Invalid view model \(viewModel)")
      return
    }
    bind(cellModel: wrapper.model, sizing: false)
  }

  public final func bind(cellModel: ListCellModel, sizing: Bool) {
    guard let model = cellModel as? CellModelType else {
      assertionFailure("Unknown cell model type \(CellModelType.self) for \(cellModel)")
      self.model = nil
      return
    }
    bind(model: model, sizing: sizing)
  }
}

// MARK: - Constraints
extension SwipeableCell {

  private func remakeConstraints(with model: SwipeableCellModel) {
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
