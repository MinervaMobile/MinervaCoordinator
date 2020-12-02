//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import IGListKit
import UIKit

public final class LegacyListController: NSObject, ListController {
  private enum Action {
    case didEndDisplaying
    case invalidateLayout
    case reloadData(completion: Completion?)
    case scrollTo(
      cellModel: ListCellModel,
      scrollPosition: UICollectionView.ScrollPosition,
      animated: Bool
    )
    case scroll(scrollPosition: UICollectionView.ScrollPosition, animated: Bool)
    case update(listSections: [ListSection], animated: Bool, completion: Completion?)
    case willDisplay
  }

  public typealias Completion = (Bool) -> Void

  public weak var animationDelegate: ListControllerAnimationDelegate?
  public weak var reorderDelegate: ListControllerReorderDelegate?
  public weak var sizeDelegate: ListControllerSizeDelegate?

  public weak var scrollViewDelegate: UIScrollViewDelegate? {
    get { adapter.scrollViewDelegate }
    set { adapter.scrollViewDelegate = newValue }
  }

  public weak var viewController: UIViewController? {
    get { adapter.viewController }
    set { adapter.viewController = newValue }
  }

  public var collectionView: UICollectionView? {
    get { adapter.collectionView }
    set { adapter.collectionView = newValue }
  }

  public var listSections: [ListSection] { listSectionWrappers.map(\.section) }

  private let adapter: ListAdapter
  private var noLongerDisplayingCells = false
  private var listSectionWrappers: [ListSectionWrapper]
  private var sizeController: ListCellSizeController
  private var actionQueue = [Action]()
  private var updating = false

  // MARK: - Initializers

  override public init() {
    self.sizeController = ListCellSizeController()
    self.listSectionWrappers = []
    let updater = ListAdapterUpdater()
    self.adapter = ListAdapter(updater: updater, viewController: nil)
    super.init()
    sizeController.delegate = self
    adapter.dataSource = self
    adapter.moveDelegate = self
  }

  // MARK: - Public

  public func reloadData(completion: Completion?) {
    dispatchPrecondition(condition: .onQueue(.main))
    reloadData(completion: completion, enqueueIfNeeded: true)
  }

  public func update(with listSections: [ListSection], animated: Bool, completion: Completion?) {
    dispatchPrecondition(condition: .onQueue(.main))
    update(with: listSections, animated: animated, completion: completion, enqueueIfNeeded: true)
  }

  public func willDisplay() {
    dispatchPrecondition(condition: .onQueue(.main))
    willDisplay(enqueueIfNeeded: true)
  }

  public func didEndDisplaying() {
    dispatchPrecondition(condition: .onQueue(.main))
    didEndDisplaying(enqueueIfNeeded: true)
  }

  public func invalidateLayout() {
    dispatchPrecondition(condition: .onQueue(.main))
    invalidateLayout(enqueueIfNeeded: true)
  }

  public func indexPath(for cellModel: ListCellModel) -> IndexPath? {
    dispatchPrecondition(condition: .onQueue(.main))
    for (sectionIndex, section) in listSections.enumerated() {
      for (rowIndex, model) in section.cellModels.enumerated() {
        if cellModel.identifier == model.identifier, cellModel.identical(to: model) {
          return IndexPath(item: rowIndex, section: sectionIndex)
        }
      }
    }
    return nil
  }

  public var centerCellModel: ListCellModel? {
    dispatchPrecondition(condition: .onQueue(.main))
    guard
      let indexPath = adapter.collectionView?.centerCellIndexPath,
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
    scrollTo(
      cellModel: cellModel,
      scrollPosition: scrollPosition,
      animated: animated,
      enqueueIfNeeded: true
    )
  }

  public func scroll(to scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
    dispatchPrecondition(condition: .onQueue(.main))
    scroll(to: scrollPosition, animated: animated, enqueueIfNeeded: true)
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

    return sizeController.size(
      for: cellModel,
      at: indexPath,
      in: listSection,
      with: constraints,
      enableSizeByDelegate: false
    )
  }

  // MARK: - Private

  private func endDisplayingVisibleCells() {
    guard let visibleCells = adapter.collectionView?.visibleCells else { return }
    visibleCells.compactMap { $0 as? ListDisplayableCell }.forEach { $0.didEndDisplayingCell() }
  }

  private func sectionIndexOf(_ listSection: ListSection) -> Int? {
    guard
      let sectionIndex = listSections.firstIndex(where: { $0.identifier == listSection.identifier })
    else {
      assertionFailure(
        "The listSection should be in listSections"
      )
      return nil
    }
    return sectionIndex
  }

  private func processActionQueue() {
    guard !actionQueue.isEmpty else {
      return
    }
    let action = actionQueue.removeFirst()
    switch action {
    case .didEndDisplaying:
      didEndDisplaying(enqueueIfNeeded: false)
    case .invalidateLayout:
      invalidateLayout(enqueueIfNeeded: false)
    case let .reloadData(completion):
      reloadData(completion: completion, enqueueIfNeeded: false)
    case let .scroll(scrollPosition, animated):
      scroll(to: scrollPosition, animated: animated, enqueueIfNeeded: false)
    case let .scrollTo(cellModel, scrollPosition, animated):
      scrollTo(
        cellModel: cellModel,
        scrollPosition: scrollPosition,
        animated: animated,
        enqueueIfNeeded: false
      )
    case let .update(listSections, animated, completion):
      update(with: listSections, animated: animated, completion: completion, enqueueIfNeeded: false)
    case .willDisplay:
      willDisplay(enqueueIfNeeded: false)
    }
  }

