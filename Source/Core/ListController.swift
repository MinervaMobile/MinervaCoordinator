//
//  ListController.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import IGListKit

public protocol ListControllerSizeDelegate: class {
  func listController(
    _ listController: ListController,
    sizeFor model: ListCellModel,
    at indexPath: IndexPath,
    constrainedTo sizeConstraints: ListSizeConstraints
  ) -> CGSize?
}

public protocol ListControllerReorderDelegate: class {
  func listControllerCompletedMove(
    _ listController: ListController,
    for cellModel: ListCellModel,
    fromIndex: Int,
    toIndex: Int
  )
}

public protocol ListAnimationDelegate: class {
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

public final class ListController: NSObject {

  public typealias Completion = (Bool) -> Void

  public weak var sizeDelegate: ListControllerSizeDelegate?
  public weak var reorderDelegate: ListControllerReorderDelegate?
  public weak var scrollViewDelegate: UIScrollViewDelegate?
  public weak var animationDelegate: ListAnimationDelegate?

  private let adapter: ListAdapter
  private var noLongerDisplayingCells = false
  private var listSectionWrappers: [ListSectionWrapper]

  public weak var viewController: UIViewController? {
    get { return self.adapter.viewController }
    set { self.adapter.viewController = newValue }
  }

  public var collectionView: UICollectionView? {
    get { return self.adapter.collectionView }
    set { self.adapter.collectionView = newValue }
  }

  public var listSections: [ListSection] {
    return listSectionWrappers.map { $0.section }
  }

  // MARK: - Initializers

  public override init() {
    self.listSectionWrappers = []
    let updater = ListAdapterUpdater()
    self.adapter = ListAdapter(updater: updater, viewController: nil, workingRangeSize: 2)
    super.init()
    self.adapter.scrollViewDelegate = self
    self.adapter.dataSource = self
    self.adapter.moveDelegate = self
  }

  // MARK: - Public

  public func reload(_ cellModels: [ListCellModel]) {
    guard Thread.isMainThread else {
      DispatchQueue.main.async {
        self.reload(cellModels)
      }
      return
    }
    self.adapter.reloadObjects(cellModels.map(ListCellModelWrapper.init))
  }

  public func update(with listSections: [ListSection], animated: Bool, completion: Completion?) {
    guard Thread.isMainThread else {
      DispatchQueue.main.async {
        self.update(with: listSections, animated: animated, completion: completion)
      }
      return
    }
    #if DEBUG
      for section in listSections {
        var identifiers = [String: ListCellModel]()
        for cellModel in section.cellModels {
          let identifier = cellModel.identifier
          if identifier.isEmpty {
            assertionFailure("Found a cell model an invalid ID \(cellModel)")
          }
          if let existingCellModel = identifiers[identifier] {
            assertionFailure("Found a cell model with a duplicate ID \(identifier) - \(cellModel) - \(existingCellModel)")
          }
          identifiers[identifier] = cellModel
        }
      }
    #endif
    self.listSectionWrappers = listSections.map(ListSectionWrapper.init)
    self.adapter.performUpdates(animated: animated, completion: completion)
  }

  public func willDisplay() {
    self.displayVisibleCells()
  }

  public func didEndDisplaying() {
    self.hideVisibleCells()
  }

  public func indexPath(for cellModel: ListCellModel) -> IndexPath? {
    guard let section = self.listSections.firstIndex(where: {
      $0.cellModels.contains(where: { cellModel.isEqual(to: $0) })
    }) else {
      return nil
    }
    guard let item = self.listSections.at(section)?.cellModels.firstIndex(where: { cellModel.isEqual(to: $0) }) else {
      return nil
    }
    return IndexPath(item: item, section: section)
  }

  public var centerCellModel: ListCellModel? {
    guard let indexPath = self.adapter.collectionView?.centerCellIndexPath,
      let cellModel = self.cellModel(at: indexPath) else {
        return nil
    }
    return cellModel
  }

  public var cellModels: [ListCellModel] {
    return self.listSections.flatMap { $0.cellModels }
  }

  public func cellModel(at indexPath: IndexPath) -> ListCellModel? {
    guard let model = self.listSections.at(indexPath.section)?.cellModels.at(indexPath.item) else {
      return nil
    }
    return model
  }

