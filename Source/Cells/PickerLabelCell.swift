//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

public final class PickerLabelCellModel: BaseListCellModel {
  public typealias Action = (
    _ cellModel: PickerLabelCellModel,
    _ pickerView: UIPickerView,
    _ row: Int,
    _ component: Int
  ) -> Void

  fileprivate static let cellMargin: CGFloat = 15.0

  private let cellIdentifier: String

  public var backgroundColor: UIColor?
  public var staticHeight: CGFloat?

  public var cellAlignment = CellAlignment.center
  fileprivate let helper: PickerLabelCellModelHelper

  public init(identifier: String, pickerData: PickerData, changedValue: Action?) {
    self.helper = PickerLabelCellModelHelper(pickerData: pickerData)
    self.cellIdentifier = identifier
    super.init()
    self.helper.changedValue = { [weak self] pickerView, row, component in
      guard let strongSelf = self else { return }
      changedValue?(strongSelf, pickerView, row, component)
    }
  }

  // MARK: - BaseListCellModel

  override public var identifier: String {
    return self.cellIdentifier
  }

  override public func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return helper.pickerData == model.helper.pickerData
      && cellAlignment == model.cellAlignment
      && backgroundColor == model.backgroundColor
      && staticHeight == model.staticHeight
  }

  override public func size(
    constrainedTo containerSize: CGSize,
    with templateProvider: () -> ListCollectionViewCell
  ) -> ListCellSize {
    guard let height = staticHeight else { return .autolayout }
    return .explicit(size: CGSize(width: containerSize.width, height: height))
  }
}

public final class PickerLabelCell: BaseListCell<PickerLabelCellModel> {

  private weak var labelLeadingConstraint: NSLayoutConstraint?
  private weak var labelWidthConstraint: NSLayoutConstraint?
  private weak var pickerWidthConstraint: NSLayoutConstraint?
  private var centerXConstraint: NSLayoutConstraint?
  private var leadingConstraint: NSLayoutConstraint?
  private var trailingConstraint: NSLayoutConstraint?

  private let containerView = UIView()
  private let pickerView = UIPickerView(frame: .zero)
  private let label: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.adjustsFontForContentSizeCategory = true
    return label
  }()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(containerView)
    containerView.addSubview(pickerView)
    containerView.addSubview(label)
    backgroundView = UIView()
    setupConstraints()
  }

  override public func bind(model: PickerLabelCellModel, sizing: Bool) {
    super.bind(model: model, sizing: sizing)

    pickerView.delegate = model.helper
    pickerView.dataSource = model.helper

    let data = model.helper.pickerData
    if let options = data.options {
      label.attributedText = options.label
      labelLeadingConstraint?.constant = options.labelMargin
    }

    remakeConstraints(with: model)

    guard !sizing else { return }

    if let options = data.options, !data.data.isEmpty {
      let row = min(max(0, options.startingRow), data.data.count - 1)
      pickerView.selectRow(row, inComponent: 0, animated: false)
    }

    for component in 0..<pickerView.numberOfComponents {
      model.helper.changedValue?(pickerView, pickerView.selectedRow(inComponent: component), component)
    }
    backgroundView?.backgroundColor = model.backgroundColor
  }
}

private class PickerLabelCellModelHelper: NSObject {
  fileprivate typealias Action = (
    _ pickerView: UIPickerView,
    _ row: Int,
    _ component: Int
  ) -> Void

  fileprivate let pickerData: PickerData
  fileprivate var changedValue: Action?

  fileprivate init(pickerData: PickerData) {
    self.pickerData = pickerData
  }
}
// MARK: - UIPickerViewDataSource
extension PickerLabelCellModelHelper: UIPickerViewDataSource {
  public func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerData.data.count
  }
}

// MARK: - UIPickerViewDelegate
extension PickerLabelCellModelHelper: UIPickerViewDelegate {
  public func pickerView(
    _ pickerView: UIPickerView,
    viewForRow row: Int,
    forComponent component: Int,
    reusing view: UIView?
  ) -> UIView {
    let label = view as? UILabel ?? UILabel()
    label.adjustsFontForContentSizeCategory = true
    label.textAlignment = pickerData.options?.rowTextAlignment ?? .center
    label.attributedText = pickerData.data.element(at: row)
    return label
  }

