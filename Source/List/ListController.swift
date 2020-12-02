//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import IGListKit
import UIKit

/// Manages the collection view state and updating the collection view to the provided ListSection's.
public protocol ListController: AnyObject {
  /// A block to be called when a method completes.  True if finished successfully.
  typealias Completion = (Bool) -> Void

  /// Set this delegate to control animations when cells appear / disappear.
  var animationDelegate: ListControllerAnimationDelegate? { get set }

  /// This delegate provides information on when a cell is moved.
  var reorderDelegate: ListControllerReorderDelegate? { get set }

  /// This must be set when you use relative sized cells.
  var sizeDelegate: ListControllerSizeDelegate? { get set }

  /// Minerva must be the scrollView delegate so set your delegate here if you need the callbacks.
  var scrollViewDelegate: UIScrollViewDelegate? { get set }

  /// The view controller that the list is bound to.
  var viewController: UIViewController? { get set }

  /// The collection view that will be updated when the data changes.
  var collectionView: UICollectionView? { get set }

  /// The current sections based on the last call to update, reload, or remove.
  var listSections: [ListSection] { get }

  /// The cell model at the center of the list
  var centerCellModel: ListCellModel? { get }

  /// Reloads all cells on the collection view with the previously set [ListSection]
  /// - Parameter completion: A block to execute when the reload completes.
  func reloadData(completion: Completion?)

  /// Replaces the existing list sections with those specified. If a CellModel has the same identifier it will be updated if identical evaluates to false, otherwise
  /// The newly provided CellModel is ignored.
  /// - Parameters:
  ///   - listSections: The sections to bind to the collection view.
  ///   - animated: Whether or not to animate the change.
  ///   - completion: A block to execute when the update completes.
  func update(with listSections: [ListSection], animated: Bool, completion: Completion?)

  /// Removes a cell model at a specific IndexPath, triggering an update to remove the cell from the collection view.
  /// - Parameters:
  ///   - indexPath: The indexPath of the cell model to remove.
  ///   - animated: Whether or not to animate the change.
  ///   - completion: A block to execute when the remove completes.
  func removeCellModel(at indexPath: IndexPath, animated: Bool, completion: Completion?)

  /// Call this when a viewController will become visible, it will add
  func willDisplay()

  /// This can be used to remove all cells from the collection view to collect back any memory
  func didEndDisplaying()

  /// Clears the autolayout cache and forces the models to recalculate their size.
  func invalidateLayout()

  /// Finds the IndexPath's for a given cell model, if it is present in the list.
  /// - Parameter cellModel: The cell model to find in the current list sections.
  func indexPath(for cellModel: ListCellModel) -> IndexPath?

  /// Returns the cell model for a given IndexPath if one exists.
  /// - Parameter indexPath: The IindexPath of the cellModel you want.
  func cellModel(at indexPath: IndexPath) -> ListCellModel?

  /// Scrolls to the specified cell if it's bound model matches the identifier and identical method evaluates to true.
  /// - Parameters:
  ///   - cellModel: The cell model to scroll to.
  ///   - scrollPosition: The location to scroll the cell to.
  ///   - animated: Whether or not to animate the scroll.
  func scrollTo(
    cellModel: ListCellModel,
    scrollPosition: UICollectionView.ScrollPosition,
    animated: Bool
  )

  /// Scrolls the collection view to a specific location.
  /// - Parameters:
  ///   - scrollPosition: The location to scroll the collection view to.
  ///   - animated: Whether or not to animate the scroll.
  func scroll(to scrollPosition: UICollectionView.ScrollPosition, animated: Bool)

  /// Provides the size for the specified ListSection.
  /// - Parameters:
  ///   - listSection: The section to calculate the size of.
  ///   - containerSize: The container size to constrain the size of each cell when calculating their size.
  func size(of listSection: ListSection, containerSize: CGSize) -> CGSize

  /// Provides the size for the specified CellModel.
  /// - Parameters:
  ///   - cellModel: The cell model to calculate a size for.
  ///   - constraints: Specifies the constraints to use when calculating the size.
  func size(of cellModel: ListCellModel, with constraints: ListSizeConstraints) -> CGSize
}

extension ListController {
  /// Reloads all cells on the collection view with the previously set [ListSection]
  public func reloadData() {
    reloadData(completion: nil)
  }

  /// Replaces the existing list sections with those specified. If a CellModel has the same identifier it will be updated if identical evaluates to false, otherwise
  /// The newly provided CellModel is ignored.
  public func update(with listSections: [ListSection], animated: Bool) {
    update(with: listSections, animated: animated, completion: nil)
  }

  /// Removes a cell model at a specific IndexPath, triggering an update to remove the cell from the collection view.
  public func removeCellModel(at indexPath: IndexPath, animated: Bool) {
    removeCellModel(at: indexPath, animated: animated, completion: nil)
  }
}

/// Control animations when cells appear / disappear.
public protocol ListControllerAnimationDelegate: AnyObject {
  func listController(
    _ listController: ListController,
    initialLayoutAttributes attributes: ListViewLayoutAttributes,
    for section: ListSection,
    at indexPath: IndexPath
  ) -> ListViewLayoutAttributes?
  func listController(
    _ listController: ListController,
    finalLayoutAttributes attributes: ListViewLayoutAttributes,
    for section: ListSection,
    at indexPath: IndexPath
  ) -> ListViewLayoutAttributes?
}

/// Provides information on when a cell is moved.
public protocol ListControllerReorderDelegate: AnyObject {
  func listController(
    _ listController: ListController,
    moved cellModel: ListCellModel,
    fromIndex: Int,
    toIndex: Int
  )
}

/// Adds support for relative sized cells.
public protocol ListControllerSizeDelegate: AnyObject {
  func listController(
    _ listController: ListController,
    sizeFor model: ListCellModel,
    at indexPath: IndexPath,
    constrainedTo sizeConstraints: ListSizeConstraints
  ) -> CGSize?
}
