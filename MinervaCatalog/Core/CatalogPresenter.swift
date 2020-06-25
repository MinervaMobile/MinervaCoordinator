//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Minerva
import RxRelay
import RxSwift
import UIKit

public final class CatalogPresenter: ListPresenter {
  public lazy var sections: BehaviorRelay<[ListSection]> = BehaviorRelay(
    value: [
      createButtonCellModelSection(),
      createButtonImageCellModelSection(),
      createDatePickerCellModelSection(),
      createDetailedLabelCellModelSection(),
      createHighlightableCellModelSection(),
      createIconTextCellModelSection(),
      createImageButtonCardCellModelSection(),
      createImageCellModelSection(),
      createImageLabelBorderCellModelSection(),
      createImageTextCardCellModelSection(),
      createImageTextCellModelSection(),
      createLabelAccessoryCellModelSection(),
      createLabelCellModelSection(),
      createMarginCellModelSection(),
      createPickerCellModelSection(),
      createPickerLabelCellModelSection(),
      createSegmentedControlCellModelSection(),
      createSeparatorCellModelSection(),
      createSwitchTextCellModelSection(),
      createTextInputCellModelSection(),
      createTextSeparatorCellModelSection(),
      createTextViewCellModelSection(),
      createSwipeableDetailedLabelCellModelSection(),
      createSwipeableLabelCellModelSection()
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
      font: font,
      iconImage: .just(image)
    )
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
      identifier: "DetailedLabelCellModel1",
      attributedTitle: title,
      attributedDetails: details
    )
    cellModels.append(model1)

    let model2 = DetailedLabelCellModel(
      identifier: "DetailedLabelCellModel2",
      attributedTitle: title,
      attributedDetails: NSAttributedString()
    )
    model2.backgroundColor = UIColor.systemGray5
    cellModels.append(model2)

