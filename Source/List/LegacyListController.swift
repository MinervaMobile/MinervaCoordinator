//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import IGListKit
import UIKit

public final class LegacyListController: NSObject, ListController {

  public typealias Completion = (Bool) -> Void

  public weak var animationDelegate: ListControllerAnimationDelegate?
  public weak var reorderDelegate: ListControllerReorderDelegate?
  public weak var sizeDelegate: ListControllerSizeDelegate?

  public weak var scrollViewDelegate: UIScrollViewDelegate? {
    get { self.adapter.scrollViewDelegate }
    set { self.adapter.scrollViewDelegate = newValue }
  }

  public weak var viewController: UIViewController? {
    get { self.adapter.viewController }
    set { self.adapter.viewController = newValue }
  }

  public var collectionView: UICollectionView? {
    get { self.adapter.collectionView }
    set { self.adapter.collectionView = newValue }
  }

  public var listSections: [ListSection] { listSectionWrappers.map { $0.section } }

  private let adapter: ListAdapter
  private var noLongerDisplayingCells = false
  private var listSectionWrappers: [ListSectionWrapper]
  private var sizeController: ListCellSizeController

  // MARK: - Initializers

  override public init() {
    self.sizeController = ListCellSizeController()
    self.listSectionWrappers = []
    let updater = ListAdapterUpdater()
    self.adapter = ListAdapter(updater: updater, viewController: nil)
    super.init()
    self.sizeController.delegate = self
    self.adapter.dataSource = self
    self.adapter.moveDelegate = self
  }

  // MARK: - Public

  public func reloadData(completion: Completion?) {
    dispatchPrecondition(condition: .onQueue(.main))
    adapter.reloadData { [weak self] finished in
      if let strongSelf = self, strongSelf.noLongerDisplayingCells {
        strongSelf.endDisplayingVisibleCells()
      }
      completion?(finished)
    }
  }

  public func update(with listSections: [ListSection], animated: Bool, completion: Completion?) {
    dispatchPrecondition(condition: .onQueue(.main))
    #if DEBUG
    var identifiers = [String: ListCellModel]()  // Should be unique across ListSections in the same UICollectionView.
    for section in listSections {
      for cellModel in section.cellModels {
        let identifier = cellModel.identifier
        if identifier.isEmpty {
          assertionFailure("Found a cell model with an invalid ID \(cellModel)")
        }
        if let existingCellModel = identifiers[identifier] {
          assertionFailure(
            "Found a cell model with a duplicate ID \(identifier) - \(cellModel) - \(existingCellModel)"
          )
        }
        identifiers[identifier] = cellModel
      }
    }
    #endif
    listSectionWrappers = listSections.map(ListSectionWrapper.init)
    adapter.performUpdates(animated: animated) { [weak self] finished in
      if let strongSelf = self, strongSelf.noLongerDisplayingCells {
        strongSelf.endDisplayingVisibleCells()
      }
      completion?(finished)
    }
  }

  public func willDisplay() {
    dispatchPrecondition(condition: .onQueue(.main))
    guard noLongerDisplayingCells else { return }
    guard let visibleCells = adapter.collectionView?.visibleCells else { return }
    visibleCells.compactMap { $0 as? ListDisplayableCell }.forEach { $0.willDisplayCell() }
    noLongerDisplayingCells = false
  }

  public func didEndDisplaying() {
    dispatchPrecondition(condition: .onQueue(.main))
    guard !noLongerDisplayingCells else { return }
    endDisplayingVisibleCells()
    noLongerDisplayingCells = true
  }

  public func invalidateLayout() {
    dispatchPrecondition(condition: .onQueue(.main))
    sizeController.clearCache()
  }

  public func indexPath(for cellModel: ListCellModel) -> IndexPath? {
    dispatchPrecondition(condition: .onQueue(.main))
    for (sectionIndex, section) in listSections.enumerated() {
      for (rowIndex, model) in section.cellModels.enumerated() {
        if cellModel.identifier == model.identifier && cellModel.identical(to: model) {
          return IndexPath(item: rowIndex, section: sectionIndex)
        }
      }
    }
    return nil
  }

  public var centerCellModel: ListCellModel? {
    dispatchPrecondition(condition: .onQueue(.main))
    guard let indexPath = adapter.collectionView?.centerCellIndexPath,
      let cellModel = cellModel(at: indexPath)
    else {
      return nil
    }
    return cellModel
  }

  public func cellModel(at indexPath: IndexPath) -> ListCellModel? {
    dispatchPrecondition(condition: .onQueue(.main))
    guard let model = listSections.at(indexPath.section)?.cellModels.at(indexPath.item) else {
      return nil
    }
    return model
  }

