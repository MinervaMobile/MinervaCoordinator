//
//  MarginCell.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import Minerva
import UIKit

public struct MarginCellModel: TypedListCellModel {

	public typealias CellType = MarginCell

	public let identifier: String

	var backgroundColor: UIColor?
	let height: CGFloat?

	init(cellIdentifier: String = "MarginCellModel", height: CGFloat? = nil) {
		self.identifier = cellIdentifier
		self.height = height
	}

	// MARK: - BaseListCellModel
	var description: String { typeDescription }

	var reorderable: Bool { false }

	public func identical(to model: MarginCellModel) -> Bool {
		return backgroundColor == model.backgroundColor
			&& height == model.height
	}

	public func size(
		constrainedTo containerSize: CGSize,
		with templateProvider: () -> CellType
	) -> ListCellSize {
		guard let height = self.height else { return .relative }
		let width = containerSize.width
		return .explicit(size: CGSize(width: width, height: height))
	}
}

public final class MarginCell: BaseListCell {

	private var model: MarginCellModel? { cellModel as? MarginCellModel }

	override public func didUpdateCellModel() {
		super.didUpdateCellModel()
		guard let model = self.model else { return }
		self.contentView.backgroundColor = model.backgroundColor
	}
}
