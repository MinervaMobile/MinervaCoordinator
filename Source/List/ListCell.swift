//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import IGListKit
import UIKit

/// The required class type and protocol for each Cell in Minerva.
public typealias ListCollectionViewCell = UICollectionViewCell & ListCell

/// The cell that will be bound to a ListCellModel
// TODO: Remove this dependency on IGListKit's ListBindable
public protocol ListCell: ListBindable {
  func bind(cellModel: ListCellModel, sizing: Bool)
}

/// Optional protocol that if implemented by a ListCell to better manage a cell's state change.
public protocol ListDisplayableCell: ListCell {
  /// Called when the cell is about to be viewable
  func willDisplayCell()
  /// Called when a cell is no longer viewable
  func didEndDisplayingCell()
}

/// Delegate for ListResizableCell, see below.
public protocol ListResizableCellDelegate: AnyObject {
  /// Called when the cell's layout should be invalidated and updated
  func cellDidInvalidateSize(_ cell: ListResizableCell)
}

/// Optional protocol that if implemented allows a cell to trigger its layout to be invalidated.
public protocol ListResizableCell: ListCollectionViewCell {
  /// Set at cell creation if the protocol is implemented, see delegate methods.
  var resizableDelegate: ListResizableCellDelegate? { get set }
}

/// A convenience protocol that adds typed model information to the class.
public protocol ListTypedCell: ListCell {
  associatedtype ModelType: ListCellModel

  /// Called when a CellModel is bound to the Cell.
  /// - Parameter model: The model to bind to this cell.
  /// - Parameter sizing: True if the cell is being used for autolayout sizing, not actual display, false otherwise.
  func bind(model: ModelType, sizing: Bool)
}

extension ListTypedCell {
  /// Implements the untyped ListCell bind method and calls the ListHelpers
  /// - Parameter cellModel: The model to bind to this cell.
  /// - Parameter sizing: True if the cell is being used for autolayout sizing, not actual display, false otherwise.
  public func bind(cellModel: ListCellModel, sizing: Bool) {
    guard let typedModel = cellModel as? ModelType else {
      assertionFailure("Invalid cellModel type \(cellModel)")
      return
    }
    bind(model: typedModel, sizing: sizing)
  }

  /// Call this method from ListBindable's |bindViewModel| function call.
  /// - Parameter viewModel: The view model that is being bound to this cell.
  public func bind(_ viewModel: Any) {
    guard let wrapper = viewModel as? ListCellModelWrapper else {
      assertionFailure("Invalid view model type \(viewModel)")
      return
    }
    bind(cellModel: wrapper.model, sizing: false)
  }
}

/// This should not be used, it is a placeholder for failures to bridge the IGListKit obj-c to Swift gap.
internal class MissingListCell: ListCollectionViewCell {
  internal func bind(cellModel: ListCellModel, sizing: Bool) {}
  internal func bindViewModel(_ viewModel: Any) {}
}
