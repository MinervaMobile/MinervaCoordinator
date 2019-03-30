//
//  ListModelSectionController.swift
//  Minerva
//
//  Created by Joe Laws
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import IGListKit

public protocol ListModelSectionControllerDelegate: class {

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

public class ListModelSectionController: ListBindingSectionController<ListSection> {
  public weak var delegate: ListModelSectionControllerDelegate?

  override init() {
    super.init()
    self.dataSource = self
    self.displayDelegate = self
    self.selectionDelegate = self
    self.transitionDelegate = self
    self.supplementaryViewSource = self
  }

  public var sizeConstraints: ListSizeConstraints? {
    guard let containerSize = self.collectionContext?.insetContainerSize else {
      assertionFailure("The container size should exist.")
      return nil
    }

    guard let section = self.object else {
      assertionFailure("List Section model should exist")
      return nil
    }

    let sizeConstraints = ListSizeConstraints(
      containerSize: containerSize,
      inset: self.inset,
      minimumLineSpacing: self.minimumInteritemSpacing,
      minimumInteritemSpacing: self.minimumInteritemSpacing,
      distribution: section.distribution
    )
    return sizeConstraints
  }

  public override func canMoveItem(at index: Int) -> Bool {
    guard let section = self.object else { return false }
    return section.cellModels[index].reorderable
  }

  public override func moveObject(from sourceIndex: Int, to destinationIndex: Int) {
    super.moveObject(from: sourceIndex, to: destinationIndex)
    guard let section = self.object else { return }

    let cellModel = section.cellModels.remove(at: sourceIndex)
    section.cellModels.insert(cellModel, at: destinationIndex)

    self.delegate?.sectionControllerCompletedMove(
      self,
      for: cellModel,
      fromIndex: sourceIndex,
      toIndex: destinationIndex
    )
  }

  // MARK: - Helpers

  private func cell(for viewModel: Any, index: Int) -> ListCollectionViewCell {
    guard let cellModel = viewModel as? ListCellModel else {
      assertionFailure("Unsupported view model type \(viewModel)")
      return BaseListCell()
    }
    guard let collectionContext = self.collectionContext else {
      assertionFailure("The collectionContext should exist")
      return BaseListCell()
    }
    if let model = cellModel as? ListBindableCellModelWrapper {
      model.willBind()
    }
    let cell: ListCollectionViewCell?
    let cellModelType = type(of: cellModel)
    if cellModel.usesNib {
      let reuseIdentifier = self.reuseIdentifier(for: cellModelType)
      let bundle = Bundle(for: cellModelType)
      cell = collectionContext.dequeueReusableCell(
        withNibName: reuseIdentifier,
        bundle: bundle,
        for: self,
        at: index) as? ListCollectionViewCell
    } else if let cellType = self.cellType(for: cellModelType) {
      cell = collectionContext.dequeueReusableCell(
        of: cellType,
        for: self,
        at: index) as? ListCollectionViewCell
    } else {
      cell = nil
    }
    guard let dequeuedCell = cell else {
      assertionFailure("Failed to get the cell for \(cellModelType) \(cellModel)")
      return BaseListCell()
    }
    return dequeuedCell
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
    if let model = cellModel as? ListBindableCellModelWrapper {
      model.willBind()
    }
    let cell: ListCollectionViewCell?
    let cellModelType = type(of: cellModel)
    if cellModel.usesNib {
      let reuseIdentifier = self.reuseIdentifier(for: cellModelType)
      let bundle = Bundle(for: cellModelType)
      cell = collectionContext.dequeueReusableSupplementaryView(
        ofKind: elementKind,
        for: self,
        nibName: reuseIdentifier,
        bundle: bundle,
        at: index) as? ListCollectionViewCell
    } else if let cellType = self.cellType(for: cellModelType) {
      cell = collectionContext.dequeueReusableSupplementaryView(
        ofKind: elementKind,
        for: self,
        class: cellType,
        at: index) as? ListCollectionViewCell
    } else {
      cell = nil
    }
    return cell ?? BaseListCell()
  }

  private func determineSize(for viewModel: Any, at index: Int) -> CGSize {
    guard let cellModel = viewModel as? ListCellModel else {
      assertionFailure("Invalid view model \(viewModel).")
      return super.sizeForItem(at: index)
    }
    guard let sizeConstraints = self.sizeConstraints else {
      assertionFailure("The size constraints should exist.")
      return super.sizeForItem(at: index)
    }

    let indexPath = IndexPath(item: index, section: self.section)
    if let size = self.delegate?.sectionController(
      self,
      sizeFor: cellModel,
      at: indexPath,
      constrainedTo: sizeConstraints) {
      return size
    }

    if let size = cellModel.size(with: sizeConstraints) {
      return size
    }
    assertionFailure("The cell or section controller delegate should provide a size.")
    return super.sizeForItem(at: index)
  }

  private func reuseIdentifier(for modelType: ListCellModel.Type) -> String {
    return String(describing: modelType).replacingOccurrences(of: "Model", with: "")
  }

  private func cellType(for modelType: ListCellModel.Type) -> ListCollectionViewCell.Type? {
    let className = self.reuseIdentifier(for: modelType)
    if let cellType = NSClassFromString(className) as? ListCollectionViewCell.Type {
      return cellType
    }
    let bundle = Bundle(for: modelType)
    guard let bundleName = bundle.infoDictionary?["CFBundleName"] as? String else {
      return nil
    }
    let fullClassName = "\(bundleName).\(className)"
    let cleanedClassName = fullClassName.replacingOccurrences(of: " ", with: "_")
    return NSClassFromString(cleanedClassName) as? ListCollectionViewCell.Type
  }
}

// MARK: - ListBindingSectionControllerDataSource
extension ListModelSectionController: ListBindingSectionControllerDataSource {
  public func sectionController(
    _ sectionController: ListBindingSectionController<ListDiffable>,
    viewModelsFor object: Any
  ) -> [ListDiffable] {
    guard let section = self.object else { return [] }
    return section.cellModels
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
    guard let cellModel = viewModel as? ListCellModel else {
      assertionFailure("Unsupported view model type \(viewModel)")
      return
    }
    let indexPath = IndexPath(item: index, section: self.section)
    if let model = cellModel as? ListSelectableCellModelWrapper {
      model.selected(at: indexPath)
    }
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
    if self.object?.headerModel != nil {
      elementKinds.append(UICollectionView.elementKindSectionHeader)
    }
    if self.object?.footerModel != nil {
      elementKinds.append(UICollectionView.elementKindSectionFooter)
    }
    return elementKinds
  }

  public func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
    let model: ListCellModel?
    switch elementKind {
    case UICollectionView.elementKindSectionHeader:
      model = self.object?.headerModel
    case UICollectionView.elementKindSectionFooter:
      model = self.object?.footerModel
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
      model = self.object?.headerModel
    case UICollectionView.elementKindSectionFooter:
      model = self.object?.footerModel
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

    if let size = cellModel.size(constrainedTo: sizeConstraints.containerSizeAdjustedForInsets) {
      return size
    }

    let indexPath = IndexPath(item: index, section: self.section)
    if let size = self.delegate?.sectionController(
      self,
      sizeFor: cellModel,
      at: indexPath,
      constrainedTo: sizeConstraints) {
      return size
    }
    assertionFailure("The cell or section controller delegate should provide a size.")
    return defaultSize
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
    guard let animationAttributes = attributes as? ListViewLayoutAttributes, let section = self.object else {
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
    guard let animationAttributes = attributes as? ListViewLayoutAttributes, let section = self.object else {
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
