//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import SwipeCellKit
import UIKit

open class SwipeableLabelCellModel: SwipeableCellModel, ListSelectableCellModel {
	public typealias Action = (_ cellModel: SwipeableLabelCellModel) -> Void

	public var deleteAction: Action?
	public var deleteColor: UIColor?
	public var swipeable = true

	fileprivate let attributedText: NSAttributedString
	private let cellIdentifier: String

	public init(identifier: String, attributedText: NSAttributedString) {
		self.attributedText = attributedText
		self.cellIdentifier = identifier
		super.init()
	}

	// MARK: - BaseListCellModel

	override open var identifier: String {
		return cellIdentifier
	}

	override open func identical(to model: ListCellModel) -> Bool {
		guard let model = model as? SwipeableLabelCellModel, super.identical(to: model) else {
			return false
		}
		return attributedText.string == model.attributedText.string
			&& deleteColor == model.deleteColor
			&& swipeable == model.swipeable
	}

	// MARK: - ListSelectableCellModel
	public typealias SelectableModelType = SwipeableLabelCellModel
	public var selectionAction: SelectionAction?
}

public final class SwipeableLabelCell: SwipeableCell {
	public var model: SwipeableLabelCellModel? { cellModel as? SwipeableLabelCellModel }

	private let label: UILabel = {
		let label = UILabel()
		label.adjustsFontForContentSizeCategory = true
		return label
	}()

	override public init(frame: CGRect) {
		super.init(frame: frame)
		containerView.addSubview(label)
		setupConstraints()
	}

	override public func didUpdateCellModel() {
		super.didUpdateCellModel()
		guard let model = self.model else {
			return
		}

		self.delegate = model
		label.attributedText = model.attributedText
	}
}

// MARK: - Constraints
extension SwipeableLabelCell {
	private func setupConstraints() {
		label.anchor(to: containerView)
		containerView.shouldTranslateAutoresizingMaskIntoConstraints(false)
		contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
	}
}

// MARK: - SwipeCollectionViewCellDelegate
extension SwipeableLabelCellModel: SwipeCollectionViewCellDelegate {
	public func collectionView(
		_ collectionView: UICollectionView,
		editActionsForItemAt indexPath: IndexPath,
		for orientation: SwipeActionsOrientation
	) -> [SwipeAction]? {
		guard orientation == .right, swipeable else { return nil }

		let deleteAction = SwipeAction(style: .destructive, title: "Delete") { [weak self] action, _ in
			guard let strongSelf = self else { return }
			strongSelf.deleteAction?(strongSelf)
			action.fulfill(with: .delete)
		}
		deleteAction.backgroundColor = deleteColor
		deleteAction.hidesWhenSelected = true

		return [deleteAction]
	}
}
