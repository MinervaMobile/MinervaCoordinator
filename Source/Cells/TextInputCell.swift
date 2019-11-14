//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

public protocol TextInputCellModelDelegate: AnyObject {
	func textInputCellModel(_ textInputCellModel: TextInputCellModel, textChangedTo text: String?)
}

public final class TextInputCellModel: BaseListCellModel {
	public weak var delegate: TextInputCellModelDelegate?

	fileprivate static let bottomBorderHeight: CGFloat = 1.0
	fileprivate static let textBottomMargin: CGFloat = 8.0
	fileprivate static let textInputIndent: CGFloat = 10.0

	fileprivate var attributedPlaceholder: NSAttributedString {
		return NSAttributedString(string: placeholder, font: font, fontColor: placeholderTextColor)
	}
	public var bottomBorderColor = BehaviorSubject<UIColor?>(value: nil)

	public var becomesFirstResponder = false
	public var text: String?
	fileprivate let font: UIFont
	fileprivate let placeholder: String

	public var cursorColor: UIColor?
	public var textColor: UIColor?
	public var textContentType: UITextContentType?
	public var isSecureTextEntry: Bool = false
	public var autocorrectionType: UITextAutocorrectionType = .default
	public var autocapitalizationType: UITextAutocapitalizationType = .none
	public var keyboardType: UIKeyboardType = .default
	public var inputTextColor: UIColor = .white
	public var placeholderTextColor: UIColor = .white
	public var maxControlWidth: CGFloat = 340

	private let cellIdentifier: String

	public init(identifier: String, placeholder: String, font: UIFont) {
		self.cellIdentifier = identifier
		self.placeholder = placeholder
		self.font = font
		super.init()
	}

	// MARK: - BaseListCellModel

	override public var identifier: String {
		return cellIdentifier
	}

	override public func identical(to model: ListCellModel) -> Bool {
		guard let model = model as? TextInputCellModel, super.identical(to: model) else { return false }
		return text == model.text
			&& font == model.font
			&& placeholder == model.placeholder
			&& cursorColor == model.cursorColor
			&& textColor == model.textColor
			&& textContentType == model.textContentType
			&& isSecureTextEntry == model.isSecureTextEntry
			&& autocorrectionType == model.autocorrectionType
			&& autocapitalizationType == model.autocapitalizationType
			&& keyboardType == model.keyboardType
			&& inputTextColor == model.inputTextColor
			&& placeholderTextColor == model.placeholderTextColor
			&& maxControlWidth == model.maxControlWidth
	}
}

public final class TextInputCell: BaseListCell {
	public var model: TextInputCellModel? { cellModel as? TextInputCellModel }
	public var disposeBag = DisposeBag()
	private let textField: UITextField = {
		let textField = UITextField(frame: .zero)
		textField.borderStyle = .none
		textField.adjustsFontForContentSizeCategory = true
		return textField
	}()
	private let bottomBorder: UIView = {
		let bottomBorder = UIView()
		return bottomBorder
	}()

	override public init(frame: CGRect) {
		super.init(frame: frame)
		contentView.addSubview(textField)
		contentView.addSubview(bottomBorder)
		textField.addTarget(
			self,
			action: #selector(textFieldDidChange(_:)),
			for: .editingChanged
		)
		setupConstraints()
	}

	override public func prepareForReuse() {
		super.prepareForReuse()
		disposeBag = DisposeBag()
	}

	@objc
	private func textFieldDidChange(_ textField: UITextField) {
		guard let model = self.model else { return }
		model.text = textField.text
		model.delegate?.textInputCellModel(model, textChangedTo: textField.text)
	}

	override public func didUpdateCellModel() {
		super.didUpdateCellModel()
		guard let model = self.model else { return }
		textField.autocapitalizationType = model.autocapitalizationType
		textField.autocorrectionType = model.autocorrectionType
		textField.tintColor = model.cursorColor
		textField.attributedPlaceholder = model.attributedPlaceholder
		textField.keyboardType = model.keyboardType
		if let initialText = model.text, (textField.text == nil || textField.text?.isEmpty == true) {
			textField.text = initialText
		}
		textField.isSecureTextEntry = model.isSecureTextEntry
		textField.textColor = model.inputTextColor
		textField.textContentType = model.textContentType
		textField.font = model.font

		model.bottomBorderColor.subscribe(onNext: { [weak self] bottomBorderColor -> Void in
			self?.bottomBorder.backgroundColor = bottomBorderColor
		}).disposed(by: disposeBag)

		if model.becomesFirstResponder {
			textField.becomeFirstResponder()
		}
	}
}

// MARK: - Constraints
extension TextInputCell {
	private func setupConstraints() {
		let layoutGuide = contentView.layoutMarginsGuide

		textField.anchor(
			toLeading: layoutGuide.leadingAnchor,
			top: layoutGuide.topAnchor,
			trailing: layoutGuide.trailingAnchor,
			bottom: nil
		)

		bottomBorder.anchorHeight(to: TextInputCellModel.bottomBorderHeight)
		bottomBorder.anchor(
			toLeading: layoutGuide.leadingAnchor,
			top: nil,
			trailing: layoutGuide.trailingAnchor,
			bottom: layoutGuide.bottomAnchor
		)
		bottomBorder.topAnchor.constraint(
			equalTo: textField.bottomAnchor,
			constant: TextInputCellModel.textBottomMargin
		).isActive = true

		contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
	}
}
