//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

open class ImageTextCellModel: BaseListCellModel, ListSelectableCellModel, ListBindableCellModel {
	fileprivate static let imageMargin: CGFloat = 10

	public let image = BehaviorSubject<UIImage?>(value: nil)

	fileprivate let attributedText: NSAttributedString
	public var imageWidth: CGFloat = 0
	public var imageHeight: CGFloat = 0
	public var imageViewCornerRadius: CGFloat = 0

	private let cellIdentifier: String

	public init(attributedText: NSAttributedString, identifier: String) {
		self.attributedText = attributedText
		self.cellIdentifier = identifier
		super.init()
	}

	// MARK: - BaseListCellModel

	override public var identifier: String {
		return self.cellIdentifier
	}

	override public func identical(to model: ListCellModel) -> Bool {
		guard let model = model as? ImageTextCellModel, super.identical(to: model) else {
			return false
		}
		return attributedText == model.attributedText
			&& imageWidth == model.imageWidth
			&& imageHeight == model.imageHeight
			&& imageViewCornerRadius == model.imageViewCornerRadius
	}

	// MARK: - ListSelectableCellModel
	public typealias SelectableModelType = ImageTextCellModel
	public var selectionAction: SelectionAction?

	// MARK: - ListBindableCellModel
	public typealias BindableModelType = ImageTextCellModel
	public var willBindAction: BindAction?
}

public class ImageTextCell: BaseListCell {
	public var model: ImageTextCellModel? { cellModel as? ImageTextCellModel }
	public var disposeBag = DisposeBag()

	private let label: UILabel = {
		let label = UILabel()
		label.textAlignment = .left
		label.numberOfLines = 0
		label.adjustsFontForContentSizeCategory = true
		return label
	}()

	private var imageViewHeightConstraint: NSLayoutConstraint?
	private var imageViewWidthConstraint: NSLayoutConstraint?
	private let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.layer.masksToBounds = true
		return imageView
	}()

	override public init(frame: CGRect) {
		super.init(frame: frame)
		contentView.addSubview(label)
		contentView.addSubview(imageView)
		setupConstraints()
	}

	override public func prepareForReuse() {
		super.prepareForReuse()
		disposeBag = DisposeBag()
		imageView.image = nil
		label.attributedText = nil
		label.text = nil
	}

	override public func didUpdateCellModel() {
		super.didUpdateCellModel()
		guard let model = model else {
			return
		}

		label.attributedText = model.attributedText
		model.image.subscribe(onNext: { [weak self] in self?.imageView.image = $0 }).disposed(by: disposeBag)
		imageViewWidthConstraint?.constant = model.imageWidth
		imageViewHeightConstraint?.constant = model.imageHeight
		imageView.layer.cornerRadius = model.imageViewCornerRadius
	}
}

// MARK: - Constraints
extension ImageTextCell {
	private func setupConstraints() {
		let layoutGuide = contentView.layoutMarginsGuide

		imageView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
		imageView.centerYAnchor.constraint(equalTo: layoutGuide.centerYAnchor).isActive = true
		imageView.topAnchor.constraint(greaterThanOrEqualTo: layoutGuide.topAnchor).isActive = true
		imageView.bottomAnchor.constraint(lessThanOrEqualTo: layoutGuide.bottomAnchor).isActive = true

		imageViewHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 75)
		imageViewHeightConstraint?.isActive = true
		imageViewWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 75)
		imageViewWidthConstraint?.isActive = true

		label.leadingAnchor.constraint(
			equalTo: imageView.trailingAnchor,
			constant: ImageTextCellModel.imageMargin
		).isActive = true
		label.anchor(
			toLeading: nil,
			top: layoutGuide.topAnchor,
			trailing: layoutGuide.trailingAnchor,
			bottom: layoutGuide.bottomAnchor
		)

		contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
	}
}
