//
//  ListModelSectionController.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import IGListKit

internal class ListCellModelWrapper: NSObject {
  internal let model: ListCellModel

  internal init(model: ListCellModel) {
    self.model = model
  }
}

// MARK: - ListDiffable
extension ListCellModelWrapper: ListDiffable {
  internal func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    guard let wrapper = object as? ListCellModelWrapper else {
      return false
    }
    return model.isEqual(to: wrapper.model)
  }

  internal func diffIdentifier() -> NSObjectProtocol {
    return model.identifier as NSString
  }
}

internal class ListSectionWrapper: NSObject {
  internal var section: ListSection

  internal init(section: ListSection) {
    self.section = section
  }
}

// MARK: - ListDiffable
extension ListSectionWrapper: ListDiffable {
  internal func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    guard let wrapper = object as? ListSectionWrapper else {
      return false
    }
    return section == wrapper.section
  }

  internal func diffIdentifier() -> NSObjectProtocol {
    return section.identifier as NSString
  }
}

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
    let rowWidth = sizeConstraints.containerSizeAdjustedForInsets.width
    let rowHeight = sizeConstraints.containerSizeAdjustedForInsets.height
    let isVertical = sizeConstraints.scrollDirection == .vertical

    switch sizeConstraints.distribution {
    case .equally(let cellsInRow):
      let maxSize: CGSize
      if isVertical {
        let equalCellWidth = (rowWidth / CGFloat(cellsInRow))
          - (sizeConstraints.minimumInteritemSpacing * CGFloat(cellsInRow - 1) / CGFloat(cellsInRow))
        maxSize = CGSize(width: equalCellWidth, height: rowHeight)
      } else {
        let equalCellHeight = (rowHeight / CGFloat(cellsInRow))
          - (sizeConstraints.minimumInteritemSpacing * CGFloat(cellsInRow - 1) / CGFloat(cellsInRow))
        maxSize = CGSize(width: rowWidth, height: equalCellHeight)
      }

      let collectionCell = model.cellType.init()
      collectionCell.bindViewModel(ListCellModelWrapper(model: model))
      let size = collectionCell.systemLayoutSizeFitting(
        maxSize,
        withHorizontalFittingPriority: isVertical ? .required : .fittingSizeLevel,
        verticalFittingPriority: isVertical ? .fittingSizeLevel : .required)
      if isVertical {
        return CGSize(width: maxSize.width, height: size.height)
      } else {
        return CGSize(width: size.width, height: maxSize.height)
      }
    case .entireRow:
      let collectionCell = model.cellType.init()
      collectionCell.bindViewModel(ListCellModelWrapper(model: model))
      let size = collectionCell.systemLayoutSizeFitting(
        sizeConstraints.containerSizeAdjustedForInsets,
        withHorizontalFittingPriority: isVertical ? .required : .fittingSizeLevel,
        verticalFittingPriority: isVertical ? .fittingSizeLevel : .required)
      if isVertical {
        return CGSize(width: sizeConstraints.containerSize.width, height: size.height)
      } else {
        return CGSize(width: size.width, height: sizeConstraints.containerSize.height)
      }
    case .proportionally:
      let collectionCell = model.cellType.init()
      collectionCell.bindViewModel(ListCellModelWrapper(model: model))
      let size = collectionCell.systemLayoutSizeFitting(
        sizeConstraints.containerSizeAdjustedForInsets,
        withHorizontalFittingPriority: .fittingSizeLevel,
        verticalFittingPriority: .fittingSizeLevel)
      return size
    }
  }

  internal func size(for model: ListCellModel, with sizeConstraints: ListSizeConstraints) -> ListCellSize {
    let rowWidth = sizeConstraints.containerSizeAdjustedForInsets.width
    let rowHeight = sizeConstraints.containerSizeAdjustedForInsets.height
    switch sizeConstraints.distribution {
    case .equally(let cellsInRow):
      let maxSize: CGSize
      if sizeConstraints.scrollDirection == .vertical {
        let equalCellWidth = (rowWidth / CGFloat(cellsInRow))
          - (sizeConstraints.minimumInteritemSpacing * CGFloat(cellsInRow - 1) / CGFloat(cellsInRow))
        maxSize = CGSize(width: equalCellWidth, height: rowHeight)
      } else {
        let equalCellHeight = (rowHeight / CGFloat(cellsInRow))
          - (sizeConstraints.minimumInteritemSpacing * CGFloat(cellsInRow - 1) / CGFloat(cellsInRow))
        maxSize = CGSize(width: rowWidth, height: equalCellHeight)
      }
      switch model.size(constrainedTo: maxSize) {
      case .autolayout:
        return .autolayout
      case .explicit(let size):
        if sizeConstraints.scrollDirection == .vertical {
          return .explicit(size: CGSize(width: maxSize.width, height: size.height))
        } else {
          return .explicit(size: CGSize(width: size.width, height: maxSize.height))
        }
      case .relative:
        return .relative
      }
    case .entireRow:
      switch model.size(constrainedTo: sizeConstraints.containerSizeAdjustedForInsets) {
      case .autolayout:
        return .autolayout
      case .explicit(let size):
        if sizeConstraints.scrollDirection == .vertical {
          return .explicit(size: CGSize(width: rowWidth, height: size.height))
        } else {
          return .explicit(size: CGSize(width: size.width, height: rowHeight))
        }
      case .relative:
        return .relative
      }
    case .proportionally:
      return model.size(constrainedTo: sizeConstraints.containerSizeAdjustedForInsets)
    }
  }

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

  // MARK: - Helpers

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
  public func sectionController(
    _ sectionController: ListBindingSectionController<ListDiffable>,
    viewModelsFor object: Any
  ) -> [ListDiffable] {
    guard let section = self.object?.section else { return [] }
    return section.cellModels.map(ListCellModelWrapper.init)
  }

  public func sectionController(
    _ sectionController: ListBindingSectionController<ListDiffable>,
    cellForViewModel viewModel: Any,
    at index: Int
  ) -> UICollectionViewCell & ListBindable {
    return cell(for: viewModel, index: index)
  }

  public func sectionController(
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
  public func sectionController(
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
  public func sectionController(
    _ sectionController: ListBindingSectionController<ListDiffable>,
    didDeselectItemAt index: Int,
    viewModel: Any
  ) {
  }
  public func sectionController(
    _ sectionController: ListBindingSectionController<ListDiffable>,
    didHighlightItemAt index: Int,
    viewModel: Any
  ) {
  }
  public func sectionController(
    _ sectionController: ListBindingSectionController<ListDiffable>,
    didUnhighlightItemAt index: Int,
    viewModel: Any
  ) {
  }
}

// MARK: - ListDisplayDelegate
extension ListModelSectionController: ListDisplayDelegate {
  public func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController) {
  }

  public func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController) {
  }

  public func listAdapter(
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

  public func listAdapter(
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

  public func supportedElementKinds() -> [String] {
    var elementKinds = [String]()
    if self.object?.section.headerModel != nil {
      elementKinds.append(UICollectionView.elementKindSectionHeader)
    }
    if self.object?.section.footerModel != nil {
      elementKinds.append(UICollectionView.elementKindSectionFooter)
    }
    return elementKinds
  }

  public func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
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
    cell.bindViewModel(cellModel)
    return cell
  }

  public func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
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

    let size = cellModel.size(constrainedTo: sizeConstraints.containerSizeAdjustedForInsets)
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
  public func listAdapter(
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
  public func listAdapter(
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
