//
//  ListModelSectionController.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import IGListKit

internal protocol ListModelSectionControllerDelegate: class {

  func sectionController(
    _ sectionController: ListModelSectionController,
    sizeFor model: ListCellModel,
    at indexPath: IndexPath,
    constrainedTo sizeConstraints: ListSizeConstraints
  ) -> CGSize?

  func sectionControllerCompletedMove(
    _ sectionController: ListModelSectionController,
    for cellModel: ListCellModel,
    fromIndex: Int,
    toIndex: Int
  )

  func sectionController(
    _ sectionController: ListModelSectionController,
    initialLayoutAttributes attributes: ListViewLayoutAttributes,
    for section: ListSection,
    at indexPath: IndexPath
  ) -> ListViewLayoutAttributes?

  func sectionController(
    _ sectionController: ListModelSectionController,
    finalLayoutAttributes attributes: ListViewLayoutAttributes,
    for section: ListSection,
    at indexPath: IndexPath
  ) -> ListViewLayoutAttributes?
}

internal class ListModelSectionController: ListBindingSectionController<ListSectionWrapper> {
  internal weak var delegate: ListModelSectionControllerDelegate?

  private var cachedCells = [String: ListCollectionViewCell]()

  internal override init() {
    super.init()
    self.dataSource = self
    self.displayDelegate = self
    self.selectionDelegate = self
    self.transitionDelegate = self
    self.supplementaryViewSource = self
  }

  internal var sizeConstraints: ListSizeConstraints? {
    guard let containerSize = self.collectionContext?.insetContainerSize else {
      assertionFailure("The container size should exist.")
      return nil
    }

    guard let section = self.object?.section else {
      assertionFailure("List Section model should exist")
      return nil
    }

    let sizeConstraints = ListSizeConstraints(
      containerSize: containerSize,
      sectionConstraints: section.constraints
    )
    return sizeConstraints
  }

  internal func autolayoutSize(for model: ListCellModel, constrainedTo sizeConstraints: ListSizeConstraints) -> CGSize {
    let adjustedContainerSize = sizeConstraints.adjustedContainerSize

    let cellType = String(describing: model.cellType)
    let collectionCell = cachedCells[cellType] ?? model.cellType.init(frame: .zero)
    collectionCell.bindViewModel(ListCellModelWrapper(model: model))

    defer {
      collectionCell.prepareForReuse()
      cachedCells[cellType] = collectionCell
    }

    switch sizeConstraints.distribution {
    case .equally, .entireRow:
      let isVertical = sizeConstraints.scrollDirection == .vertical
      let size = collectionCell.systemLayoutSizeFitting(
        adjustedContainerSize,
        withHorizontalFittingPriority: isVertical ? .required : .fittingSizeLevel,
        verticalFittingPriority: isVertical ? .fittingSizeLevel : .required)
      if isVertical {
        return CGSize(width: adjustedContainerSize.width, height: size.height)
      } else {
        return CGSize(width: size.width, height: adjustedContainerSize.height)
      }
    case .proportionally:
      let size = collectionCell.systemLayoutSizeFitting(
        adjustedContainerSize,
        withHorizontalFittingPriority: .fittingSizeLevel,
        verticalFittingPriority: .fittingSizeLevel)
      return size
    }
  }

  internal func size(for model: ListCellModel, with sizeConstraints: ListSizeConstraints) -> ListCellSize {
    let adjustedContainerSize = sizeConstraints.adjustedContainerSize
    let modelSize = model.size(constrainedTo: adjustedContainerSize)

    guard case .explicit(let size) = modelSize else {
      return modelSize
    }

    switch sizeConstraints.distribution {
    case .equally, .entireRow:
      if sizeConstraints.scrollDirection == .vertical {
        return .explicit(size: CGSize(width: adjustedContainerSize.width, height: size.height))
      } else {
        return .explicit(size: CGSize(width: size.width, height: adjustedContainerSize.height))
      }
    case .proportionally:
      return modelSize
    }
  }
}

// MARK: - ListBindingSectionController
extension ListModelSectionController {

  internal override func canMoveItem(at index: Int) -> Bool {
    guard let section = self.object?.section else { return false }
    return section.cellModels[index].reorderable
  }

  internal override func moveObject(from sourceIndex: Int, to destinationIndex: Int) {
    super.moveObject(from: sourceIndex, to: destinationIndex)
    guard let wrapper = self.object else { return }

    let cellModel = wrapper.section.cellModels.remove(at: sourceIndex)
    wrapper.section.cellModels.insert(cellModel, at: destinationIndex)

    self.delegate?.sectionControllerCompletedMove(
      self,
      for: cellModel,
      fromIndex: sourceIndex,
      toIndex: destinationIndex
    )
  }
}

// MARK: - Private
extension ListModelSectionController {

