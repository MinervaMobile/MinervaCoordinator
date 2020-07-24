//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxRelay
import RxSwift

public final class FakePresenter: ListPresenter {
  public let cellModels: [ListCellModel] = {
    let font = UIFont.preferredFont(forTextStyle: .body)
    let color = UIColor.label
    let size = CGSize(width: 24, height: 24)
    let text = "text"
    let attrText = NSAttributedString(string: text)
    let image = UIImage()
    let row = PickerDataRow(
      text: attrText,
      imageData: PickerImageData(image: image, imageColor: color, imageMargin: 0, imageSize: size)
    )
    let component = PickerDataComponent(
      data: [row, row],
      textAlignment: .center,
      verticalMargin: 0,
      startingRow: 0
    )
    let options = PickerDataOptions(
      label: attrText,
      labelMargin: 0,
      rowMargin: 0,
      startingRow: 0,
      rowTextAlignment: .center
    )
    let pickerData = PickerData(data: [attrText, attrText, attrText], options: options)
    let cellModels = [
      // Cells
      ButtonCellModel(text: "ButtonCellModel", font: font, textColor: color),
      ButtonImageCellModel(imageSize: size, text: "ButtonImageCellModel", font: font),
      DatePickerCellModel(identifier: "DatePickerCellModel", startDate: Date()),
      DetailedLabelCellModel(
        identifier: "DetailedLabelCellModel",
        attributedTitle: attrText,
        attributedDetails: attrText
      ),
      IconTextCellModel(imageSize: size, text: "IconTextCellModel", font: font),
      ImageButtonCardCellModel(
        identifier: "ImageButtonCardCellModel",
        attributedText: attrText,
        selectedAttributedText: attrText,
        image: image,
        imageSize: size,
        isSelected: true
      ),
      ImageCellModel(imageObservable: .just(image), imageSize: size),
      ImageLabelBorderCellModel(
        text: "ImageLabelBorderCellModel",
        font: font,
        image: image,
        imageSize: size
      ),
      ImageTextCardCellModel(attributedText: NSAttributedString(string: "ImageTextCardCellModel")),
      ImageTextCellModel(identifier: "ImageTextCellModel", attributedText: attrText),
      LabelAccessoryCellModel(identifier: "LabelAccessoryCellModel", attributedText: attrText),
      LabelCellModel(identifier: "LabelCellModel", attributedText: attrText),
      MarginCellModel(identifier: "MarginCellModel", height: size.height),
      PickerCellModel(
        identifier: "PickerCellModel",
        pickerDataComponents: [component],
        changedValue: { _, _, _, _ in }
      ),
      PickerLabelCellModel(
        identifier: "PickerLabelCellModel",
        pickerData: pickerData,
        changedValue: { _, _, _, _ in }
      ),
      SegmentedControlCellModel(selectedSegment: 0, segmentTitles: [text]),
      SeparatorCellModel(location: .bottom(cellModelID: "SeparatorCellModel"), color: color),
      SwitchTextCellModel(
        text: "SwitchTextCellModel",
        font: font,
        textColor: color,
        switchColor: color,
        isOn: true
      ),
      TextInputCellModel(identifier: "TextInputCellModel", placeholder: text, font: font),
      TextSeparatorCellModel(text: "TextSeparatorCellModel"),

      TextViewCellModel(
        identifier: "TextViewCellModel",
        text: text,
        font: font
      ),
      // Swipe
      SwipeableDetailedLabelCellModel(
        identifier: "SwipeableDetailedLabelCellModel",
        attributedText: attrText,
        detailsText: attrText
      ),
      SwipeableLabelCellModel(identifier: "SwipeableLabelCellModel", attributedText: attrText)
    ]
    return cellModels
  }()

  public let listSections: [ListSection]
  public let sections: BehaviorRelay<[ListSection]>

  public init() {
    let mainSection = ListSection(cellModels: cellModels, identifier: "Section")

    let horizontalCellModel = HorizontalCollectionCellModel(
      identifier: "HorizontalCollectionCellModel",
      cellModels: [ImageCellModel(imageObservable: .just(UIImage()), imageSize: CGSize(width: 24, height: 24))],
      distribution: .entireRow,
      listController: LegacyListController()
    )!
    var horizontalSection = ListSection(
      cellModels: [horizontalCellModel],
      identifier: "HorizontalSection"
    )
    horizontalSection.constraints.scrollDirection = .horizontal
    listSections = [mainSection, horizontalSection]
    sections = BehaviorRelay<[ListSection]>(value: listSections)
  }
}
