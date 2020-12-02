//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import IGListKit
import UIKit

internal protocol ListModelSectionControllerDelegate: AnyObject {
  func sectionController(
    _ sectionController: ListModelSectionController,
    didInvalidateSizeAt indexPath: IndexPath
  )

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

internal final class ListModelSectionController: ListBindingSectionController<ListSectionWrapper> {
  internal weak var delegate: ListModelSectionControllerDelegate?

  private let sizeController: ListCellSizeController

  internal init(sizeController: ListCellSizeController) {
    self.sizeController = sizeController
    super.init()
    self.dataSource = self
    self.displayDelegate = self
    self.selectionDelegate = self
    self.transitionDelegate = self
    self.supplementaryViewSource = self
  }

  internal var sizeConstraints: ListSizeConstraints? {
    guard let containerSize = collectionContext?.insetContainerSize else {
      assertionFailure("The container size should exist.")
      return nil
    }

    guard let section = object?.section else {
      assertionFailure("List Section model should exist")
      return nil
    }

    let sizeConstraints = ListSizeConstraints(
      containerSize: containerSize,
      sectionConstraints: section.constraints
    )
    return sizeConstraints
  }
}

// MARK: - ListBindingSectionController

extension ListModelSectionController {
  override internal func didUpdate(to object: Any) {
    super.didUpdate(to: object)
    guard let sectionWrapper = object as? ListSectionWrapper else {
      assertionFailure("Unknown object type \(object)")
      return
    }
    inset = sectionWrapper.section.constraints.inset
    minimumLineSpacing = sectionWrapper.section.constraints.minimumLineSpacing
    minimumInteritemSpacing = sectionWrapper.section.constraints.minimumInteritemSpacing
  }

  override internal func canMoveItem(at index: Int) -> Bool {
    guard let section = object?.section else { return false }
    return (section.cellModels[index] as? ListReorderableCellModel)?.reorderable ?? false
  }

  override internal func moveObject(from sourceIndex: Int, to destinationIndex: Int) {
    super.moveObject(from: sourceIndex, to: destinationIndex)
    guard let wrapper = object else { return }

    let cellModel = wrapper.section.cellModels.remove(at: sourceIndex)
    wrapper.section.cellModels.insert(cellModel, at: destinationIndex)

    delegate?
      .sectionControllerCompletedMove(
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
      return MissingListCell()
    }
    return cell(for: wrapper.model, index: index)
  }

