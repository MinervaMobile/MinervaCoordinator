//
//  ListCell.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import IGListKit

// TODO: Remove this dependency on IGListKit's ListBindable
public typealias ListCollectionViewCell = UICollectionViewCell & ListCell

// MARK: - ListCell
public protocol ListCell: ListBindable {
  func bind(cellModel: ListCellModel, sizing: Bool)
}

// MARK: - ListCellHelper
public protocol ListDisplayableCell: ListCell {
  func willDisplayCell()
  func didEndDisplayingCell()
}

// MARK: - ListCellHelper
public protocol ListCellHelper: ListCell {
  associatedtype ModelType: ListCellModel

  func bind(model: ModelType, sizing: Bool)
}

extension ListCellHelper {
  public func bind(cellModel: ListCellModel, sizing: Bool) {
    guard let typedModel = cellModel as? ModelType else {
      assertionFailure("Invalid cellModel type \(cellModel)")
      return
    }
    bind(model: typedModel, sizing: sizing)
  }

  public func bind(_ viewModel: Any) {
    guard let wrapper = viewModel as? ListCellModelWrapper else {
      assertionFailure("Invalid view model type \(viewModel)")
      return
    }
    if let model = wrapper.model as? ListBindableCellModelWrapper {
      model.willBind()
    }
    bind(cellModel: wrapper.model, sizing: false)
  }
}

// This should not be used, it is a placeholder for failures to bridge the IGListKit obj-c to Swift gap.
internal class BaseListCell: ListCollectionViewCell {
  func bind(cellModel: ListCellModel, sizing: Bool) { }
  func bindViewModel(_ viewModel: Any) { }
}
