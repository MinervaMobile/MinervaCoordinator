//
//  PickerCell.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva

struct PickerImageData: Equatable {
  let image: UIImage
  let imageColor: UIColor
  let imageMargin: CGFloat
  let imageHeight: CGFloat
  let imageWidth: CGFloat

  init(image: UIImage, imageColor: UIColor, imageMargin: CGFloat, imageHeight: CGFloat, imageWidth: CGFloat) {
    self.image = image
    self.imageColor = imageColor
    self.imageMargin = imageMargin
    self.imageHeight = imageHeight
    self.imageWidth = imageWidth
  }
}

struct PickerDataRow: Equatable {
  let text: NSAttributedString
  let imageData: PickerImageData?
  init(text: NSAttributedString, imageData: PickerImageData?) {
    self.text = text
    self.imageData = imageData
  }
}

struct PickerDataComponent: Equatable {
  let data: [PickerDataRow]
  let textAlignment: NSTextAlignment
  let verticalMargin: CGFloat
  let startingRow: Int

  init(data: [PickerDataRow], textAlignment: NSTextAlignment, verticalMargin: CGFloat, startingRow: Int) {
    self.data = data
    self.textAlignment = textAlignment
    self.verticalMargin = verticalMargin
    self.startingRow = startingRow
  }
}

final class PickerCellModel: BaseListCellModel {
  typealias Action = (
    _ cellModel: PickerCellModel,
    _ pickerView: UIPickerView,
    _ row: Int,
    _ component: Int
  ) -> Void
  var height: CGFloat = 220
  fileprivate static let cellMargin: CGFloat = 15.0
  private let cellIdentifier: String

  fileprivate let helper: PickerCellModelHelper

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

  override var identifier: String {
    return cellIdentifier
  }

  override func isEqual(to model: ListCellModel) -> Bool {
    guard let model = model as? PickerCellModel else {
      return false
    }
    return helper.pickerDataComponents == model.helper.pickerDataComponents
      && height == model.height
  }
}

final class PickerCell: BaseListCell, ListCellHelper {

  typealias ModelType = PickerCellModel

  private let pickerView: UIPickerView

  override init(frame: CGRect) {
    pickerView = UIPickerView(frame: .zero)
    super.init(frame: frame)
    contentView.addSubview(pickerView)
    pickerView.anchor(to: contentView)
    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("Unsupported")
  }

  override func updatedCellModel() {
    super.updatedCellModel()
    guard let model = model else {
      return
    }
    pickerView.delegate = model.helper
    pickerView.dataSource = model.helper
    for (component, componentData) in model.helper.pickerDataComponents.enumerated() {
      pickerView.selectRow(componentData.startingRow, inComponent: component, animated: false)
    }
  }
}

private class PickerCellModelHelper: NSObject {
  typealias Action = (
    _ pickerView: UIPickerView,
    _ row: Int,
    _ component: Int
  ) -> Void
  let pickerDataComponents: [PickerDataComponent]
  var changedValue: Action?

  init(pickerDataComponents: [PickerDataComponent]) {
    self.pickerDataComponents = pickerDataComponents
  }
}

// MARK: - UIPickerViewDataSource
extension PickerCellModelHelper: UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return pickerDataComponents.count
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    guard let rowCount = pickerDataComponents.at(component)?.data.count else {
      assertionFailure("Data should exist for component \(component)")
      return 0
    }
    return rowCount
  }
}

// MARK: - UIPickerViewDelegate
extension PickerCellModelHelper: UIPickerViewDelegate {
  func pickerView(
    _ pickerView: UIPickerView,
    viewForRow row: Int,
    forComponent component: Int,
    reusing view: UIView?
  ) -> UIView {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true

    guard let componentData = pickerDataComponents.at(component), let rowData = componentData.data.at(row) else {
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
    imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    label.anchor(
      toLeading: nil,
      top: containerView.topAnchor,
      trailing: containerView.trailingAnchor,
      bottom: containerView.bottomAnchor
    )
    label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: imageData.imageMargin).isActive = true
    label.leadingAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true

    containerView.shouldTranslateAutoresizingMaskIntoConstraints(false)
    return containerView
  }

  func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
    guard let componentData = pickerDataComponents.at(component) else {
      return 0
    }
    let maxTextHeight
      = componentData.data.reduce(0, { max($0, $1.text.height(constraintedToWidth: pickerView.frame.width)) })
    let maxImageHeight = componentData.data.reduce(0, { max($0, ($1.imageData?.imageHeight ?? 0)) })

    return max(maxTextHeight, maxImageHeight) + componentData.verticalMargin * 2
  }
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    changedValue?(pickerView, row, component)
  }
}