  public func cell(at indexPath: IndexPath) -> UICollectionViewCell? {
    guard let cell = self.adapter.collectionView?.cellForItem(at: indexPath) else {
      return nil
    }
    return cell
  }

  public func cell(for cellModel: ListCellModel) -> UICollectionViewCell? {
    guard let indexPath = self.indexPath(for: cellModel),
      let cell = self.adapter.collectionView?.cellForItem(at: indexPath) else {
        return nil
    }
    return cell
  }

  public func removeCellModel(at indexPath: IndexPath, completion: Completion?) {
    guard self.listSections.at(indexPath.section)?.cellModels.at(indexPath.item) != nil else {
      assertionFailure("Could not find model at indexPath")
      return
    }
    var listSections = self.listSections
    var section = listSections[indexPath.section]
    var cellModels = section.cellModels
    cellModels.remove(at: indexPath.row)

    if cellModels.isEmpty {
      listSections.remove(at: indexPath.section)
    } else {
      section.cellModels = cellModels
      listSections[indexPath.section] = section
    }
    self.update(with: listSections, animated: true, completion: completion)
  }

  public func scrollTo(
    cellModel: ListCellModel,
    scrollPosition: UICollectionView.ScrollPosition,
    animated: Bool
  ) {
    let section = self.listSections.first(where: {
      $0.cellModels.contains(where: { $0.identifier == cellModel.identifier })
    })

    guard let listSection = section else {
      assertionFailure("Section should exist for \(cellModel)")
      return
    }
    guard let sectionController = self.adapter.sectionController(for: listSection) else {
      assertionFailure("Section Controller should exist for \(listSection) and \(cellModel)")
      return
    }
    guard let modelIndex = listSection.cellModels.firstIndex(where: { $0.identifier == cellModel.identifier }) else {
      assertionFailure("index should exist for \(cellModel)")
      return
    }
    let indexPath = IndexPath(item: modelIndex, section: sectionController.section)
    guard self.collectionView?.isIndexPathAvailable(indexPath) ?? false else {
      assertionFailure("IndexPath should exist for \(cellModel)")
      return
    }
    sectionController.collectionContext?.scroll(
      to: sectionController,
      at: modelIndex,
      scrollPosition: scrollPosition,
      animated: animated)
  }

  public func scroll(to scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
    guard !self.cellModels.isEmpty else {
      return
    }
    let model: ListCellModel?
    switch scrollPosition {
    case UICollectionView.ScrollPosition.top, UICollectionView.ScrollPosition.left:
      model = self.cellModels.first
    case UICollectionView.ScrollPosition.centeredVertically,
       UICollectionView.ScrollPosition.centeredHorizontally:
      let middleIndex = self.cellModels.count / 2
      model = self.cellModels.at(middleIndex)
    case UICollectionView.ScrollPosition.bottom, UICollectionView.ScrollPosition.right:
      model = self.cellModels.last
    default:
      assertionFailure("Unrecognized scroll position")
      return
    }

    guard let cellModel = model else {
      return
    }
    self.scrollTo(cellModel: cellModel, scrollPosition: scrollPosition, animated: animated)
  }

  public func size(of cellModel: ListCellModel, with constraints: ListSizeConstraints? = nil) -> CGSize? {
    let sectionWrapper = self.listSectionWrappers.first(where: {
      $0.section.cellModels.contains(where: { $0.identifier == cellModel.identifier })
    })

    let sectionController: ListModelSectionController
    let sizeConstraints: ListSizeConstraints

    // If this function is called before the adapter is showing the cellModel we still want to return the correct size.
    // Reuse the existing ListModelSectionController if it is available in order to support caching of size information.
    if let listSectionWrapper = sectionWrapper,
      let controller = adapter.sectionController(for: listSectionWrapper) as? ListModelSectionController,
      let constraints = controller.sizeConstraints {
      sectionController = controller
      sizeConstraints = constraints
    } else if let constraints = constraints {
      sectionController = ListModelSectionController()
      sizeConstraints = constraints
    } else {
      assertionFailure("Need a section to properly size the cell")
      return nil
    }

    let size = sectionController.size(for: cellModel, with: sizeConstraints)
    switch size {
    case .autolayout:
      return sectionController.autolayoutSize(for: cellModel, constrainedTo: sizeConstraints)
    case .explicit(let size):
      return size
    case .relative:
      return nil
    }
  }

