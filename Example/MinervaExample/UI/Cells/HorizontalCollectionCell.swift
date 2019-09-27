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
  var itemSpacing: CGFloat = 0 {
    didSet {
      section.constraints.minimumInteritemSpacing = itemSpacing
      section.constraints.minimumLineSpacing = itemSpacing
    }
  }

  private let listController: ListController
  private var section: ListSection
  private let cellIdentifier: String

  init(
    identifier: String,
    cellModels: [ListCellModel],
    distribution: ListSection.Distribution,
    listController: ListController
  ) {
    assert(cellModels.isNotEmpty, "Horizontal Scroll list should have at least 1 model")
    self.cellIdentifier = identifier
    self.listController = listController
    self.section = ListSection(cellModels: cellModels, identifier: "\(identifier)-section")
    super.init()
    section.constraints.distribution = distribution
  }

  // MARK: - BaseListCellModel

  override var identifier: String {
    return cellIdentifier
  }

  override func isEqual(to model: ListCellModel) -> Bool {
    guard let model = model as? HorizontalCollectionCellModel, super.isEqual(to: model) else { return false }
    return model.section == section
      && followsInsets == model.followsInsets
      && isScrollEnabled == model.isScrollEnabled
      && horizontalContentInset == model.horizontalContentInset
      && itemSpacing == model.itemSpacing
      && listController === model.listController
  }

  override func size(constrainedTo containerSize: CGSize) -> ListCellSize {
    let size = CGSize(width: containerSize.width, height: CGFloat.greatestFiniteMagnitude)
    let constraints = ListSizeConstraints(
      containerSize: size,
      sectionConstraints: section.constraints)
    let height = section.cellModels.reduce(1) { maxHeight, cellModel -> CGFloat in
      max(maxHeight, listController.size(of: cellModel, with: constraints)?.height ?? 0)
    }
    let totalHeight = height + separatorAndMarginHeight
    return .explicit(size: CGSize(width: containerSize.width, height: totalHeight))
  }

  // MARK: - Helpers

  fileprivate func update(collectionView: UICollectionView) {
    listController.collectionView = collectionView
    listController.update(with: [section], animated: true, completion: nil)
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

  override func updatedCellModel() {
    super.updatedCellModel()
    guard let model = self.model else {
      return
    }

    collectionView.contentInset.left = model.horizontalContentInset
    collectionView.contentInset.right = model.horizontalContentInset
    collectionView.isScrollEnabled = model.isScrollEnabled

    if !model.followsInsets {
      containerLeadingConstraint?.constant = 0
      containerTrailingConstraint?.constant = 0
    }

    model.update(collectionView: collectionView)
  }
}