  private func reloadData(completion: Completion?, enqueueIfNeeded: Bool) {
    guard !enqueueIfNeeded || (actionQueue.isEmpty && !updating) else {
      actionQueue.append(.reloadData(completion: completion))
      return
    }
    updating = true
    adapter.reloadData { [weak self] finished in
      defer {
        completion?(finished)
      }
      guard let strongSelf = self else {
        return
      }
      if strongSelf.noLongerDisplayingCells {
        strongSelf.endDisplayingVisibleCells()
      }
      strongSelf.updating = false
      strongSelf.processActionQueue()
    }
  }

  private func update(
    with listSections: [ListSection],
    animated: Bool,
    completion: Completion?,
    enqueueIfNeeded: Bool
  ) {
    guard !enqueueIfNeeded || (actionQueue.isEmpty && !updating) else {
      actionQueue.append(
        .update(listSections: listSections, animated: animated, completion: completion)
      )
      return
    }
    #if DEBUG
    var identifiers = [String: ListCellModel]() // Should be unique across ListSections in the same UICollectionView.
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
    updating = true
    listSectionWrappers = listSections.map(ListSectionWrapper.init)
    adapter.performUpdates(animated: animated) { [weak self] finished in
      defer {
        completion?(finished)
      }
      guard let strongSelf = self else {
        return
      }
      if strongSelf.noLongerDisplayingCells {
        strongSelf.endDisplayingVisibleCells()
      }
      strongSelf.updating = false
      strongSelf.processActionQueue()
    }
  }

  private func didEndDisplaying(enqueueIfNeeded: Bool) {
    guard !enqueueIfNeeded || (actionQueue.isEmpty && !updating) else {
      actionQueue.append(.didEndDisplaying)
      return
    }
    defer {
      processActionQueue()
    }
    guard !noLongerDisplayingCells else { return }
    endDisplayingVisibleCells()
    noLongerDisplayingCells = true
  }

  private func willDisplay(enqueueIfNeeded: Bool) {
    guard !enqueueIfNeeded || (actionQueue.isEmpty && !updating) else {
      actionQueue.append(.willDisplay)
      return
    }
    defer {
      processActionQueue()
    }
    guard noLongerDisplayingCells else { return }
    guard let visibleCells = adapter.collectionView?.visibleCells else { return }
    visibleCells.compactMap { $0 as? ListDisplayableCell }.forEach { $0.willDisplayCell() }
    noLongerDisplayingCells = false
  }

  private func invalidateLayout(enqueueIfNeeded: Bool) {
    guard !enqueueIfNeeded || (actionQueue.isEmpty && !updating) else {
      actionQueue.append(.invalidateLayout)
      return
    }
    sizeController.clearCache()
    processActionQueue()
  }

  private func scrollTo(
    cellModel: ListCellModel,
    scrollPosition: UICollectionView.ScrollPosition,
    animated: Bool,
    enqueueIfNeeded: Bool
  ) {
    guard !enqueueIfNeeded || (actionQueue.isEmpty && !updating) else {
      actionQueue.append(
        .scrollTo(cellModel: cellModel, scrollPosition: scrollPosition, animated: animated)
      )
      return
    }
    defer {
      processActionQueue()
    }
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

  private func scroll(
    to scrollPosition: UICollectionView.ScrollPosition,
    animated: Bool,
    enqueueIfNeeded: Bool
  ) {
    guard !enqueueIfNeeded || (actionQueue.isEmpty && !updating) else {
      actionQueue.append(.scroll(scrollPosition: scrollPosition, animated: animated))
      return
    }
    guard !listSections.isEmpty else {
      processActionQueue()
      return
    }
    let cellModels = listSections.flatMap(\.cellModels)
    guard !cellModels.isEmpty else {
      processActionQueue()
      return
    }
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

    guard let cellModel = model else {
      processActionQueue()
      return
    }
    scrollTo(
      cellModel: cellModel,
      scrollPosition: .centeredVertically,
      animated: animated,
      enqueueIfNeeded: false
    )
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
    listSectionWrappers = sections
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
  internal func sectionController(
    _ sectionController: ListModelSectionController,
    didInvalidateSizeAt indexPath: IndexPath
  ) {
    guard let collectionView = adapter.collectionView else { return }
    let contextClassType: AnyClass = type(of: collectionView.collectionViewLayout).invalidationContextClass
    guard let contextClass = contextClassType as? UICollectionViewLayoutInvalidationContext.Type
    else { return }
    let context = contextClass.init()
    context.invalidateItems(at: [indexPath])
    collectionView.collectionViewLayout.invalidateLayout(with: context)
    adapter.performUpdates(animated: false, completion: nil)
  }

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
