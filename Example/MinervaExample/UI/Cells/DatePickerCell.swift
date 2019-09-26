//
//  DatePickerCell.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva

final class DatePickerCellModel: BaseListCellModel {

  typealias Action = (_ cellModel: DatePickerCellModel, _ date: Date) -> Void

  var changedDate: Action?
  var mode: UIDatePicker.Mode = .dateAndTime
  var minimumDate: Date?
  var maximumDate: Date?

  private let cellIdentifier: String
  fileprivate let startDate: Date

  init(identifier: String, startDate: Date) {
    self.cellIdentifier = identifier
    self.startDate = startDate
    super.init()
  }

  // MARK: - BaseListCellModel

  override var identifier: String {
    return cellIdentifier
  }

  override func isEqual(to model: ListCellModel) -> Bool {
    guard let model = model as? DatePickerCellModel else {
      return false
    }
    return startDate == model.startDate
      && mode == model.mode
  }
}

final class DatePickerCell: BaseListCell, ListCellHelper {

  typealias ModelType = DatePickerCellModel

  private let datePicker: UIDatePicker = {
    let datePicker = UIDatePicker()
    return datePicker
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.datePicker.addTarget(
      self,
      action: #selector(self.dateDidChange(_:)),
      for: .valueChanged
    )
    self.contentView.addSubview(self.datePicker)
    self.setupConstraints()
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc
  func dateDidChange(_ datePicker: UIDatePicker) {
    guard let model = self.model else {
      return
    }
    model.changedDate?(model, datePicker.date)
  }

  override func updatedCellModel() {
    super.updatedCellModel()
    guard let model = self.model else {
      return
    }
    datePicker.datePickerMode = model.mode
    datePicker.minimumDate = model.minimumDate
    datePicker.maximumDate = model.maximumDate
    datePicker.setDate(model.startDate, animated: false)
  }
}

// MARK: - Constraints
extension DatePickerCell {
  private func setupConstraints() {
    datePicker.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor).isActive = true
    datePicker.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor).isActive = true
    datePicker.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    datePicker.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    datePicker.widthAnchor.constraint(lessThanOrEqualToConstant: 340).isActive = true
    let widthConstraint = datePicker.widthAnchor.constraint(equalToConstant: 340)
    widthConstraint.priority = .defaultLow
    widthConstraint.isActive = true

    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}