  private func cell(for viewModel: Any, index: Int) -> ListCollectionViewCell {
    guard let wrapper = viewModel as? ListCellModelWrapper else {
      assertionFailure("Unsupported view model type \(viewModel)")
      return BaseListCell()
    }
    return cell(for: wrapper.model, index: index)
  }

  private func cell(for cellModel: ListCellModel, index: Int) -> ListCollectionViewCell {
    guard let collectionContext = self.collectionContext else {
      assertionFailure("The collectionContext should exist")
      return BaseListCell()
    }
    let cellType = cellModel.cellType
    guard let cell = collectionContext.dequeueReusableCell(
      of: cellType,
      for: self,
      at: index
    ) as? ListCollectionViewCell else {
      assertionFailure("Failed to load the reuseable cell for \(cellType)")
      return BaseListCell()
    }
    return cell
  }

  private func supplementaryView(
    for cellModel: ListCellModel,
    index: Int,
    elementKind: String
  ) -> ListCollectionViewCell {
    guard let collectionContext = self.collectionContext else {
      assertionFailure("The collectionContext should exist")
      return BaseListCell()
    }
    let cellType = cellModel.cellType
    guard let cell = collectionContext.dequeueReusableSupplementaryView(
      ofKind: elementKind,
      for: self,
      class: cellType,
      at: index
    ) as? ListCollectionViewCell else {
      assertionFailure("Failed to load the reuseable cell for \(cellType)")
      return BaseListCell()
    }
    return cell
  }

  private func determineSize(for viewModel: Any, at index: Int) -> CGSize {
    guard let wrapper = viewModel as? ListCellModelWrapper else {
      assertionFailure("Invalid view model \(viewModel).")
      return super.sizeForItem(at: index)
    }
    guard let sizeConstraints = self.sizeConstraints else {
      assertionFailure("The size constraints should exist.")
      return super.sizeForItem(at: index)
    }
    let cellModel = wrapper.model

    let cellSize = size(for: cellModel, with: sizeConstraints)
    switch cellSize {
    case .autolayout:
      return autolayoutSize(for: cellModel, constrainedTo: sizeConstraints)
    case .explicit(let size):
      return size
    case .relative:
      let indexPath = IndexPath(item: index, section: self.section)
      guard let size = self.delegate?.sectionController(
        self,
        sizeFor: cellModel,
        at: indexPath,
        constrainedTo: sizeConstraints
      ) else {
        assertionFailure("The section controller delegate should provide a size for relative cell sizes.")
        return autolayoutSize(for: cellModel, constrainedTo: sizeConstraints)
      }
      return size
    }
  }
}

// MARK: - ListBindingSectionControllerDataSource
extension ListModelSectionController: ListBindingSectionControllerDataSource {
  internal func sectionController(
    _ sectionController: ListBindingSectionController<ListDiffable>,
    viewModelsFor object: Any
  ) -> [ListDiffable] {
    guard let section = self.object?.section else { return [] }
    return section.cellModels.map(ListCellModelWrapper.init)
  }

  internal func sectionController(
    _ sectionController: ListBindingSectionController<ListDiffable>,
    cellForViewModel viewModel: Any,
    at index: Int
  ) -> UICollectionViewCell & ListBindable {
    return cell(for: viewModel, index: index)
  }

  internal func sectionController(
    _ sectionController: ListBindingSectionController<ListDiffable>,
    sizeForViewModel viewModel: Any,
    at index: Int
  ) -> CGSize {
    let size = determineSize(for: viewModel, at: index)
    guard size.height > 0 && size.width > 0 else {
      assertionFailure("Height and width must be > 0 or the cell shouldn't exist \(size) for \(viewModel)")
      return CGSize(width: 1, height: 1)
    }
    return size
  }
}

// MARK: - ListBindingSectionControllerSelectionDelegate
extension ListModelSectionController: ListBindingSectionControllerSelectionDelegate {
  internal func sectionController(
    _ sectionController: ListBindingSectionController<ListDiffable>,
    didSelectItemAt index: Int,
    viewModel: Any
  ) {
    guard let wrapper = viewModel as? ListCellModelWrapper else {
      assertionFailure("Unsupported view model type \(viewModel)")
      return
    }
    let indexPath = IndexPath(item: index, section: self.section)
    if let model = wrapper.model as? ListSelectableCellModelWrapper {
      model.selected(at: indexPath)
    }
  }
  internal func sectionController(
    _ sectionController: ListBindingSectionController<ListDiffable>,
    didDeselectItemAt index: Int,
    viewModel: Any
  ) {
  }
  internal func sectionController(
    _ sectionController: ListBindingSectionController<ListDiffable>,
    didHighlightItemAt index: Int,
    viewModel: Any
  ) {
  }
  internal func sectionController(
    _ sectionController: ListBindingSectionController<ListDiffable>,
    didUnhighlightItemAt index: Int,
    viewModel: Any
  ) {
  }
}