  public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    self.changedValue?(pickerView, row, component)
  }

  public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
    let width = pickerData.data.reduce(
      0) { max($0, $1.width(constraintedToHeight: CGFloat.greatestFiniteMagnitude)) }
      + (pickerData.options?.rowMargin ?? 8)
    return width
  }
}

// MARK: - Constraints
extension PickerLabelCell {

  private func remakeConstraints(with model: PickerLabelCellModel) {
    let data = model.helper.pickerData
    centerXConstraint?.isActive = false
    trailingConstraint?.isActive = false
    leadingConstraint?.isActive = false

    switch model.cellAlignment {
    case .center:
      centerXConstraint?.isActive = true
    case .left(let leftMargin):
      leadingConstraint?.constant = leftMargin
      leadingConstraint?.isActive = true
    case .right(let rightMargin):
      trailingConstraint?.constant = -rightMargin
      trailingConstraint?.isActive = true
    }

    let pickerWidth = model.helper.pickerData.data.reduce(
      0) { max($0, $1.width(constraintedToHeight: CGFloat.greatestFiniteMagnitude)) }
      + (data.options?.rowMargin ?? 8)
    let labelWidth = data.options?.label?.width(constraintedToHeight: CGFloat.greatestFiniteMagnitude) ?? 0

    labelWidthConstraint?.constant = labelWidth
    pickerWidthConstraint?.constant = pickerWidth
  }

  private func setupConstraints() {
    let layoutGuide = contentView.layoutMarginsGuide

    containerView.anchor(toLeading: nil, top: layoutGuide.topAnchor, trailing: nil, bottom: layoutGuide.bottomAnchor)

    pickerView.anchor(
      toLeading: containerView.leadingAnchor,
      top: containerView.topAnchor,
      trailing: nil,
      bottom: containerView.bottomAnchor
    )
    label.anchor(
      toLeading: nil,
      top: containerView.topAnchor,
      trailing: containerView.trailingAnchor,
      bottom: containerView.bottomAnchor
    )
    labelLeadingConstraint = label.leadingAnchor.constraint(equalTo: pickerView.trailingAnchor, constant: 0)
    labelLeadingConstraint?.isActive = true
    labelWidthConstraint = label.widthAnchor.constraint(equalToConstant: 0)
    labelWidthConstraint?.isActive = true

    pickerWidthConstraint = pickerView.widthAnchor.constraint(equalToConstant: 0)
    pickerWidthConstraint?.isActive = true

    leadingConstraint = containerView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor)
    leadingConstraint?.priority = UILayoutPriority.required - 1
    leadingConstraint?.isActive = true

    trailingConstraint = containerView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor)
    trailingConstraint?.priority = UILayoutPriority.required - 1
    trailingConstraint?.isActive = true

    centerXConstraint = containerView.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor)
    centerXConstraint?.priority = UILayoutPriority.required - 1

    containerView.shouldTranslateAutoresizingMaskIntoConstraints(false)
    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)

  }
}

public enum CellAlignment: Equatable {
  case left(leftMargin: CGFloat)
  case right(rightMargin: CGFloat)
  case center
}

public struct PickerData: Equatable {
  public let data: [NSAttributedString]
  public let options: PickerDataOptions?

  public init(data: [NSAttributedString], options: PickerDataOptions?) {
    self.data = data
    self.options = options
  }
}

public struct PickerDataOptions: Equatable {
  public let label: NSAttributedString?
  public let labelMargin: CGFloat
  public let rowMargin: CGFloat
  public let startingRow: Int
  public let rowTextAlignment: NSTextAlignment

  public init(
    label: NSAttributedString?,
    labelMargin: CGFloat,
    rowMargin: CGFloat,
    startingRow: Int,
    rowTextAlignment: NSTextAlignment
  ) {
    self.label = label
    self.labelMargin = labelMargin
    self.rowMargin = rowMargin
    self.startingRow = startingRow
    self.rowTextAlignment = rowTextAlignment
  }
}