  // MARK: - Helpers

  private func displayVisibleCells() {
    guard Thread.isMainThread else {
      DispatchQueue.main.async {
        self.displayVisibleCells()
      }
      return
    }
    guard noLongerDisplayingCells else { return }
    guard let visibleCells = adapter.collectionView?.visibleCells else { return }
    visibleCells.compactMap { $0 as? ListCell }.forEach { $0.willDisplayCell() }
    noLongerDisplayingCells = false
  }

  private func hideVisibleCells() {
    guard Thread.isMainThread else {
      DispatchQueue.main.async {
        self.hideVisibleCells()
      }
      return
    }
    guard !noLongerDisplayingCells else { return }
    guard let visibleCells = adapter.collectionView?.visibleCells else { return }
    visibleCells.compactMap { $0 as? ListCell }.forEach { $0.didEndDisplayingCell() }
    noLongerDisplayingCells = true
  }
}

// MARK: - ListAdapterDataSource
extension ListController: ListAdapterDataSource {
  public func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
    return self.listSectionWrappers
  }

  public func listAdapter(
    _ listAdapter: ListAdapter,
    sectionControllerFor object: Any
  ) -> ListSectionController {
    let sectionController = ListModelSectionController()
    sectionController.delegate = self
    return sectionController
  }

  public func emptyView(for listAdapter: ListAdapter) -> UIView? {
    return nil
  }
}

// MARK: - ListAdapterMoveDelegate
extension ListController: ListAdapterMoveDelegate {
  public func listAdapter(
    _ listAdapter: ListAdapter,
    move object: Any,
    from previousObjects: [Any],
    to objects: [Any]
  ) {
    guard let sections = objects as? [ListSectionWrapper] else {
      assertionFailure("Invalid object types \(objects)")
      return
    }
    self.listSectionWrappers = sections
  }
}

// MARK: - ListModelSectionControllerDelegate
extension ListController: ListModelSectionControllerDelegate {
  internal func sectionController(
    _ sectionController: ListModelSectionController,
    sizeFor model: ListCellModel,
    at indexPath: IndexPath,
    constrainedTo sizeConstraints: ListSizeConstraints
  ) -> CGSize? {
    return sizeDelegate?.listController(
      self,
      sizeFor: model,
      at: indexPath,
      constrainedTo: sizeConstraints
    )
  }

  internal func sectionControllerCompletedMove(
    _ sectionController: ListModelSectionController,
    for cellModel: ListCellModel,
    fromIndex: Int,
    toIndex: Int
  ) {
    reorderDelegate?.listControllerCompletedMove(self, for: cellModel, fromIndex: fromIndex, toIndex: toIndex)
  }

  internal func sectionController(
    _ sectionController: ListModelSectionController,
    initialLayoutAttributes attributes: ListViewLayoutAttributes,
    for section: ListSection,
    at indexPath: IndexPath
  ) -> ListViewLayoutAttributes? {
    return animationDelegate?.listController(self, initialLayoutAttributes: attributes, for: section, at: indexPath)
  }

  internal func sectionController(
    _ sectionController: ListModelSectionController,
    finalLayoutAttributes attributes: ListViewLayoutAttributes,
    for section: ListSection,
    at indexPath: IndexPath
  ) -> ListViewLayoutAttributes? {
    return animationDelegate?.listController(self, finalLayoutAttributes: attributes, for: section, at: indexPath)
  }
}

// MARK: - UIScrollViewDelegate
extension ListController: UIScrollViewDelegate {
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if let delegate = self.scrollViewDelegate,
      delegate.responds(to: #selector(scrollViewDidScroll(_:))) {
      delegate.scrollViewDidScroll?(scrollView)
    }
  }

  public func scrollViewDidEndDragging(
    _ scrollView: UIScrollView,
    willDecelerate decelerate: Bool
  ) {
    if let delegate = self.scrollViewDelegate,
      delegate.responds(to: #selector(scrollViewDidEndDragging(_: willDecelerate:))) {
      delegate.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
  }

  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    if let delegate = self.scrollViewDelegate,
      delegate.responds(to: #selector(scrollViewDidEndDecelerating(_:))) {
      delegate.scrollViewDidEndDecelerating?(scrollView)
    }
  }
}
