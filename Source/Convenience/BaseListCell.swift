//
//  BaseListCell.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

open class BaseListCellModel: ListCellModel {

  public init() { }

  // MARK: - ListCellModel
  open var identifier: String {
    return typeIdentifier
  }
  open var cellType: ListCollectionViewCell.Type {
    return cellTypeFromModelName
  }

  open func identical(to model: ListCellModel) -> Bool {
    return identifier == model.identifier
  }
  open func size(
    constrainedTo containerSize: CGSize,
    with templateProvider: () -> ListCollectionViewCell
  ) -> ListCellSize {
    return .autolayout
  }
}

open class BaseListCell: ListCollectionViewCell {

  open private(set) var cellModel: ListCellModel?

  public override init(frame: CGRect) {
    super.init(frame: frame)
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
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
    didUpdateCellModel()
  }

  open func didUpdateCellModel() {
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
