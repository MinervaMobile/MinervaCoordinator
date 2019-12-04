//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import IGListKit
import UIKit

public final class HorizontalCollectionCellModel: BaseListCellModel {

  public var directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

  public var isScrollEnabled = true
  public var itemSpacing: CGFloat = 0 {
    didSet {
      section.constraints.minimumInteritemSpacing = itemSpacing
      section.constraints.minimumLineSpacing = itemSpacing
    }
  }
  public var numberOfRows = 1
  public var backgroundColor: UIColor?

  private let listController: ListController
  private var section: ListSection

  public init?(
    identifier: String,
    cellModels: [ListCellModel],
    distribution: ListSection.Distribution,
    listController: ListController
  ) {
    guard !cellModels.isEmpty else { return nil }
    self.listController = listController
    self.section = ListSection(cellModels: cellModels, identifier: "\(identifier)-section")
    super.init(identifier: identifier)
    self.section.constraints.distribution = distribution
    self.section.constraints.scrollDirection = .horizontal
  }

  // MARK: - BaseListCellModel

  override public func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    guard section == model.section
      && isScrollEnabled == model.isScrollEnabled
      && itemSpacing == model.itemSpacing
      && listController === model.listController
      && numberOfRows == model.numberOfRows
      && backgroundColor == model.backgroundColor
      && directionalLayoutMargins == model.directionalLayoutMargins else {
        return false
    }

    guard section.cellModels.count == model.section.cellModels.count else { return false }
    for (index, cellModel) in section.cellModels.enumerated() {
      guard cellModel.identical(to: model.section.cellModels[index]) else { return false }
    }
    return true
  }

  override public func size(
    constrainedTo containerSize: CGSize,
    with templateProvider: () -> ListCollectionViewCell
  ) -> ListCellSize {
    let constraints = ListSizeConstraints(
      containerSize: containerSize,
      sectionConstraints: section.constraints)

    let height = section.cellModels.reduce(1) { maxHeight, cellModel -> CGFloat in
      max(maxHeight, listController.size(of: cellModel, with: constraints).height)
    }
    let totalHeight = height + directionalLayoutMargins.top + directionalLayoutMargins.bottom
    return .explicit(size: CGSize(width: containerSize.width, height: totalHeight))
  }

  // MARK: - Private

  fileprivate func update(collectionView: UICollectionView, animated: Bool) {
    listController.collectionView = collectionView
    listController.update(with: [section], animated: animated, completion: nil)
  }
}

public final class HorizontalCollectionCell: BaseListCell<HorizontalCollectionCellModel> {

  private let collectionView: UICollectionView = {
    var layout = ListViewLayout(
      stickyHeaders: false,
      scrollDirection: .horizontal,
      topContentInset: 0,
      stretchToEdge: true
    )
    let view = ListCollectionView(frame: .zero, listCollectionViewLayout: layout)
    view.backgroundColor = .clear
    view.alwaysBounceVertical = false
    view.alwaysBounceHorizontal = true
    view.showsHorizontalScrollIndicator = false
    return view
  }()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(collectionView)
    setupConstraints()
    backgroundView = UIView()
  }

  override public func prepareForReuse() {
    super.prepareForReuse()
    collectionView.dataSource = self
    collectionView.reloadData()
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    collectionView.collectionViewLayout.invalidateLayout()
  }

  override public func bind(model: HorizontalCollectionCellModel, sizing: Bool) {
    super.bind(model: model, sizing: sizing)
    contentView.directionalLayoutMargins = model.directionalLayoutMargins
    collectionView.contentInset.left = contentView.layoutMargins.left
    collectionView.contentInset.right = contentView.layoutMargins.right

    model.update(collectionView: collectionView, animated: !sizing)

    guard !sizing else { return }

    collectionView.isScrollEnabled = model.isScrollEnabled
    backgroundView?.backgroundColor = model.backgroundColor
  }
}

// MARK: - Constraints
extension HorizontalCollectionCell {
  private func setupConstraints() {
    collectionView.anchor(
      toLeading: contentView.leadingAnchor,
      top: contentView.topAnchor,
      trailing: contentView.trailingAnchor,
      bottom: contentView.bottomAnchor
    )
    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}

extension HorizontalCollectionCell: UICollectionViewDataSource {

  public func numberOfSections(in collectionView: UICollectionView) -> Int { 0 }

  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 0 }

  public func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    UICollectionViewCell()
  }
}
