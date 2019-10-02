//
//  BaseListCell.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

open class BaseListCell: ListCollectionViewCell {

  open class Model: ListCellModel {

    public init() { }

    // MARK: - ListCellModel
    open var description: String {
      return typeDescription
    }
    open var reorderable: Bool {
      return false
    }
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

  open private(set) var cellModel: ListCellModel?

  override public init(frame: CGRect = .zero) {
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
    updatedCellModel()
  }

  open func updatedCellModel() {
  }

  open func willDisplayCell() {
  }

  open func didEndDisplayingCell() {
  }

  // MARK: - ListBindable

  open func bindViewModel(_ viewModel: Any) {
    guard let wrapper = viewModel as? ListCellModelWrapper else {
      assertionFailure("Invalid view model \(viewModel)")
      return
    }
    if let model = wrapper.model as? ListBindableCellModelWrapper {
      model.willBind()
    }
    self.cellModel = wrapper.model
    updatedCellModel()
  }
}
