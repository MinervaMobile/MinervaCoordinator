//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

open class DetailedLabelCellModel: BaseListCellModel, ListSelectableCellModel {
	fileprivate static let labelMargin: CGFloat = 16

	public var numberOfLines = 0
	public var backgroundColor: UIColor?

	fileprivate let attributedTitle: NSAttributedString
	fileprivate let attributedDetails: NSAttributedString
	private let cellIdentifier: String

	public init(identifier: String, attributedTitle: NSAttributedString, attributedDetails: NSAttributedString) {
		self.cellIdentifier = identifier
		self.attributedTitle = attributedTitle
		self.attributedDetails = attributedDetails
		super.init()
	}

	public convenience init(attributedTitle: NSAttributedString, attributedDetails: NSAttributedString) {
		self.init(
			identifier: "\(attributedTitle.string)-\(attributedDetails.string)",
			attributedTitle: attributedTitle,
			attributedDetails: attributedDetails)
	}

	// MARK: - BaseListCellModel

	override public var identifier: String {
		return self.cellIdentifier
	}

	override public func identical(to model: ListCellModel) -> Bool {
		guard let model = model as? DetailedLabelCellModel, super.identical(to: model) else {
			return false
		}
		return attributedTitle == model.attributedTitle
			&& attributedDetails == model.attributedDetails
			&& numberOfLines == model.numberOfLines
			&& backgroundColor == model.backgroundColor
	}

	// MARK: - ListSelectableCellModel
	public typealias SelectableModelType = DetailedLabelCellModel
	public var selectionAction: SelectionAction?
}

public class DetailedLabelCell: BaseListCell {
	public var model: DetailedLabelCellModel? { cellModel as? DetailedLabelCellModel }

	private let label: UILabel = {
		let label = UILabel()
		label.adjustsFontForContentSizeCategory = true
		label.numberOfLines = 0
		return label
	}()
	private let detailedLabel: UILabel = {
		let label = UILabel()
		label.adjustsFontForContentSizeCategory = true
		label.numberOfLines = 0
		return label
	}()

	override public init(frame: CGRect) {
		super.init(frame: frame)
		contentView.addSubview(label)
		contentView.addSubview(detailedLabel)
		setupConstraints()
	}

	override public func didUpdateCellModel() {
		super.didUpdateCellModel()
		guard let model = self.model else {
			return
		}
		label.attributedText = model.attributedTitle
		detailedLabel.attributedText = model.attributedDetails
		contentView.backgroundColor = model.backgroundColor
		label.backgroundColor = model.backgroundColor
		detailedLabel.backgroundColor = model.backgroundColor
	}
}

// MARK: - Constraints
extension DetailedLabelCell {
	private func setupConstraints() {
		let layoutGuide = contentView.layoutMarginsGuide

		label.anchor(
			toLeading: layoutGuide.leadingAnchor,
			top: layoutGuide.topAnchor,
			trailing: nil,
			bottom: layoutGuide.bottomAnchor
		)
		detailedLabel.leadingAnchor.constraint(
			equalTo: label.trailingAnchor,
			constant: DetailedLabelCellModel.labelMargin
		).isActive = true
		detailedLabel.anchor(
			toLeading: nil,
			top: layoutGuide.topAnchor,
			trailing: layoutGuide.trailingAnchor,
			bottom: layoutGuide.bottomAnchor
		)

		label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		detailedLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

		contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
	}
}
