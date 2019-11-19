//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import UIKit

open class PickerCellModel: BaseListCellModel {
  public typealias Action = (
    _ cellModel: PickerCellModel,
    _ pickerView: UIPickerView,
    _ row: Int,
    _ component: Int
  ) -> Void

  fileprivate static let cellMargin: CGFloat = 15.0

  public var directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

  public var backgroundColor: UIColor?
  private let cellIdentifier: String

  fileprivate let helper: PickerCellModelHelper

  public
  init(identifier: String, pickerDataComponents: [PickerDataComponent], changedValue: @escaping Action) {
    self.cellIdentifier = identifier
    self.helper = PickerCellModelHelper(pickerDataComponents: pickerDataComponents)
    super.init()
    self.helper.changedValue = { [weak self] pickerView, row, component in
      guard let strongSelf = self else { return }
      changedValue(strongSelf, pickerView, row, component)
    }
  }

  // MARK: - BaseListCellModel

  override open var identifier: String { cellIdentifier }

  override open func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return helper.pickerDataComponents == model.helper.pickerDataComponents
      && backgroundColor == model.backgroundColor
      && directionalLayoutMargins == model.directionalLayoutMargins
  }
}

public final class PickerCell: BaseListCell<PickerCellModel> {

  private let pickerView: UIPickerView

  override public init(frame: CGRect) {
    pickerView = UIPickerView(frame: .zero)
    super.init(frame: frame)
    contentView.addSubview(pickerView)
    pickerView.anchorTo(layoutGuide: contentView.layoutMarginsGuide)
    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
    backgroundView = UIView()
  }

  override public func bind(model: PickerCellModel, sizing: Bool) {
    super.bind(model: model, sizing: sizing)
    pickerView.delegate = model.helper
    pickerView.dataSource = model.helper
    contentView.directionalLayoutMargins = model.directionalLayoutMargins
    guard !sizing else { return }

    for (component, componentData) in model.helper.pickerDataComponents.enumerated() {
      pickerView.selectRow(componentData.startingRow, inComponent: component, animated: false)
    }

    backgroundView?.backgroundColor = model.backgroundColor
  }
}

private class PickerCellModelHelper: NSObject {
  fileprivate typealias Action = (
    _ pickerView: UIPickerView,
    _ row: Int,
    _ component: Int
  ) -> Void

  fileprivate let pickerDataComponents: [PickerDataComponent]
  fileprivate var changedValue: Action?

  fileprivate init(pickerDataComponents: [PickerDataComponent]) {
    self.pickerDataComponents = pickerDataComponents
  }
}

// MARK: - UIPickerViewDataSource
extension PickerCellModelHelper: UIPickerViewDataSource {
  public func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return pickerDataComponents.count
  }

  public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    guard let rowCount = pickerDataComponents.element(at: component)?.data.count else {
      assertionFailure("Data should exist for component \(component)")
      return 0
    }
    return rowCount
  }
}

// MARK: - UIPickerViewDelegate
extension PickerCellModelHelper: UIPickerViewDelegate {
  public func pickerView(
    _ pickerView: UIPickerView,
    viewForRow row: Int,
    forComponent component: Int,
    reusing view: UIView?
  ) -> UIView {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true

    guard let componentData = pickerDataComponents.element(at: component),
      let rowData = componentData.data.element(at: row) else {
        assertionFailure("Data should exist for component \(component) row \(row)")
        return label
    }

    label.attributedText = rowData.text
    label.textAlignment = componentData.textAlignment

    guard let imageData = rowData.imageData else {
      return label
    }
    let containerView = UIView()
    containerView.addSubview(label)
    let imageView = UIImageView(image: imageData.image)
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = imageData.imageColor
    imageView.anchorWidth(to: imageData.imageWidth)
    imageView.anchorHeight(to: imageData.imageHeight)
    containerView.addSubview(imageView)

    imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
    imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    label.anchor(
      toLeading: nil,
      top: containerView.topAnchor,
      trailing: containerView.trailingAnchor,
      bottom: containerView.bottomAnchor
    )
    label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: imageData.imageMargin).isActive = true

    let rowView = UIView()
    rowView.addSubview(containerView)

    let containerWidth: CGFloat = componentData.data.reduce(0) { maxWidth, rowData in
      let textWidth = rowData.text.width(constraintedToHeight: pickerView.bounds.height)
      let width = textWidth + (rowData.imageData?.imageMargin ?? 0) + (rowData.imageData?.imageWidth ?? 0)
      return max(maxWidth, width)
    }

    containerView.anchorWidth(to: containerWidth)
    containerView.anchor(toLeading: nil, top: rowView.topAnchor, trailing: nil, bottom: rowView.bottomAnchor)
    containerView.centerXAnchor.constraint(equalTo: rowView.centerXAnchor).isActive = true
    containerView.shouldTranslateAutoresizingMaskIntoConstraints(false)
    rowView.shouldTranslateAutoresizingMaskIntoConstraints(false)
    return rowView
  }

  public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
    guard let componentData = pickerDataComponents.element(at: component) else {
      return 0
    }
    let maxTextHeight
      = componentData.data.reduce(0) { max($0, $1.text.height(constraintedToWidth: pickerView.frame.width)) }
    let maxImageHeight = componentData.data.reduce(0) { max($0, ($1.imageData?.imageHeight ?? 0)) }

    return max(maxTextHeight, maxImageHeight) + componentData.verticalMargin * 2
  }
  public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    changedValue?(pickerView, row, component)
  }
}

public struct PickerImageData: Equatable {
  public let image: UIImage
  public let imageColor: UIColor
  public let imageMargin: CGFloat
  public let imageHeight: CGFloat
  public let imageWidth: CGFloat

  public init(image: UIImage, imageColor: UIColor, imageMargin: CGFloat, imageHeight: CGFloat, imageWidth: CGFloat) {
    self.image = image
    self.imageColor = imageColor
    self.imageMargin = imageMargin
    self.imageHeight = imageHeight
    self.imageWidth = imageWidth
  }
}

public struct PickerDataRow: Equatable {
  public let text: NSAttributedString
  public let imageData: PickerImageData?

  public init(text: NSAttributedString, imageData: PickerImageData?) {
    self.text = text
    self.imageData = imageData
  }
}

public struct PickerDataComponent: Equatable {
  public let data: [PickerDataRow]
  public let textAlignment: NSTextAlignment
  public let verticalMargin: CGFloat
  public let startingRow: Int

  public init(data: [PickerDataRow], textAlignment: NSTextAlignment, verticalMargin: CGFloat, startingRow: Int) {
    self.data = data
    self.textAlignment = textAlignment
    self.verticalMargin = verticalMargin
    self.startingRow = startingRow
  }
}
