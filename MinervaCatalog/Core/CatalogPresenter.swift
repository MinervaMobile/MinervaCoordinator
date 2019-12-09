//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Minerva
import RxSwift
import UIKit

public final class CatalogPresenter: Presenter {
  public lazy var sections: Observable<[ListSection]> = Observable.just(
    [
      createButtonCellModelSection(),
      createButtonImageCellModelSection(),
      createDatePickerCellModelSection(),
      createDetailedLabelCellModelSection(),
      createOtherCellModelSection()
    ]
  )

  private func createButtonCellModelSection() -> ListSection {
    let font = UIFont.preferredFont(forTextStyle: .body)
    var cellModels = [ListCellModel]()

    let model1 = ButtonCellModel(text: "ButtonCellModel1", font: font, textColor: .label)
    cellModels.append(model1)

    let model2 = ButtonCellModel(text: "ButtonCellModel2", font: font, textColor: .label)
    model2.textAlignment = .left
    model2.borderColor = .label
    cellModels.append(model2)

    return createSection(for: cellModels, name: "ButtonCellModel")
  }

  private func createButtonImageCellModelSection() -> ListSection {
    let font = UIFont.preferredFont(forTextStyle: .body)
    let image = UIImage(systemName: "trash")!

    var cellModels = [ListCellModel]()

    let model1 = ButtonImageCellModel(
      imageSize: CGSize(width: 24, height: 24),
      text: "ButtonImageCellModel",
      font: font
    )
    model1.iconImage.onNext(image)
    cellModels.append(model1)

    return createSection(for: cellModels, name: "ButtonImageCellModel")
  }

  private func createDatePickerCellModelSection() -> ListSection {
    var cellModels = [ListCellModel]()

    let model1 = DatePickerCellModel(identifier: "DatePickerCellModel", startDate: Date())
    cellModels.append(model1)

    return createSection(for: cellModels, name: "DatePickerCellModel")
  }

  private func createDetailedLabelCellModelSection() -> ListSection {
    let title = NSAttributedString(
      string: "Title",
      attributes: [
        NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title3),
        NSAttributedString.Key.foregroundColor: UIColor.label
      ]
    )
    let details = NSAttributedString(
      string: "Details",
      attributes: [
        NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline),
        NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
      ]
    )

    var cellModels = [ListCellModel]()

    let model1 = DetailedLabelCellModel(
      identifier: "DetailedLabelCellModel",
      attributedTitle: title,
      attributedDetails: details
    )
    cellModels.append(model1)

    return createSection(for: cellModels, name: "DetailedLabelCellModel")
  }

  private func createOtherCellModelSection() -> ListSection {
    let font = UIFont.preferredFont(forTextStyle: .body)
    let size = CGSize(width: 24, height: 24)
    let text = "text"
    let attrText = NSAttributedString(
      string: text,
      attributes: [
        NSAttributedString.Key.font: font,
        NSAttributedString.Key.foregroundColor: UIColor.label
      ]
    )
    let image = UIImage(systemName: "trash")!
    let row = PickerDataRow(
      text: attrText,
      imageData: PickerImageData(image: image, imageColor: .label, imageMargin: 0, imageSize: size)
    )
    let component = PickerDataComponent(data: [row, row], textAlignment: .center, verticalMargin: 0, startingRow: 0)
    let options = PickerDataOptions(
      label: attrText,
      labelMargin: 0,
      rowMargin: 0,
      startingRow: 0,
      rowTextAlignment: .center)
    let pickerData = PickerData(data: [attrText, attrText, attrText], options: options)
    let cellModels = [
      // Cells
      IconTextCellModel(imageSize: size, text: "IconTextCellModel", font: font),
      ImageButtonCardCellModel(
        identifier: "ImageButtonCardCellModel",
        attributedText: attrText,
        selectedAttributedText: attrText,
        image: image,
        imageSize: size,
        isSelected: true
      ),
      ImageCellModel(image: image, imageSize: size),
      ImageLabelBorderCellModel(text: "ImageLabelBorderCellModel", font: font, image: image, imageSize: size),
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
      PickerLabelCellModel(identifier: "PickerLabelCellModel", pickerData: pickerData, changedValue: { _, _, _, _ in }),
      SegmentedControlCellModel(selectedSegment: 0, segmentTitles: [text]),
      SeparatorCellModel(location: .bottom(cellModelID: "SeparatorCellModel"), color: .separator),
      SwitchTextCellModel(
        text: "SwitchTextCellModel",
        font: font,
        textColor: .label,
        switchColor: .secondaryLabel,
        isOn: true
      ),
      TextInputCellModel(identifier: "TextInputCellModel", placeholder: text, font: font),
      TextSeparatorCellModel(text: "TextSeparatorCellModel"),
      TextViewCellModel(identifier: "TextViewCellModel", text: text, font: font, changedValue: { _, _ in }),
      // Swipe
      SwipeableDetailedLabelCellModel(
        identifier: "SwipeableDetailedLabelCellModel",
        attributedText: attrText,
        detailsText: attrText
      ),
      SwipeableLabelCellModel(identifier: "SwipeableLabelCellModel", attributedText: attrText)
    ]
    return createSection(for: cellModels, name: "Other Cell Models")
  }

  private func createSection(for cellModels: [ListCellModel], name: String) -> ListSection {
    let separatorModels = cellModels.map { cellModel -> SeparatorCellModel in
      let model = SeparatorCellModel(
        location: .bottom(cellModelID: cellModel.identifier),
        color: .separator
      )
      return model
    }
    let models = zip(cellModels, separatorModels).flatMap { [$0, $1] }

    var section = ListSection(cellModels: models, identifier: name)
    let header = LabelCellModel(text: name, font: .preferredFont(forTextStyle: .headline))
    header.backgroundColor = .secondarySystemBackground
    section.headerModel = header
    return section
  }
}