// MARK: - ListDisplayDelegate
extension ListModelSectionController: ListDisplayDelegate {
  internal func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController) {
  }

  internal func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController) {
  }

  internal func listAdapter(
    _ listAdapter: ListAdapter,
    willDisplay sectionController: ListSectionController,
    cell: UICollectionViewCell,
    at index: Int
  ) {
    guard let minervaCell = cell as? ListCell else {
      assertionFailure("invalid cell type \(cell)")
      return
    }
    minervaCell.willDisplayCell()
  }

  internal func listAdapter(
    _ listAdapter: ListAdapter,
    didEndDisplaying sectionController: ListSectionController,
    cell: UICollectionViewCell,
    at index: Int
  ) {
    guard let minervaCell = cell as? ListCell else {
      assertionFailure("invalid cell type \(cell)")
      return
    }
    minervaCell.didEndDisplayingCell()
  }
}

// MARK: - ListSupplementaryViewSource
extension ListModelSectionController: ListSupplementaryViewSource {

  internal func supportedElementKinds() -> [String] {
    var elementKinds = [String]()
    if self.object?.section.headerModel != nil {
      elementKinds.append(UICollectionView.elementKindSectionHeader)
    }
    if self.object?.section.footerModel != nil {
      elementKinds.append(UICollectionView.elementKindSectionFooter)
    }
    return elementKinds
  }

  internal func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
    let model: ListCellModel?
    switch elementKind {
    case UICollectionView.elementKindSectionHeader:
      model = self.object?.section.headerModel
    case UICollectionView.elementKindSectionFooter:
      model = self.object?.section.footerModel
    default:
      assertionFailure("Unsupported Supplementary view type")
      model = nil
    }
    guard let cellModel = model else {
      assertionFailure("Unsupported Supplementary view type")
      return UICollectionViewCell()
    }

    let cell = self.supplementaryView(for: cellModel, index: index, elementKind: elementKind)
    cell.bindViewModel(ListCellModelWrapper(model: cellModel))
    return cell
  }

  internal func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
    let model: ListCellModel?
    switch elementKind {
    case UICollectionView.elementKindSectionHeader:
      model = self.object?.section.headerModel
    case UICollectionView.elementKindSectionFooter:
      model = self.object?.section.footerModel
    default:
      assertionFailure("Unsupported Supplementary view type")
      model = nil
    }
    guard let collectionContext = self.collectionContext, let cellModel = model else {
      assertionFailure("The collectionContext should exist")
      return .zero
    }
    let defaultSize = CGSize(width: collectionContext.containerSize.width, height: 44)

    guard let sizeConstraints = self.sizeConstraints else {
      assertionFailure("The size constraints should exist.")
      return defaultSize
    }

    let size = cellModel.size(constrainedTo: sizeConstraints.containerSize)
    switch size {
    case .autolayout:
      return autolayoutSize(for: cellModel, constrainedTo: sizeConstraints)
    case .explicit(let size):
      return size
    case .relative:
      assertionFailure("Relative sizing is not supported for supplementary views")
      return autolayoutSize(for: cellModel, constrainedTo: sizeConstraints)
    }
  }
}

// MARK: - IGListTransitionDelegate
extension ListModelSectionController: IGListTransitionDelegate {
  internal func listAdapter(
    _ listAdapter: ListAdapter,
    customizedInitialLayoutAttributes attributes: UICollectionViewLayoutAttributes,
    sectionController: ListSectionController,
    at index: Int
  ) -> UICollectionViewLayoutAttributes {
    let indexPath = IndexPath(item: index, section: sectionController.section)
    guard let animationAttributes = attributes as? ListViewLayoutAttributes, let section = self.object?.section else {
      return attributes
    }

    guard let customAttributes = delegate?.sectionController(
      self,
      initialLayoutAttributes: animationAttributes,
      for: section,
      at: indexPath
    ) else {
      return attributes
    }
    return customAttributes
  }
  internal func listAdapter(
    _ listAdapter: ListAdapter,
    customizedFinalLayoutAttributes attributes: UICollectionViewLayoutAttributes,
    sectionController: ListSectionController,
    at index: Int
  ) -> UICollectionViewLayoutAttributes {
    let indexPath = IndexPath(item: index, section: sectionController.section)
    guard let animationAttributes = attributes as? ListViewLayoutAttributes, let section = self.object?.section else {
      return attributes
    }
    guard let customAttributes = delegate?.sectionController(
      self,
      finalLayoutAttributes: animationAttributes,
      for: section,
      at: indexPath
    ) else {
      return attributes
    }
    return customAttributes
  }
}
