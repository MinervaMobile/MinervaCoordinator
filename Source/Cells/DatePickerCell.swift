//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import UIKit

open class DatePickerCellModel: BaseListCellModel {
  public typealias Action = (_ cellModel: DatePickerCellModel, _ date: Date) -> Void
  public var changedDate: Action?

  public var directionalLayoutMargins = NSDirectionalEdgeInsets(
    top: 8,
    leading: 16,
    bottom: 8,
    trailing: 16
  )

  fileprivate let startDate: Date
  public var maxControlWidth: CGFloat = 340
  public var maximumDate: Date?
  public var minimumDate: Date?
  public var backgroundColor: UIColor?
  public var mode: UIDatePicker.Mode = .date
  public var pickerAccessibilityIdentifier: String?

  public init(identifier: String, startDate: Date) {
    self.startDate = startDate
    super.init(identifier: identifier)
  }

  // MARK: - BaseListCellModel

  override open func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return startDate == model.startDate
      && maxControlWidth == model.maxControlWidth
      && minimumDate == model.minimumDate
      && maximumDate == model.maximumDate
      && backgroundColor == model.backgroundColor
      && directionalLayoutMargins == model.directionalLayoutMargins
      && pickerAccessibilityIdentifier == model.pickerAccessibilityIdentifier
  }
}

public final class DatePickerCell: BaseListCell<DatePickerCellModel> {

  private var highPriorityWidthAnchor: NSLayoutConstraint?
  private var lowPriorityWidthAnchor: NSLayoutConstraint?

  private let datePicker: UIDatePicker = {
    let picker = UIDatePicker()
    if #available(iOS 13.4, *) {
      picker.preferredDatePickerStyle = .wheels
    }
    return picker
  }()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    self.datePicker.addTarget(
      self,
      action: #selector(self.dateDidChange(_:)),
      for: .valueChanged
    )
    self.contentView.addSubview(self.datePicker)
    self.setupConstraints()
    self.backgroundView = UIView()
  }

  @objc
  private func dateDidChange(_ datePicker: UIDatePicker) {
    guard let model = self.model else {
      return
    }
    model.changedDate?(model, datePicker.date)
  }

  override public func bind(model: DatePickerCellModel, sizing: Bool) {
    super.bind(model: model, sizing: sizing)

    datePicker.maximumDate = model.maximumDate
    datePicker.minimumDate = model.minimumDate
    contentView.directionalLayoutMargins = directionalLayoutMargins
    updateConstraints(with: model)

    guard !sizing else { return }

    self.backgroundView?.backgroundColor = model.backgroundColor
    datePicker.setDate(model.startDate, animated: false)
    datePicker.datePickerMode = model.mode
    datePicker.accessibilityIdentifier = model.pickerAccessibilityIdentifier
  }
}

// MARK: - Constraints
extension DatePickerCell {
  private func updateConstraints(with model: DatePickerCellModel) {
    highPriorityWidthAnchor?.constant = model.maxControlWidth
    lowPriorityWidthAnchor?.constant = model.maxControlWidth
  }

  private func setupConstraints() {
    datePicker.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor).isActive =
      true
    datePicker.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor).isActive =
      true
    datePicker.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    datePicker.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true

    highPriorityWidthAnchor = datePicker.widthAnchor.constraint(lessThanOrEqualToConstant: 0)
    highPriorityWidthAnchor?.isActive = true

    lowPriorityWidthAnchor = datePicker.widthAnchor.constraint(equalToConstant: 0)
    lowPriorityWidthAnchor?.priority = .defaultLow
    lowPriorityWidthAnchor?.isActive = true

    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}
