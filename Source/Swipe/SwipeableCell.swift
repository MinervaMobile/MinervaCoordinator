//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import IGListKit
import RxSwift
import SwipeCellKit
import UIKit

open class SwipeableCellModel: BaseListCellModel {
  public var directionalLayoutMargins = NSDirectionalEdgeInsets(
    top: 8,
    leading: 16,
    bottom: 8,
    trailing: 16
  )
  public var backgroundColor: UIColor?

  override open func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return backgroundColor == model.backgroundColor
      && directionalLayoutMargins == model.directionalLayoutMargins
  }
}

open class SwipeableCell<CellModelType: SwipeableCellModel>: SwipeCollectionViewCell, ListCell {
  public private(set) var disposeBag = DisposeBag()

  open private(set) var model: CellModelType?
  open private(set) var highlightView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isHidden = true
    return view
  }()

  override open var isHighlighted: Bool {
    didSet {
      guard
        let highlightModel = model as? ListHighlightableCellModelWrapper,
        highlightModel.highlightEnabled
      else {
        highlightView.isHidden = true
        return
      }

      highlightView.isHidden = !isHighlighted
    }
  }

  public let containerView = UIView()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(containerView)
    contentView.addSubview(highlightView)
    containerView.anchorTo(layoutGuide: contentView.layoutMarginsGuide)
    highlightView.anchor(to: contentView)
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
      layer.add(animation, forKey: nil)
    }
  }

  override open func prepareForReuse() {
    super.prepareForReuse()
    model = nil
    disposeBag = DisposeBag()
  }

  open func bind(model: CellModelType, sizing: Bool) {
    contentView.directionalLayoutMargins = model.directionalLayoutMargins
    guard !sizing else { return }
    disposeBag = DisposeBag()
    self.model = model

    if let highlightableViewModel = model as? ListHighlightableCellModelWrapper {
      highlightView.backgroundColor = highlightableViewModel.highlightColor
    }

    contentView.backgroundColor = model.backgroundColor
    accessibilityIdentifier = model.accessibilityIdentifier
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
