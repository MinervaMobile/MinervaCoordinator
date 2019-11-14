//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import IGListKit
import UIKit

public final class HorizontalCollectionCellModel: BaseListCellModel {

	public var followsInsets = false
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
	private let cellIdentifier: String

	public init?(
		identifier: String,
		cellModels: [ListCellModel],
		distribution: ListSection.Distribution,
		listController: ListController
	) {
		guard !cellModels.isEmpty else { return nil }
		self.cellIdentifier = identifier
		self.listController = listController
		self.section = ListSection(cellModels: cellModels, identifier: "\(identifier)-section")
		super.init()
		self.section.constraints.distribution = distribution
		self.section.constraints.scrollDirection = .horizontal
	}

	// MARK: - BaseListCellModel

	override public var identifier: String {
		return cellIdentifier
	}

	override public func identical(to model: ListCellModel) -> Bool {
		guard let model = model as? HorizontalCollectionCellModel, super.identical(to: model) else { return false }
		return model.section == section
			&& followsInsets == model.followsInsets
			&& isScrollEnabled == model.isScrollEnabled
			&& itemSpacing == model.itemSpacing
			&& listController === model.listController
			&& numberOfRows == model.numberOfRows
			&& backgroundColor == model.backgroundColor
	}

	override public func size(
		constrainedTo containerSize: CGSize,
		with templateProvider: () -> ListCollectionViewCell
	) -> ListCellSize {
		let margins = templateProvider().layoutMargins
		let constraints = ListSizeConstraints(
			containerSize: containerSize,
			sectionConstraints: section.constraints)

		let height = section.cellModels.reduce(1) { maxHeight, cellModel -> CGFloat in
			max(maxHeight, listController.size(of: cellModel, with: constraints)?.height ?? 0)
		}
		let totalHeight = height + margins.top + margins.bottom
		return .explicit(size: CGSize(width: containerSize.width, height: totalHeight))
	}

	// MARK: - Private

	fileprivate func update(collectionView: UICollectionView) {
		listController.collectionView = collectionView
		listController.update(with: [section], animated: true, completion: nil)
	}
}

public final class HorizontalCollectionCell: BaseListCell {
	public var model: HorizontalCollectionCellModel? { cellModel as? HorizontalCollectionCellModel }

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

	override public func layoutSubviews() {
		super.layoutSubviews()
		collectionView.collectionViewLayout.invalidateLayout()
	}

	override public func didUpdateCellModel() {
		super.didUpdateCellModel()
		guard let model = self.model else {
			return
		}

		collectionView.contentInset.left = contentView.layoutMargins.left
		collectionView.contentInset.right = contentView.layoutMargins.right
		collectionView.isScrollEnabled = model.isScrollEnabled

		model.update(collectionView: collectionView)
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
