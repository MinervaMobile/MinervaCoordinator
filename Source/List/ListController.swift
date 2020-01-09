//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import IGListKit
import UIKit

/// Manages the collection view state and updating the collection view to the provided ListSection's.
public protocol ListController: AnyObject {

  typealias Completion = (Bool) -> Void

  var animationDelegate: ListControllerAnimationDelegate? { get set }
  var reorderDelegate: ListControllerReorderDelegate? { get set }
  var sizeDelegate: ListControllerSizeDelegate? { get set }
  var scrollViewDelegate: UIScrollViewDelegate? { get set }

  var viewController: UIViewController? { get set }
  var collectionView: UICollectionView? { get set }
  var listSections: [ListSection] { get }
  var centerCellModel: ListCellModel? { get }

  func reloadData(completion: Completion?)
  func reload(_ cellModels: [ListCellModel])
  func update(with listSections: [ListSection], animated: Bool, completion: Completion?)
  func removeCellModel(at indexPath: IndexPath, animated: Bool, completion: Completion?)

  func willDisplay()
  func didEndDisplaying()
  func invalidateLayout()

  func indexPaths(for cellModel: ListCellModel) -> [IndexPath]
  func cellModel(at indexPath: IndexPath) -> ListCellModel?

  func scrollTo(
    cellModel: ListCellModel,
    scrollPosition: UICollectionView.ScrollPosition,
    animated: Bool
  )
  func scroll(to scrollPosition: UICollectionView.ScrollPosition, animated: Bool)

  func size(of listSection: ListSection, containerSize: CGSize) -> CGSize
  func size(of cellModel: ListCellModel, with constraints: ListSizeConstraints) -> CGSize
}

extension ListController {
  public func reloadData() {
    reloadData(completion: nil)
  }
  public func update(with listSections: [ListSection], animated: Bool) {
    update(with: listSections, animated: animated, completion: nil)
  }
  public func removeCellModel(at indexPath: IndexPath, animated: Bool) {
    removeCellModel(at: indexPath, animated: animated, completion: nil)
  }
}

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

public protocol ListControllerReorderDelegate: AnyObject {
  func listControllerCompletedMove(
    _ listController: ListController,
    for cellModel: ListCellModel,
    fromIndex: Int,
    toIndex: Int
  )
}

public protocol ListControllerSizeDelegate: AnyObject {
  func listController(
    _ listController: ListController,
    sizeFor model: ListCellModel,
    at indexPath: IndexPath,
    constrainedTo sizeConstraints: ListSizeConstraints
  ) -> CGSize?
}
