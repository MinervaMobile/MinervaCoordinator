//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import UIKit

/// Specifies how the cell will size itself.
public enum ListCellSize: Equatable {
  /// Bind the model to a template view and have the system determine the size.
  case autolayout
  /// Provides the exact size the cell should occupy.
  case explicit(size: CGSize)
  /// Delegates the sizing decision to the |ListControllerSizeDelegate|
  case relative
}

/// The model that will bind to a cell.
public protocol ListCellModel {
  /// A unique identifier for the cell model. If the model identifiers are different,
  /// the cells are assumed to be completely different triggering a delete and
  /// an insert of a new cell.
  var identifier: String { get }

  /// The type of list cell that this model should be bound to.
  var cellType: ListCollectionViewCell.Type { get }

  /// Determines if two models with the same identifier are equal. If they are not, then the cell is reloaded and bound to the new model.
  /// - Parameter model: The model to compare against.
  func identical(to model: ListCellModel) -> Bool

  /// Provides the size that the models cell will need.
  /// - Parameter containerSize: The max size that the cell can occupy.
  func size(constrainedTo containerSize: CGSize) -> ListCellSize
}

extension ListCellModel {
  /// A simple description of the cell model that displays the type and identifier.
  public var typeDescription: String {
    "[\(String(describing: type(of: self))) \(identifier)]"
  }
}

extension ListCellModel where Self: AnyObject {
  /// Provides a unique identifier based on the objects memory reference.
  public var typeIdentifier: String {
    let identifier = String(describing: Unmanaged.passUnretained(self).toOpaque())
    guard !identifier.isEmpty else {
      assertionFailure("The identifier should exist for \(self)")
      return UUID().uuidString
    }
    return identifier
  }

  /// Determines the cell type from the current models name.  This will only work if the names follow the pattern:
  /// MyCellModel and MyCell where the Cell name is the Model's name after removing Model from the end.
  public var cellTypeFromModelName: ListCollectionViewCell.Type {
    let modelType = type(of: self)
    let className = String(describing: modelType).replacingOccurrences(of: "Model", with: "")
    if let cellType = NSClassFromString(className) as? ListCollectionViewCell.Type {
      return cellType
    }
    let minervaClassName = "Minerva.\(className)"
    if let cellType = NSClassFromString(minervaClassName) as? ListCollectionViewCell.Type {
      return cellType
    }
    let bundle = Bundle(for: modelType)
    let bundleName = bundle.infoDictionary?["CFBundleName"] as? String ?? ""
    let fullClassName = "\(bundleName).\(className)"
    let cleanedClassName = fullClassName.replacingOccurrences(of: " ", with: "_")
    if let cellType = NSClassFromString(cleanedClassName) as? ListCollectionViewCell.Type {
      return cellType
    }
    assertionFailure("Unable to determine the cell type")
    return MissingListCell.self
  }
}

extension ListCellModel where Self: Equatable {
  public func identical(to model: ListCellModel) -> Bool {
    guard let other = model as? Self else { return false }
    return self == other
  }
}

/// If a cell model conforms to this protocol it will support the collection views native move logic
/// if reorderable returns true.
public protocol ListReorderableCellModel {
  var reorderable: Bool { get }
}

/// This should not be used directly, conform to ListSelectableCellModel instead.
public protocol ListSelectableCellModelWrapper {
  func selected(at indexPath: IndexPath)
}

/// If a cell is selectable it should conform to this protocol and set a block to be
/// called when selected. Headers and Footers can not be selected using this protocol.
public protocol ListSelectableCellModel: ListSelectableCellModelWrapper {
  associatedtype SelectableModelType: ListCellModel
  typealias SelectionAction = (_ cellModel: SelectableModelType, _ indexPath: IndexPath) -> Void

  /// The block to use when the cell is selected.
  var selectionAction: SelectionAction? { get }
}

extension ListSelectableCellModel {
  public func selected(at indexPath: IndexPath) {
    guard let model = self as? SelectableModelType else {
      assertionFailure("Invalid model type \(self) for \(SelectableModelType.self)")
      return
    }
    selectionAction?(model, indexPath)
  }
}

/// This should not be used directly, conform to ListHighlightableCellModel instead.
public protocol ListHighlightableCellModelWrapper {
  /// If true, highlighting will be enabled and the highlight/unhighlight methods will be called.
  var highlightEnabled: Bool { get }
  /// The color that will be shown on the cell when highlighted.
  var highlightColor: UIColor? { get set }
  /// Called when the cell is highlighted.
  func highlighted(at indexPath: IndexPath)
  /// Called when the cell is unhighlighted.
  func unhighlighted(at indexPath: IndexPath)
}

/// A protocol that models can conform to for cell highlighting.
public protocol ListHighlightableCellModel: ListHighlightableCellModelWrapper {
  associatedtype HighlightableModelType: ListCellModel
  typealias HighlightAction = (_ cellModel: HighlightableModelType, _ indexPath: IndexPath) -> Void

  /// The block to use when the cell is selected.
  var highlightedAction: HighlightAction? { get }
  var unhighlightedAction: HighlightAction? { get }
}

extension ListHighlightableCellModel {
  public func highlighted(at indexPath: IndexPath) {
    guard let model = self as? HighlightableModelType else {
      assertionFailure("Invalid model type \(self) for \(HighlightableModelType.self)")
      return
    }
    highlightedAction?(model, indexPath)
  }

  public func unhighlighted(at indexPath: IndexPath) {
    guard let model = self as? HighlightableModelType else {
      assertionFailure("Invalid model type \(self) for \(HighlightableModelType.self)")
      return
    }
    unhighlightedAction?(model, indexPath)
  }
}

/// Adds type information to the cell model with convenient type safe functions.
public protocol ListTypedCellModel: ListCellModel {
  associatedtype CellType: ListCollectionViewCell

  /// Determines if two models with the same identifier are equal. If they are not, then the cell is reloaded and bound to the new model.
  /// - Parameter model: The model to compare against.
  func identical(to model: Self) -> Bool
}

extension ListTypedCellModel {
  public var cellType: ListCollectionViewCell.Type { CellType.self }

  public func identical(to other: ListCellModel) -> Bool {
    guard let model = other as? Self else { return false }
    return identical(to: model)
  }
}

extension ListTypedCellModel where Self: Equatable {
  public func identical(to model: Self) -> Bool {
    self == model
  }
}