  public func removeCellModel(at indexPath: IndexPath, animated: Bool, completion: Completion?) {
    dispatchPrecondition(condition: .onQueue(.main))
    guard listSections.at(indexPath.section)?.cellModels.at(indexPath.item) != nil else {
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
    update(with: listSections, animated: animated, completion: completion)
  }

  public func scrollTo(
    cellModel: ListCellModel,
    scrollPosition: UICollectionView.ScrollPosition,
    animated: Bool
  ) {
    dispatchPrecondition(condition: .onQueue(.main))

    guard
      let sectionWrapper = listSectionWrappers.first(where: {
        $0.section.cellModels.contains(where: { $0.identifier == cellModel.identifier })
      })
    else {
      assertionFailure("Section should exist for \(cellModel)")
      return
    }
    guard let sectionController = adapter.sectionController(for: sectionWrapper) else {
      assertionFailure("Section Controller should exist for \(sectionWrapper) and \(cellModel)")
      return
    }
    guard
      let modelIndex = sectionWrapper.section.cellModels.firstIndex(where: {
        $0.identifier == cellModel.identifier
      })
    else {
      assertionFailure("index should exist for \(cellModel)")
      return
    }
    let indexPath = IndexPath(item: modelIndex, section: sectionController.section)
    guard collectionView?.isIndexPathAvailable(indexPath) ?? false else {
      assertionFailure("IndexPath should exist for \(cellModel)")
      return
    }
    sectionController.collectionContext?
      .scroll(
        to: sectionController,
        at: modelIndex,
        scrollPosition: scrollPosition,
        animated: animated
      )
  }

  public func scroll(to scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
    dispatchPrecondition(condition: .onQueue(.main))
    guard !listSections.isEmpty else { return }
    let cellModels = listSections.flatMap { $0.cellModels }
    guard !cellModels.isEmpty else { return }
    let model: ListCellModel?
    switch scrollPosition {
    case .top, .left:
      model = cellModels.first
    case .centeredVertically, .centeredHorizontally:
      let middleIndex = cellModels.count / 2
      model = cellModels.at(middleIndex)
    case .bottom, .right:
      model = cellModels.last
    default:
      model = cellModels.first
    }

    guard let cellModel = model else { return }
    scrollTo(cellModel: cellModel, scrollPosition: scrollPosition, animated: animated)
  }

  public func size(of listSection: ListSection, containerSize: CGSize) -> CGSize {
    dispatchPrecondition(condition: .onQueue(.main))
    let sizeConstraints = ListSizeConstraints(
      containerSize: containerSize,
      sectionConstraints: listSection.constraints
    )

    guard let sectionIndex = sectionIndexOf(listSection) else { return .zero }
    return sizeController.size(of: listSection, atSectionIndex: sectionIndex, with: sizeConstraints)
  }

  public func size(of cellModel: ListCellModel, with constraints: ListSizeConstraints) -> CGSize {
    dispatchPrecondition(condition: .onQueue(.main))

    let indexPath = self.indexPath(for: cellModel)
    let listSection: ListSection?
    if let indexPath = indexPath {
        listSection = listSections.at(indexPath.section)
    } else {
        listSection = nil
    }

    return sizeController.size(for: cellModel, at: indexPath, in: listSection, with: constraints, enableSizeByDelegate: false)
  }

  // MARK: - Private

  private func endDisplayingVisibleCells() {
    guard let visibleCells = adapter.collectionView?.visibleCells else { return }
    visibleCells.compactMap { $0 as? ListDisplayableCell }.forEach { $0.didEndDisplayingCell() }
  }

  private func sectionIndexOf(_ listSection: ListSection) -> Int? {
    guard let sectionIndex = listSections.firstIndex(where: { $0.identifier == listSection.identifier }) else {
      assertionFailure(
        "The listSection should be in listSections"
      )
      return nil
    }
    return sectionIndex
  }
}

// MARK: - ListAdapterDataSource
extension LegacyListController: ListAdapterDataSource {
  public func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
    listSectionWrappers
  }

  public func listAdapter(
    _ listAdapter: ListAdapter,
    sectionControllerFor object: Any
  ) -> ListSectionController {
    let sectionController = ListModelSectionController(sizeController: sizeController)
    sectionController.delegate = self
    return sectionController
  }

  public func emptyView(for listAdapter: ListAdapter) -> UIView? { nil }
}

// MARK: - ListAdapterMoveDelegate
extension LegacyListController: ListAdapterMoveDelegate {
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

// MARK: - ListCellSizeControllerDelegate
extension LegacyListController: ListCellSizeControllerDelegate {
  internal func sizeController(
    _ sizeController: ListCellSizeController,
    sizeFor model: ListCellModel,
    at indexPath: IndexPath,
    constrainedTo sizeConstraints: ListSizeConstraints
  ) -> CGSize? {
    sizeDelegate?
      .listController(
        self,
        sizeFor: model,
        at: indexPath,
        constrainedTo: sizeConstraints
      )
  }
}

// MARK: - ListModelSectionControllerDelegate
extension LegacyListController: ListModelSectionControllerDelegate {

  internal func sectionControllerCompletedMove(
    _ sectionController: ListModelSectionController,
    for cellModel: ListCellModel,
    fromIndex: Int,
    toIndex: Int
  ) {
    reorderDelegate?.listController(self, moved: cellModel, fromIndex: fromIndex, toIndex: toIndex)
  }

  internal func sectionController(
    _ sectionController: ListModelSectionController,
    initialLayoutAttributes attributes: ListViewLayoutAttributes,
    for section: ListSection,
    at indexPath: IndexPath
  ) -> ListViewLayoutAttributes? {
    animationDelegate?
      .listController(
        self,
        initialLayoutAttributes: attributes,
        for: section,
        at: indexPath
      )
  }

  internal func sectionController(
    _ sectionController: ListModelSectionController,
    finalLayoutAttributes attributes: ListViewLayoutAttributes,
    for section: ListSection,
    at indexPath: IndexPath
  ) -> ListViewLayoutAttributes? {
    animationDelegate?
      .listController(
        self,
        finalLayoutAttributes: attributes,
        for: section,
        at: indexPath
      )
  }
}