    return createSection(for: cellModels, name: "DetailedLabelCellModel")
  }

  private func createHighlightableCellModelSection() -> ListSection {
    let model1 = HighlightableLabelCellModel(
      identifier: "HighlightableCellModel",
      text: "HighlightableCellModel",
      font: UIFont.preferredFont(forTextStyle: .subheadline)
    )
    model1.highlightEnabled = true
    model1.highlightColor = UIColor.systemPurple.withAlphaComponent(0.75)

    let font = UIFont.preferredFont(forTextStyle: .body)
    let image = UIImage(systemName: "trash")!

    let model2 = HighlightableIconTextCellModel(
      imageSize: CGSize(width: 32, height: 32),
      text: "HighlightableIconTextCellModel",
      font: font,
      iconImage: .just(image)
    )
    model2.highlightEnabled = true
    model2.highlightColor = model1.highlightColor

    return createSection(for: [model1, model2], name: "Highlightable Cells")
  }

  private func createIconTextCellModelSection() -> ListSection {
    let font = UIFont.preferredFont(forTextStyle: .body)
    let image = UIImage(systemName: "trash")!

    var cellModels = [ListCellModel]()

    let model1 = IconTextCellModel(
      imageSize: CGSize(width: 32, height: 32),
      text: "IconTextCellModel",
      font: font,
      iconImage: .just(image)
    )
    cellModels.append(model1)

    return createSection(for: cellModels, name: "IconTextCellModel")
  }

  private func createImageButtonCardCellModelSection() -> ListSection {
    let font = UIFont.preferredFont(forTextStyle: .body)
    let attributedText = NSAttributedString(
      string: "attributedText",
      attributes: [
        NSAttributedString.Key.font: font,
        NSAttributedString.Key.foregroundColor: UIColor.label
      ]
    )
    let selectedAttributedText = NSAttributedString(
      string: "selectedAttributedText",
      attributes: [
        NSAttributedString.Key.font: font,
        NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
      ]
    )
    let image = UIImage(systemName: "trash")!

    var cellModels = [ListCellModel]()

    let model1 = ImageButtonCardCellModel(
      identifier: "ImageButtonCardCellModel",
      attributedText: attributedText,
      selectedAttributedText: selectedAttributedText,
      image: image,
      imageSize: CGSize(width: 32, height: 32),
      isSelected: false
    )
    cellModels.append(model1)

    return createSection(for: cellModels, name: "ImageButtonCardCellModel")
  }

  private func createImageCellModelSection() -> ListSection {
    let image = UIImage(systemName: "trash")!

    var cellModels = [ListCellModel]()

    let model1 = ImageCellModel(
      identifier: "ImageCellModel-model1",
      image: image,
      imageSize: CGSize(width: 32, height: 32)
    )
    cellModels.append(model1)

    return createSection(for: cellModels, name: "ImageCellModel")
  }

  private func createImageLabelBorderCellModelSection() -> ListSection {
    let image = UIImage(systemName: "trash")!
    let size = CGSize(width: 32, height: 32)
    let font = UIFont.preferredFont(forTextStyle: .body)

    var cellModels = [ListCellModel]()

    let model1 = ImageLabelBorderCellModel(
      text: "ImageLabelBorderCellModel",
      font: font,
      image: image,
      imageSize: size
    )
    cellModels.append(model1)

    return createSection(for: cellModels, name: "ImageLabelBorderCellModel")
  }

  private func createImageTextCardCellModelSection() -> ListSection {
    let image = UIImage(systemName: "trash")!
    let font = UIFont.preferredFont(forTextStyle: .body)
    let attributedText = NSAttributedString(
      string: "attributedText",
      attributes: [
        NSAttributedString.Key.font: font,
        NSAttributedString.Key.foregroundColor: UIColor.label
      ]
    )

    var cellModels = [ListCellModel]()

    let model1 = ImageTextCardCellModel(
      identifier: "ImageTextCardCellModelmodel1",
      attributedText: attributedText,
      image: .just(image)
    )
    cellModels.append(model1)

    return createSection(for: cellModels, name: "ImageTextCardCellModel")
  }

  private func createImageTextCellModelSection() -> ListSection {
    let image = UIImage(systemName: "trash")!
    let font = UIFont.preferredFont(forTextStyle: .body)
    let attributedText = NSAttributedString(
      string: "attributedText",
      attributes: [
        NSAttributedString.Key.font: font,
        NSAttributedString.Key.foregroundColor: UIColor.label
      ]
    )

    var cellModels = [ListCellModel]()

    let model1 = ImageTextCellModel(
      identifier: "ImageTextCellModel",
      attributedText: attributedText,
      imageObservable: .just(image)
    )
    cellModels.append(model1)

    return createSection(for: cellModels, name: "ImageTextCellModel")
  }

  private func createLabelAccessoryCellModelSection() -> ListSection {
    let image = UIImage(systemName: "trash")!
    let font = UIFont.preferredFont(forTextStyle: .body)
    let attributedText = NSAttributedString(
      string: "attributedText",
      attributes: [
        NSAttributedString.Key.font: font,
        NSAttributedString.Key.foregroundColor: UIColor.label
      ]
    )

    var cellModels = [ListCellModel]()

    let model1 = LabelAccessoryCellModel(
      identifier: "LabelAccessoryCellModel",
      attributedText: attributedText
    )
    model1.accessoryImage = image
    cellModels.append(model1)

    return createSection(for: cellModels, name: "LabelAccessoryCellModel")
  }

  private func createLabelCellModelSection() -> ListSection {
    let font = UIFont.preferredFont(forTextStyle: .body)
    let attributedText = NSAttributedString(
      string: "attributedText",
      attributes: [
        NSAttributedString.Key.font: font,
        NSAttributedString.Key.foregroundColor: UIColor.label
      ]
    )

    var cellModels = [ListCellModel]()

    let model1 = LabelCellModel(identifier: "LabelCellModel", attributedText: attributedText)
    cellModels.append(model1)

    return createSection(for: cellModels, name: "LabelCellModel")
  }

  private func createMarginCellModelSection() -> ListSection {
    var cellModels = [ListCellModel]()

    let model1 = MarginCellModel(identifier: "MarginSection-MarginCellModel1", height: 64)
    cellModels.append(model1)

    let model2 = MarginCellModel(identifier: "MarginSection-MarginCellModel2", height: 8)
    cellModels.append(model2)

    return createSection(for: cellModels, name: "MarginCellModel")
  }

  private func createPickerCellModelSection() -> ListSection {
    let font = UIFont.preferredFont(forTextStyle: .body)
    let size = CGSize(width: 24, height: 24)
    let text = "text"
    let attributedText = NSAttributedString(
      string: text,
      attributes: [
        NSAttributedString.Key.font: font,
        NSAttributedString.Key.foregroundColor: UIColor.label
      ]
    )
    let image = UIImage(systemName: "trash")!
    let row = PickerDataRow(
      text: attributedText,
      imageData: PickerImageData(image: image, imageColor: .label, imageMargin: 0, imageSize: size)
    )
    let component = PickerDataComponent(
      data: [row, row],
      textAlignment: .center,
      verticalMargin: 0,
      startingRow: 0
    )

    var cellModels = [ListCellModel]()

    let model1 = PickerCellModel(
      identifier: "PickerCellModel1",
      pickerDataComponents: [component],
      changedValue: { _, _, _, _ in }
    )
    cellModels.append(model1)

    return createSection(for: cellModels, name: "PickerCellModel")
  }

  private func createPickerLabelCellModelSection() -> ListSection {
    let font = UIFont.preferredFont(forTextStyle: .body)
    let text = "text"
    let attributedText = NSAttributedString(
      string: text,
      attributes: [
        NSAttributedString.Key.font: font,
        NSAttributedString.Key.foregroundColor: UIColor.label
      ]
    )
    let options = PickerDataOptions(
      label: attributedText,
      labelMargin: 0,
      rowMargin: 0,
      startingRow: 0,
      rowTextAlignment: .center
    )
    let data = (1...5)
      .map {
        NSAttributedString(
          string: " \($0) ",
          attributes: [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.label
          ]
        )
      }
    let pickerData = PickerData(data: data, options: options)

    var cellModels = [ListCellModel]()

    let model1 = PickerLabelCellModel(
      identifier: "PickerLabelCellModel",
      pickerData: pickerData,
      changedValue: { _, _, _, _ in }
    )
    cellModels.append(model1)

    return createSection(for: cellModels, name: "PickerLabelCellModel")
  }

  private func createSegmentedControlCellModelSection() -> ListSection {
    var cellModels = [ListCellModel]()

    let model1 = SegmentedControlCellModel(
      selectedSegment: 0,
      segmentTitles: ["one", "two", "three"]
    )
    cellModels.append(model1)

    return createSection(for: cellModels, name: "SegmentedControlCellModel")
  }

  private func createSeparatorCellModelSection() -> ListSection {
    var cellModels = [ListCellModel]()

    cellModels.append(MarginCellModel(identifier: "SeperatorSection-MarginCellModel1", height: 8))
    let model1 = SeparatorCellModel(
      location: .top(cellModelID: "SeparatorCellModel1"),
      color: .separator,
      height: 8
    )
    cellModels.append(model1)

    cellModels.append(MarginCellModel(identifier: "SeperatorSection-MarginCellModel2", height: 8))

    let model2 = SeparatorCellModel(
      location: .bottom(cellModelID: "SeparatorCellModel2"),
      color: .separator,
      height: 4,
      followsLeadingMargin: true,
      followsTrailingMargin: true
    )
    model2.backgroundColor = UIColor.systemBackground
    cellModels.append(model2)

    cellModels.append(MarginCellModel(identifier: "MarginCellModel3", height: 8))

    return createSection(for: cellModels, name: "SeparatorCellModel", includeSeparators: false)
  }

  private func createSwitchTextCellModelSection() -> ListSection {
    let font = UIFont.preferredFont(forTextStyle: .body)
    var cellModels = [ListCellModel]()

    let model1 = SwitchTextCellModel(
      text: "text",
      font: font,
      textColor: .label,
      switchColor: .systemGreen,
      isOn: true
    )
    cellModels.append(model1)

    return createSection(for: cellModels, name: "SwitchTextCellModel")
  }

  private func createTextInputCellModelSection() -> ListSection {
    let font = UIFont.preferredFont(forTextStyle: .body)
    var cellModels = [ListCellModel]()

    let model1 = TextInputCellModel(
      identifier: "TextInputCellModel",
      placeholder: "placeholder",
      font: font
    )
    model1.inputTextColor = .label
    model1.placeholderTextColor = .secondaryLabel
    cellModels.append(model1)

    return createSection(for: cellModels, name: "TextInputCellModel")
  }

  private func createTextSeparatorCellModelSection() -> ListSection {
    var cellModels = [ListCellModel]()

    let model1 = TextSeparatorCellModel(text: "TextSeparatorCellModel")
    model1.textColor = .label
    model1.lineColor = .secondaryLabel
    cellModels.append(model1)

    return createSection(for: cellModels, name: "TextSeparatorCellModel")
  }

  private func createTextViewCellModelSection() -> ListSection {
    let font = UIFont.preferredFont(forTextStyle: .body)
    var cellModels = [ListCellModel]()

    let model1 = TextViewCellModel(
      identifier: "TextViewCellModel",
      text: nil,
      font: font
    )
    model1.textColor = .label
    model1.placeholderTextColor = .secondaryLabel
    model1.placeholderText = "placeholderText"
    cellModels.append(model1)

    return createSection(for: cellModels, name: "TextViewCellModel")
  }

  private func createSwipeableDetailedLabelCellModelSection() -> ListSection {
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

    let model1 = SwipeableDetailedLabelCellModel(
      identifier: "SwipeableDetailedLabelCellModel",
      attributedText: title,
      detailsText: details
    )
    cellModels.append(model1)

    return createSection(for: cellModels, name: "SwipeableDetailedLabelCellModel")
  }

  private func createSwipeableLabelCellModelSection() -> ListSection {
    let title = NSAttributedString(
      string: "Title",
      attributes: [
        NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title3),
        NSAttributedString.Key.foregroundColor: UIColor.label
      ]
    )
    var cellModels = [ListCellModel]()

    let model1 = SwipeableLabelCellModel(
      identifier: "SwipeableLabelCellModel",
      attributedText: title
    )
    cellModels.append(model1)

    return createSection(for: cellModels, name: "SwipeableLabelCellModel")
  }

  private func createSection(
    for cellModels: [ListCellModel],
    name: String,
    includeSeparators: Bool = true
  ) -> ListSection {
    var cellModels = cellModels
    if includeSeparators {
      let separatorModels = cellModels.map { cellModel -> SeparatorCellModel in
        let model = SeparatorCellModel(
          location: .bottom(cellModelID: cellModel.identifier),
          color: .separator
        )
        return model
      }
      cellModels = zip(cellModels, separatorModels).flatMap { [$0, $1] }
    }

    var section = ListSection(cellModels: cellModels, identifier: name)
    let header = LabelCellModel(text: name, font: .preferredFont(forTextStyle: .headline))
    header.backgroundColor = .secondarySystemBackground
    section.headerModel = header
    return section
  }
}
