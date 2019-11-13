//
//  BottomMarginCell.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import Minerva
import UIKit

public struct BottomMarginCellModel: TypedListCellModel, Equatable {

	public typealias CellType = BottomMarginCell

	var backgroundColor: UIColor?

	// MARK: - TypedListCellModel

	var description: String { typeDescription }
	var reorderable: Bool { false }
	public var identifier: String { "BottomMarginCellModel" }

	public func size(
		constrainedTo containerSize: CGSize,
		with templateProvider: () -> CellType
	) -> ListCellSize {
		let device = UIDevice.current
		let height: CGFloat
		if device.userInterfaceIdiom == .pad && device.orientation.isLandscape {
			height = 60
		} else if device.userInterfaceIdiom == .pad {
			height = 120
		} else {
			height = 40
		}
		let width = containerSize.width
		return .explicit(size: CGSize(width: width, height: height))
	}
}

public final class BottomMarginCell: BaseListCell {

	private var model: BottomMarginCellModel? { cellModel as? BottomMarginCellModel }

	override public func didUpdateCellModel() {
		super.didUpdateCellModel()
		guard let model = self.model else { return }
		self.contentView.backgroundColor = model.backgroundColor
	}
}
