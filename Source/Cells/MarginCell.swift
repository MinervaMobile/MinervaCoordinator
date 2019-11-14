//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

public final class MarginCellModel: BaseListCellModel, ListSelectableCellModel {

	public enum Location {
		case top
		case bottom
		case other(identifier: String)

		public var cellIdentifier: String {
			switch self {
			case .top: return "topDynamicMarginModelIdentifier"
			case .bottom: return "bottomDynamicMarginModelIdentifier"
			case .other(let identifier): return identifier
			}
		}
	}

	public enum SizeType {
		case dynamic
		case fixed(height: CGFloat)

		public func isEqual(to type: SizeType) -> Bool {
			switch self {
			case .dynamic:
				guard case SizeType.dynamic = type else {
					return false
				}
				return true
			case .fixed(let height):
				guard case let SizeType.fixed(other) = type else {
					return false
				}
				return height == other
			}
		}
	}

	public var selectionAction: ((_ cellModel: MarginCellModel, _ indexPath: IndexPath) -> Void)?
	private let cellIdentifier: String

	public var backgroundColor: UIColor?
	private let type: SizeType

	public init(location: Location, type: SizeType = .dynamic) {
		self.cellIdentifier = location.cellIdentifier
		self.type = type
		super.init()
	}

	public convenience init(identifier: String, height: CGFloat) {
		self.init(location: .other(identifier: identifier), type: .fixed(height: height))
	}

	// MARK: - BaseListCellModel

	override public var identifier: String {
		return self.cellIdentifier
	}

	override public func size(
		constrainedTo containerSize: CGSize,
		with templateProvider: () -> ListCollectionViewCell
	) -> ListCellSize {
		switch type {
		case .dynamic:
			return .relative
		case .fixed(let height):
			return .explicit(size: CGSize(width: containerSize.width, height: height))
		}
	}

	override public func identical(to model: ListCellModel) -> Bool {
		guard let model = model as? MarginCellModel else {
			return false
		}
		return backgroundColor == model.backgroundColor && type.isEqual(to: model.type)
	}
}

public final class MarginCell: BaseListCell {

	public var model: MarginCellModel? { cellModel as? MarginCellModel }

	override public func didUpdateCellModel() {
		super.didUpdateCellModel()
		guard let model = self.model else {
			return
		}
		self.contentView.backgroundColor = model.backgroundColor
	}
}
