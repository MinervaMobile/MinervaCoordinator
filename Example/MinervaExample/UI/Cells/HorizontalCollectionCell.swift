//
//  HorizontalCollectionCell.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva

final class HorizontalCollectionCellModel: DefaultListCellModel {

  var followsInsets = false
  var isScrollEnabled = true
  var horizontalContentInset: CGFloat = 0
  var itemSpacing: CGFloat = 0

  private let listController: ListController
  private let cellModels: [ListCellModel]
  private let distribution: ListRowDistribution
  private let cellIdentifier: String

  init(
    identifier: String,
    cellModels: [ListCellModel],
    distribution: ListRowDistribution,
    listController: ListController
  ) {
    self.cellIdentifier = identifier
    self.listController = listController
    self.cellModels = cellModels
    self.distribution = distribution
    super.init()
    assert(cellModels.isNotEmpty, "Horizontal Scroll list should have at least 1 model")
  }

  // MARK: - BaseListCellModel

  override var identifier: String {
    return cellIdentifier
  }

  override func isEqual(to model: ListCellModel) -> Bool {
    guard let model = model as? HorizontalCollectionCellModel, super.isEqual(to: model) else { return false }
    let equalCells = zip(model.cellModels, cellModels).reduce(true, { $0 && $1.0.isEqual(to: $1.1) })
    return equalCells
      && followsInsets == model.followsInsets
      && isScrollEnabled == model.isScrollEnabled
      && horizontalContentInset == model.horizontalContentInset
      && itemSpacing == model.itemSpacing
      && listController === model.listController
  }

  override func size(constrainedTo containerSize: CGSize) -> CGSize? {
    let width = containerSize.width
    let maxHeight = cellModels.reduce(1, { max($0, ($1.size(constrainedTo: containerSize)?.height ?? 1)) })
    let height = maxHeight + separatorAndMarginHeight
    return CGSize(width: width, height: height)
  }

  // MARK: - Helpers

  private func createListSection() -> ListSection {
    let section = ListSection(cellModels: cellModels, identifier: "\(cellIdentifier)-section")
    section.minimumInteritemSpacing = itemSpacing
    section.minimumLineSpacing = itemSpacing
    section.distribution = distribution
    return section
  }

  fileprivate func update(collectionView: UICollectionView) {
    listController.collectionView = collectionView
    listController.update(with: [createListSection()], animated: true, completion: nil)
  }
}

final class HorizontalCollectionCell: DefaultListCell, ListCellHelper {
  typealias ModelType = HorizontalCollectionCellModel

  private let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
    view.backgroundColor = .clear
    view.alwaysBounceVertical = false
    view.alwaysBounceHorizontal = true
    view.showsHorizontalScrollIndicator = false
    return view
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(collectionView)
    collectionView.anchor(to: containerView)
    containerView.shouldTranslateAutoresizingMaskIntoConstraints(false)
    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    collectionView.collectionViewLayout.invalidateLayout()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("Unsupported")
  }

  override func updatedCellModel() {
    super.updatedCellModel()
    guard let model = self.model else {
      return
    }

    collectionView.contentInset.left = model.horizontalContentInset
    collectionView.contentInset.right = model.horizontalContentInset
    collectionView.isScrollEnabled = model.isScrollEnabled

    if !model.followsInsets {
      maxContainerWidthConstraint?.isActive = false
      containerLeadingConstraint?.constant = 0
      containerTrailingConstraint?.constant = 0
    }

    model.update(collectionView: collectionView)
  }
}