  private func cell(for cellModel: ListCellModel, index: Int) -> ListCollectionViewCell {
    guard let collectionContext = self.collectionContext else {
      assertionFailure("The collectionContext should exist")
      return MissingListCell()
    }
    let cellType = cellModel.cellType
    guard
      let cell = collectionContext.dequeueReusableCell(
        of: cellType,
        for: self,
        at: index
      ) as? ListCollectionViewCell
    else {
      assertionFailure("Failed to load the reuseable cell for \(cellType)")
      return MissingListCell()
    }
    if let cell = cell as? ListResizableCell {
      cell.resizableDelegate = self
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
      return MissingListCell()
    }
    let cellType = cellModel.cellType
    guard
      let cell = collectionContext.dequeueReusableSupplementaryView(
        ofKind: elementKind,
        for: self,
        class: cellType,
        at: index
      ) as? ListCollectionViewCell
    else {
      assertionFailure("Failed to load the reuseable cell for \(cellType)")
      return MissingListCell()
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

    guard let section = object?.section else {
      assertionFailure("List Section model should exist")
      return super.sizeForItem(at: index)
    }

    let cellModel = wrapper.model
    let indexPath = IndexPath(item: index, section: self.section)

    return sizeController.size(
      for: cellModel,
      at: indexPath,
      in: section,
      with: sizeConstraints,
      enableSizeByDelegate: true
    )
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
    cell(for: viewModel, index: index)
  }

  internal func sectionController(
    _ sectionController: ListBindingSectionController<ListDiffable>,
    sizeForViewModel viewModel: Any,
    at index: Int
  ) -> CGSize {
    let size = determineSize(for: viewModel, at: index)
    guard size.height > 0, size.width > 0 else {
      assertionFailure(
        "Height and width must be > 0 or the cell shouldn't exist \(size) for \(viewModel)"
      )
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
    let indexPath = IndexPath(item: index, section: section)
    if let model = wrapper.model as? ListSelectableCellModelWrapper {
      model.selected(at: indexPath)
    } else {
      collectionContext?
        .deselectItem(
          at: index,
          sectionController: sectionController,
          animated: false
        )
    }
  }

  internal func sectionController(
    _ sectionController: ListBindingSectionController<ListDiffable>,
    didDeselectItemAt index: Int,
    viewModel: Any
  ) {}
  internal func sectionController(
    _ sectionController: ListBindingSectionController<ListDiffable>,
    didHighlightItemAt index: Int,
    viewModel: Any
  ) {
    guard let wrapper = viewModel as? ListCellModelWrapper else {
      assertionFailure("Unsupported view model type \(viewModel)")
      return
    }
    let indexPath = IndexPath(item: index, section: section)
    if let model = wrapper.model as? ListHighlightableCellModelWrapper {
      model.highlighted(at: indexPath)
    }
  }

  internal func sectionController(
    _ sectionController: ListBindingSectionController<ListDiffable>,
    didUnhighlightItemAt index: Int,
    viewModel: Any
  ) {
    guard let wrapper = viewModel as? ListCellModelWrapper else {
      assertionFailure("Unsupported view model type \(viewModel)")
      return
    }
    let indexPath = IndexPath(item: index, section: section)
    if let model = wrapper.model as? ListHighlightableCellModelWrapper {
      model.unhighlighted(at: indexPath)
    }
  }
}

// MARK: - ListDisplayDelegate

extension ListModelSectionController: ListDisplayDelegate {
  internal func listAdapter(
    _ listAdapter: ListAdapter,
    willDisplay sectionController: ListSectionController
  ) {}

  internal func listAdapter(
    _ listAdapter: ListAdapter,
    didEndDisplaying sectionController: ListSectionController
  ) {}

  internal func listAdapter(
    _ listAdapter: ListAdapter,
    willDisplay sectionController: ListSectionController,
    cell: UICollectionViewCell,
    at index: Int
  ) {
    guard let minervaCell = cell as? ListDisplayableCell else { return }
    minervaCell.willDisplayCell()
  }

  internal func listAdapter(
    _ listAdapter: ListAdapter,
    didEndDisplaying sectionController: ListSectionController,
    cell: UICollectionViewCell,
    at index: Int
  ) {
    guard let minervaCell = cell as? ListDisplayableCell else { return }
    minervaCell.didEndDisplayingCell()
  }
}

// MARK: - ListResizableCellDelegate

extension ListModelSectionController: ListResizableCellDelegate {
  internal func cellDidInvalidateSize(_ cell: ListResizableCell) {
    guard let index = collectionContext?.index(for: cell, sectionController: self) else { return }
    let indexPath = IndexPath(item: index, section: section)
    delegate?.sectionController(self, didInvalidateSizeAt: indexPath)
  }
}

// MARK: - ListSupplementaryViewSource

extension ListModelSectionController: ListSupplementaryViewSource {
  internal func supportedElementKinds() -> [String] {
    var elementKinds = [String]()
    if object?.section.headerModel != nil {
      elementKinds.append(UICollectionView.elementKindSectionHeader)
    }
    if object?.section.footerModel != nil {
      elementKinds.append(UICollectionView.elementKindSectionFooter)
    }
    return elementKinds
  }

  internal func viewForSupplementaryElement(ofKind elementKind: String, at index: Int)
    -> UICollectionReusableView
  {
    let model: ListCellModel?
    switch elementKind {
    case UICollectionView.elementKindSectionHeader:
      model = object?.section.headerModel
    case UICollectionView.elementKindSectionFooter:
      model = object?.section.footerModel
    default:
      assertionFailure("Unsupported Supplementary view type")
      model = nil
    }
    guard let cellModel = model else {
      assertionFailure("Unsupported Supplementary view type")
      return UICollectionViewCell()
    }

    let cell = supplementaryView(for: cellModel, index: index, elementKind: elementKind)
    cell.bindViewModel(ListCellModelWrapper(model: cellModel))
    return cell
  }

  internal func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
    let model: ListCellModel?
    switch elementKind {
    case UICollectionView.elementKindSectionHeader:
      model = object?.section.headerModel
    case UICollectionView.elementKindSectionFooter:
      model = object?.section.footerModel
    default:
      assertionFailure("Unsupported Supplementary view type")
      model = nil
    }
    guard let collectionContext = self.collectionContext, let cellModel = model else {
      assertionFailure("The collectionContext and model should exist")
      return .zero
    }

    guard let sizeConstraints = self.sizeConstraints else {
      assertionFailure("The size constraints should exist.")
      return CGSize(width: collectionContext.containerSize.width, height: 44)
    }

    return sizeController.supplementarySize(for: cellModel, sizeConstraints: sizeConstraints)
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
    guard
      let animationAttributes = attributes as? ListViewLayoutAttributes,
      let section = object?.section
    else {
      return attributes
    }

    guard
      let customAttributes = delegate?
      .sectionController(
        self,
        initialLayoutAttributes: animationAttributes,
        for: section,
        at: indexPath
      )
    else {
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
    guard
      let animationAttributes = attributes as? ListViewLayoutAttributes,
      let section = object?.section
    else {
      return attributes
    }
    guard
      let customAttributes = delegate?
      .sectionController(
        self,
        finalLayoutAttributes: animationAttributes,
        for: section,
        at: indexPath
      )
    else {
      return attributes
    }
    return customAttributes
  }
}
