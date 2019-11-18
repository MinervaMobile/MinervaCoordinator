//
//  MinervaTests.swift
//  MinervaTests
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Minerva
import XCTest

public final class IntegrationTests: XCTestCase {

  private var listController: ListController!
  private var collectionVC: UICollectionViewController!

  override public func setUp() {
    super.setUp()
    collectionVC = UICollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
    collectionVC.view.frame = CGRect(x: 0, y: 0, width: 500, height: 10_000)
    listController = LegacyListController()
    listController.viewController = collectionVC
    listController.collectionView = collectionVC.collectionView
  }

  override public func tearDown() {
    collectionVC = nil
    listController = nil
    super.tearDown()
  }

  public func testCreation() {
    XCTAssertNotNil(listController)
  }

  public func testUpdate() {
    let font = UIFont.preferredFont(forTextStyle: .body)
    let color = UIColor.label
    let size = CGSize(width: 24, height: 24)
    let text = "text"
    let attrText = NSAttributedString(string: text)
    let image = UIImage()
    let cellModels = [
      ButtonCellModel(text: "ButtonCellModel", font: font, textColor: color),
      ButtonImageCellModel(imageSize: size, text: "ButtonImageCellModel", font: font),
      DatePickerCellModel(identifier: "DatePickerCellModel", startDate: Date()),
      DetailedLabelCellModel(
        identifier: "DetailedLabelCellModel",
        attributedTitle: attrText,
        attributedDetails: attrText
      ),
      HorizontalCollectionCellModel(
        identifier: "HorizontalCollectionCellModel",
        cellModels: [MarginCellModel(location: .top)],
        distribution: .entireRow,
        listController: LegacyListController()
      )!,
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
      PickerCellModel(identifier: "PickerCellModel", pickerDataComponents: [], changedValue: { _, _, _, _ in }),
      PickerLabelCellModel(
        identifier: "PickerLabelCellModel",
        pickerData: PickerData(data: [], options: nil),
        changedValue: { _, _, _, _ in }
      ),
      SegmentedControlCellModel(selectedSegment: 0, segmentTitles: [text]),
      SeparatorCellModel(location: .bottom(cellModelID: "SeparatorCellModel"), color: color),
      SwitchTextCellModel(text: "SwitchTextCellModel", font: font, textColor: color, switchColor: color, isOn: true),
      TextInputCellModel(identifier: "TextInputCellModel", placeholder: text, font: font),
      TextSeparatorCellModel(text: "TextSeparatorCellModel"),
      TextViewCellModel(identifier: "TextViewCellModel", text: nil, font: font, changedValue: { _, _ in })
    ]
    let section = ListSection(cellModels: cellModels, identifier: "Section")
    let sections = [section]
    let updateExpectation = expectation(description: "Update Expectation")
    listController.update(with: sections, animated: false) { finished in
      XCTAssert(finished)
      updateExpectation.fulfill()
    }
    wait(for: [updateExpectation], timeout: 1)

    for (index, model) in cellModels.enumerated() {
      let cell = collectionVC.collectionView.cellForItem(at: IndexPath(row: index, section: 0))!
      let modelCellType = model.cellType
      let actualCellType = type(of: cell)
      XCTAssert(modelCellType === actualCellType)
    }
  }
}
